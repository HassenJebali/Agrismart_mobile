"""
ML API for plant disease detection.
"""
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import importlib
import io
import json
from pathlib import Path
import logging

import numpy as np
from huggingface_hub import snapshot_download

tf = None


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Plant Disease Detection API",
    description="API for diagnosing plant diseases from photos",
    version="2.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

HF_REPO_ID = "eligapris/maize-diseases-detection"
HF_MODEL_DIR = Path(__file__).resolve().parent / "hf_maize_model"
DEFAULT_INPUT_SIZE = (300, 300)
DEFAULT_CLASS_NAMES = [
    "Gray_Leaf_Spot",
    "Common_Rust",
    "Northern_Leaf_Blight",
    "Healthy",
]

model = None
model_input_size = DEFAULT_INPUT_SIZE
model_load_error = None
class_names = DEFAULT_CLASS_NAMES.copy()


def _label_for_index(index: int) -> str:
    if 0 <= index < len(class_names):
        return class_names[index]
    return f"Class {index}"


def _load_class_names(model_dir: Path) -> list[str]:
    def parse_mapping(mapping: dict) -> list[str]:
        # Format A: {"Healthy": 0, "Gray_Leaf_Spot": 1, ...}
        if all(isinstance(value, (int, float)) for value in mapping.values()):
            ordered = sorted(mapping.items(), key=lambda item: int(item[1]))
            return [str(key) for key, _ in ordered]

        # Format B: {"0": "Healthy", "1": "Gray_Leaf_Spot", ...}
        if all(str(key).isdigit() for key in mapping.keys()):
            ordered = sorted(mapping.items(), key=lambda item: int(item[0]))
            return [str(value) for _, value in ordered]

        return [str(value) for value in mapping.values()]

    classes_detailed_path = model_dir / "classes_detailed.json"
    classes_path = model_dir / "classes.json"

    if classes_detailed_path.exists():
        with classes_detailed_path.open("r", encoding="utf-8") as handle:
            payload = json.load(handle)
        class_mapping = payload.get("classes", {})
        if isinstance(class_mapping, dict) and class_mapping:
            return parse_mapping(class_mapping)

    if classes_path.exists():
        with classes_path.open("r", encoding="utf-8") as handle:
            payload = json.load(handle)
        if isinstance(payload, dict) and payload:
            return parse_mapping(payload)
        if isinstance(payload, list) and payload:
            return [str(value) for value in payload]

    return DEFAULT_CLASS_NAMES.copy()


def _extract_prediction_array(raw_output) -> np.ndarray:
    if isinstance(raw_output, dict):
        raw_output = next(iter(raw_output.values()))
    elif isinstance(raw_output, (list, tuple)):
        raw_output = raw_output[0]

    if hasattr(raw_output, "numpy"):
        output_array = raw_output.numpy()
    else:
        output_array = np.asarray(raw_output)

    output_array = np.asarray(output_array)
    if output_array.ndim == 0:
        output_array = output_array.reshape(1)
    elif output_array.ndim > 1:
        output_array = output_array[0]

    return output_array


def _get_input_size(loaded_model) -> tuple[int, int]:
    input_shape = getattr(loaded_model, "input_shape", None)

    if isinstance(input_shape, list):
        input_shape = input_shape[0]

    if isinstance(input_shape, tuple) and len(input_shape) >= 3:
        height, width = input_shape[1], input_shape[2]
        if height and width:
            return int(height), int(width)

    return DEFAULT_INPUT_SIZE


def _softmax(values: np.ndarray) -> np.ndarray:
    values = np.asarray(values, dtype=np.float32)
    values = values - np.max(values)
    exp_values = np.exp(values)
    total = float(np.sum(exp_values))
    if total <= 0:
        return np.zeros_like(values)
    return exp_values / total


def _normalize_probabilities(raw_values) -> np.ndarray:
    scores = np.asarray(raw_values, dtype=np.float32).reshape(-1)
    if scores.size == 0:
        return scores

    if np.all(np.isfinite(scores)):
        if np.all(scores >= 0):
            total = float(np.sum(scores))
            if total > 0:
                if abs(total - 1.0) > 0.01:
                    scores = scores / total
                return scores
        return _softmax(scores)

    return np.zeros_like(scores)


def preprocess_image(image: Image.Image, size: tuple[int, int] = DEFAULT_INPUT_SIZE) -> np.ndarray:
    image = image.convert("RGB")
    target_width = size[0]
    target_height = max(1, int(target_width * image.size[1] / image.size[0]))
    image = image.resize((target_width, target_height), Image.Resampling.LANCZOS)
    image_array = np.asarray(image).astype(np.float32)
    return np.expand_dims(image_array, axis=0)


