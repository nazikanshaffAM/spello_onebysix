import os
import json
import random
#import vosk
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

def get_random_target_word():
    TARGET_WORD_LIST = ["Think", "This", "Rabbit", "Lemon", "Snake", "Ship", "Cheese", "Juice", "Zebra", "Violin", "Fish", "Water",
             "Yellow", "Sing", "Tiger", "Dinosaur", "Pencil", "Banana", "Kite", "Goat"]
    random.shuffle(TARGET_WORD_LIST)
    return random.choice(TARGET_WORD_LIST)

#get one target word from the list
TARGET_WORD = get_random_target_word()
print(TARGET_WORD)



# Function to calculate similarity percentage
def calculate_accuracy(target, spoken):
    if not spoken:
        return 0  # No spoken word detected
    distance = Levenshtein.distance(target, spoken)
    max_length = max(len(target), len(spoken))
    accuracy = ((max_length - distance) / max_length) * 100
    return round(accuracy, 2)


# API Endpoint to receive audio
@app.route('/speech-to-text', methods=['POST'])
def speech_to_text():
    # Get audio data from the request (expecting audio in WAV format)
    audio_file = request.files['audio']

    # Read the audio file
    audio_data = audio_file.read()

    # Process audio with Vosk model
    recognizer.AcceptWaveform(audio_data)
    result = json.loads(recognizer.Result())
    spoken_word = result.get("text", "").strip()

    # Calculate accuracy
    accuracy = calculate_accuracy(TARGET_WORD, spoken_word)

    # Return the accuracy to the client
    return jsonify({
        "spoken_word": spoken_word,
        "target_word": TARGET_WORD,
        "accuracy": accuracy
    })


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)