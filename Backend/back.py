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