def load_model():
    """Load the Hugging Face SavedModel."""
    global model, model_load_error, model_input_size, class_names

    try:
        global tf
        if tf is None:
            tf = importlib.import_module("tensorflow")

        model_dir = Path(
            snapshot_download(
                repo_id=HF_REPO_ID,
                local_dir=str(HF_MODEL_DIR),
            )
        )

        loaded_model = tf.saved_model.load(str(model_dir))
        model = loaded_model
        model_input_size = (300, 300)
        class_names = _load_class_names(model_dir)
        model_load_error = None
        logger.info("Model loaded successfully from %s", model_dir)
        return True
    except Exception as error:
        model = None
        model_load_error = str(error)
        logger.error("Error while loading model: %s", error)
        return False


def _run_prediction(image: Image.Image):
    if model is None:
        raise HTTPException(status_code=503, detail="Model unavailable")

    image_tensor = preprocess_image(image, model_input_size)
    tf_input = tf.constant(image_tensor, dtype=tf.float32)
    raw_predictions = model(tf_input)
    predictions = _extract_prediction_array(raw_predictions)

    probabilities = _normalize_probabilities(predictions)
    if probabilities.size == 0:
        raise ValueError("Model returned no probabilities")

    top_indices = np.argsort(probabilities)[::-1]
    top_indices = top_indices[: min(3, len(top_indices))]
    predicted_index = int(top_indices[0])

    top3 = [
        {
            "label": _label_for_index(int(index)),
            "confidence": round(float(probabilities[int(index)]) * 100.0, 2),
        }
        for index in top_indices
    ]

    return {
        "top_class": _label_for_index(predicted_index),
        "confidence": round(float(probabilities[predicted_index]) * 100.0, 2),
        "top3": top3,
        "probabilities": {
            _label_for_index(index): round(float(probabilities[index]) * 100.0, 2)
            for index in range(len(probabilities))
        },
        "model": HF_REPO_ID,
    }


@app.on_event("startup")
async def startup_event():
    """Load the model at startup."""
    success = load_model()
    if not success:
        logger.warning("Unable to load model at startup")


@app.get("/")
async def root():
    return {
        "name": "Plant Disease Detection API",
        "version": "2.0.0",
        "endpoints": {
            "predict": "/predict (POST)",
            "diagnose": "/diagnose (POST)",
            "health": "/health (GET)",
            "info": "/info (GET)",
        },
    }


@app.get("/health")
async def health():
    return {
        "status": "healthy" if model is not None else "model_not_loaded",
        "device": "tensorflow",
        "model_loaded": model is not None,
        "model_error": model_load_error,
        "model_path": str(HF_MODEL_DIR),
        "hf_repo": HF_REPO_ID,
    }


@app.get("/info")
async def info():
    return {
        "name": "Corn/Maize Leaf Disease Model",
        "version": "2.0.0",
        "framework": "TensorFlow/Keras",
        "device": "tensorflow",
        "model_path": str(HF_MODEL_DIR),
        "hf_repo": HF_REPO_ID,
        "model_loaded": model is not None,
        "model_error": model_load_error,
        "input_size": model_input_size,
        "classes": class_names,
    }


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    if model is None:
        raise HTTPException(status_code=503, detail="Model unavailable")

    try:
        if file.content_type not in ["image/jpeg", "image/png", "image/jpg", "image/webp"]:
            raise HTTPException(status_code=400, detail="Unsupported image format. Use JPG, PNG or WEBP")

        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data))
        return _run_prediction(image)
    except HTTPException:
        raise
    except Exception as error:
        logger.error("Error during prediction: %s", error)
        raise HTTPException(status_code=500, detail=f"Processing error: {error}")


@app.post("/diagnose")
async def diagnose(file: UploadFile = File(...)):
    prediction = await predict(file)
    return {
        "diagnostic": prediction["top_class"],
        "confidence": prediction["confidence"],
        "probabilities": prediction["probabilities"],
        "model_version": prediction["model"],
    }


@app.post("/diagnose_batch")
async def diagnose_batch(files: list[UploadFile] = File(...)):
    if model is None:
        raise HTTPException(status_code=503, detail="Model unavailable")

    results = []
    for file in files:
        try:
            if file.content_type not in ["image/jpeg", "image/png", "image/jpg", "image/webp"]:
                raise HTTPException(status_code=400, detail="Unsupported image format. Use JPG, PNG or WEBP")

            image_data = await file.read()
            image = Image.open(io.BytesIO(image_data))
            prediction = _run_prediction(image)
            results.append({
                "filename": file.filename,
                "diagnostic": prediction["top_class"],
                "confidence": prediction["confidence"],
            })
        except Exception as error:
            results.append({
                "filename": file.filename,
                "error": str(error),
            })

    return {"results": results}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8001)