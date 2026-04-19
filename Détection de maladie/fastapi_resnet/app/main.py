import json
import os
from io import BytesIO
from pathlib import Path
from typing import List, Optional

import numpy as np
import onnxruntime as ort
from fastapi import FastAPI, File, HTTPException, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
from pydantic import BaseModel


class TopPrediction(BaseModel):
    label: str
    confidence: float


class PredictResponse(BaseModel):
    top_class: str
    confidence: float
    top3: List[TopPrediction]
    model: str


BASE_DIR = Path(__file__).resolve().parents[2]
MODELS_DIR = BASE_DIR / "models"
ONNX_MODEL_PATH = MODELS_DIR / "plant_disease_model.onnx"
CLASS_NAMES_PATH = MODELS_DIR / "class_names.json"

app = FastAPI(title="AgriSmart Plant Disease API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:4200",
        "http://127.0.0.1:4200",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


_session: Optional[ort.InferenceSession] = None
_input_name: Optional[str] = None
_class_names: Optional[List[str]] = None


def _load_class_names() -> Optional[List[str]]:
    if CLASS_NAMES_PATH.exists():
        with open(CLASS_NAMES_PATH, "r", encoding="utf-8") as fp:
            data = json.load(fp)
        if isinstance(data, list) and data:
            return [str(x) for x in data]
    return None


def _ensure_model_loaded() -> None:
    global _session, _input_name, _class_names

    if _session is not None:
        return

    if not ONNX_MODEL_PATH.exists():
        raise HTTPException(
            status_code=503,
            detail=(
                f"Modele ONNX introuvable: {ONNX_MODEL_PATH}. "
                "Exporte le modele depuis Resnet.ipynb avant de lancer l'API."
            ),
        )

    providers = ["CPUExecutionProvider"]
    try:
        if ort.get_device().upper() == "GPU":
            providers = ["CUDAExecutionProvider", "CPUExecutionProvider"]
    except Exception:
        providers = ["CPUExecutionProvider"]

    _session = ort.InferenceSession(str(ONNX_MODEL_PATH), providers=providers)
    _input_name = _session.get_inputs()[0].name
    _class_names = _load_class_names()


def _preprocess_image(raw: bytes) -> np.ndarray:
    image = Image.open(BytesIO(raw)).convert("RGB")
    image = image.resize((256, 256))
    arr = np.asarray(image, dtype=np.float32) / 255.0
    arr = np.transpose(arr, (2, 0, 1))
    arr = np.expand_dims(arr, axis=0)
    return arr


def _softmax(logits: np.ndarray) -> np.ndarray:
    x = logits - np.max(logits)
    exp = np.exp(x)
    return exp / np.sum(exp)


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/predict", response_model=PredictResponse)
async def predict(file: UploadFile = File(...)) -> PredictResponse:
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Le fichier doit etre une image.")

    _ensure_model_loaded()

    raw = await file.read()
    if not raw:
        raise HTTPException(status_code=400, detail="Image vide.")

    inp = _preprocess_image(raw)
    outputs = _session.run(None, {_input_name: inp})
    logits = np.array(outputs[0]).squeeze()
    probs = _softmax(logits)

    indices = np.argsort(probs)[::-1][:3]
    top_items: List[TopPrediction] = []

    for idx in indices:
        idx_int = int(idx)
        label = str(idx_int)
        if _class_names and idx_int < len(_class_names):
            label = _class_names[idx_int]
        top_items.append(TopPrediction(label=label, confidence=float(probs[idx_int])))

    best = top_items[0]
    return PredictResponse(
        top_class=best.label,
        confidence=best.confidence,
        top3=top_items,
        model="onnxruntime",
    )
