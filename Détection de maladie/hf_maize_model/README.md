---
language:
  - en
thumbnail: "/assets/image.jpg"
tags:
  - image-classification
  - computer-vision
  - agriculture
  - maize-diseases
license: mit
datasets:
  - smaranjitghose/corn-or-maize-leaf-disease-dataset
metrics:
  - accuracy
pipeline_tag: image-classification
---

# Maize Disease Detection Model

This model is designed to detect diseases in maize (corn) leaves using computer vision techniques.

## Model description

The Maize Disease Detection Model is a convolutional neural network (CNN) trained to classify images of maize leaves into four categories: Healthy, Gray Leaf Spot, Blight, and Common Rust. It aims to assist farmers and agricultural professionals in quickly identifying common maize diseases, potentially leading to earlier interventions and improved crop management.

### Intended uses & limitations

The model is intended for use as a diagnostic tool to assist in the identification of maize leaf diseases. It should be used in conjunction with expert knowledge and not as a sole means of diagnosis. The model's performance may vary depending on image quality, lighting conditions, and the presence of diseases or conditions not included in the training dataset.

**Limitations:**
- The model is trained on a specific dataset and may not generalize well to significantly different growing conditions or maize varieties.
- It is not designed to detect diseases other than the four categories it was trained on.
- Performance on images with multiple diseases present has not been extensively tested.
- The model should not be used as a replacement for professional agricultural advice.

### How to use

Here's a basic example of how to use the model:

```python
import tensorflow as tf
from PIL import Image
import numpy as np
import json

import tensorflow as tf
from huggingface_hub import snapshot_download

# Download the entire model directory
model_dir = snapshot_download(repo_id="eligapris/maize-diseases-detection",
    local_dir="path/to/model")

# Load the model
model = tf.saved_model.load('path/to/model')

# Now you can use the model for inference

# Load and preprocess the image
img = Image.open('/path/to/image.jpg')
img = img.resize((300, 300 * img.size[1] // img.size[0]))  
img_array = np.array(img)[None]

# Make prediction
inp = tensorflow.constant(img_array, dtype='float32')
prediction = model(inp)[0].numpy()

# Load class names
with open('path/to/model/classes.json', 'r') as f:
    class_names = json.load(f)

# Get the predicted class
predicted_class = list(class_names.keys())[prediction.argmax()]
print(f"Predicted class: {predicted_class}")
```


Here's a detailed output of model prediction:

```python
import tensorflow as tf
from PIL import Image
import numpy as np
import json

import tensorflow as tf
from huggingface_hub import snapshot_download

# Download the entire model directory
model_dir = snapshot_download(repo_id="eligapris/maize-diseases-detection",
    local_dir="path/to/model")

# Load the model
model = tf.saved_model.load('path/to/model')

# Now you can use the model for inference

# Load and preprocess the image
img = Image.open('/path/to/image.jpg')
img = img.resize((300, 300 * img.size[1] // img.size[0]))  
img_array = np.array(img)[None]

# Make prediction
inp = tensorflow.constant(img_array, dtype='float32')
prediction = model(inp)[0].numpy()

# Load class names and details
with open('model/classes_detailed.json', 'r') as f:
    data = json.load(f)

class_names = data['classes']
class_details = data['details']

# Get the predicted class
predicted_class = list(class_names.keys())[prediction.argmax()]
predicted_class_label = class_names[predicted_class]

print(f"Predicted class: {predicted_class} (Label: {predicted_class_label})")

# Print detailed information about the predicted class
if predicted_class in class_details:
    details = class_details[predicted_class]
    print("\nDetailed Information:")
    for key, value in details.items():
        if isinstance(value, list):
            print(f"{key.capitalize()}:")
            for item in value:
                print(f"  - {item}")
        else:
            print(f"{key.capitalize()}: {value}")

# Print general notes
print("\nGeneral Notes:")
for note in data['general_notes']:
    print(f"- {note}")
```

### Test the colab 
```
https://colab.research.google.com/drive/13-S-obR6MZDDP5kgj6ytsbFiNKzzfXbp
```
### Training data

The model was trained on a dataset derived from the PlantVillage and PlantDoc datasets, specifically curated for maize leaf diseases. The dataset consists of:

- Common Rust: 1306 images
- Gray Leaf Spot: 574 images
- Blight: 1146 images
- Healthy: 1162 images

Total images: 4188

The original dataset can be found on Kaggle: [Corn or Maize Leaf Disease Dataset](https://www.kaggle.com/datasets/smaranjitghose/corn-or-maize-leaf-disease-dataset)

## Ethical considerations

- The model's predictions should not be used as the sole basis for agricultural decisions that may impact food security or farmers' livelihoods.
- There may be biases in the training data that could lead to reduced performance for certain maize varieties or growing conditions not well-represented in the dataset.
- Users should be made aware of the model's limitations and the importance of expert validation.

Additionally, please credit the original authors of the PlantVillage and PlantDoc datasets, as this model's training data is derived from their work.

## Model Card Authors

Grey

## Model Card Contact

eligapris