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