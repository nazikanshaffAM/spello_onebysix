import requests
import time
import json
import statistics
import matplotlib.pyplot as plt
import concurrent.futures
import random
import io
import wave
from locust import HttpUser, task, between

# Base URL for API
BASE_URL = "http://localhost:5000"  # Change to your deployment URL

# Test user credentials
TEST_USER = {
    "email": "test_performance@example.com",
    "password": "test1234",
    "name": "Performance Tester"
}

# Sample audio file path (you'll need a real WAV file)
SAMPLE_AUDIO_PATH = "test_audio.wav"


# Create a dummy audio file for testing
def create_dummy_audio():
    """Create a dummy audio file for testing purposes"""
    audio_data = io.BytesIO()
    with wave.open(audio_data, 'wb') as wav:
        wav.setnchannels(1)  # mono
        wav.setsampwidth(2)  # 16-bit
        wav.setframerate(16000)  # 16kHz (expected by Vosk)
        # Create 1 second of silence
        wav.writeframes(b'\x00' * 32000)

    with open(SAMPLE_AUDIO_PATH, 'wb') as f:
        f.write(audio_data.getvalue())

    return SAMPLE_AUDIO_PATH