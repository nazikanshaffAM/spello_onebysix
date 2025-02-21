import os
import queue
import sounddevice as sd
import vosk
import json
import random
from rapidfuzz.distance import Levenshtein

try:
    # Set the path to the downloaded model
    MODEL_PATH = "vosk-model-small-en-us-0.15"

    # Load Vosk Model
    if not os.path.exists(MODEL_PATH):
        raise ValueError("Model not found! Please download and extract it.")

    model = vosk.Model(MODEL_PATH)
    recognizer = vosk.KaldiRecognizer(model,16000)  # rate is to make reading fast and accurate as much as possible 16kHz

    # Audio Recording Settings
    q = queue.Queue()


    def callback(indata, frames, time, status):
        if status:
            print(status)
        q.put(bytes(indata))  # Store audio data


    WORDS = ["water bottle","redeem", "cow","shit got real","pakistan"]
    TARGET_WORD = random.choice(WORDS)



    # Function to calculate similarity percentage
    def calculate_accuracy(target, spoken):
        if not spoken:
            return 0  # No spoken word detected
        distance = Levenshtein.distance(target, spoken)
        max_length = max(len(target), len(spoken))
        accuracy = ((max_length - distance) / max_length) * 100
        return round(accuracy, 2)


    # Start Recording
    with sd.RawInputStream(samplerate=16000, blocksize=8000, dtype='int16',
                           channels=1, callback=callback):
        print("Speak the word:", TARGET_WORD)

        while True:
            data = q.get()
            if recognizer.AcceptWaveform(data):
                result = json.loads(recognizer.Result())
                spoken_word = result["text"].strip()

                # Calculate accuracy
                accuracy = calculate_accuracy(TARGET_WORD, spoken_word)

                if accuracy == 100:
                    print("Correct! Well done!")
                    print(f"Accuracy: {accuracy}%")
                    break
                else:
                    print(f"Incorrect. You said: '{spoken_word}' instead of '{TARGET_WORD}'")
                    print(f"Accuracy: {accuracy}%")
                    print("Try again!")
except KeyboardInterrupt:
    print("Program terminated!")