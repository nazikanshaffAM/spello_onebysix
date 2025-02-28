import os
import json
import random
import vosk
from rapidfuzz.distance import Levenshtein
from flask import Flask, request, jsonify
from io import BytesIO

app = Flask(__name__)

# path to the downloaded model
MODEL_PATH = "vosk-model-small-en-us-0.15"


# Load Vosk Model
if not os.path.exists(MODEL_PATH):
    raise ValueError("Model not found! Please download and extract it.")


model = vosk.Model(MODEL_PATH)
recognizer = vosk.KaldiRecognizer(model, 16000)  # rate is 16kHz

#sample word
TARGET_WORD = "cow"


# Function to calculate similarity percentage
def calculate_accuracy(target, spoken):
    if not spoken:
        return 0  # No spoken word detected
    distance = Levenshtein.distance(target, spoken)
    max_length = max(len(target), len(spoken))
    accuracy = ((max_length - distance) / max_length) * 100
    return round(accuracy, 2)