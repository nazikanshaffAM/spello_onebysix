import os
import json
import random
# import sounddevice as sd
import vosk
from rapidfuzz.distance import Levenshtein
from flask import Flask, request, jsonify
from io import BytesIO