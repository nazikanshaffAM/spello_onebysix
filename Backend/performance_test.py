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




# Helper function to register and log in a test user
def setup_test_user():
    """Register and log in a test user for performance testing"""
    # Check if user exists and delete if so
    response = requests.get(f"{BASE_URL}/get_user", params={"email": TEST_USER["email"]})
    if response.status_code == 200:
        requests.delete(f"{BASE_URL}/delete_user", params={"email": TEST_USER["email"]})

    # Register test user
    response = requests.post(f"{BASE_URL}/register", json=TEST_USER)
    if response.status_code != 201:
        print(f"Failed to register test user: {response.text}")
        return None

    # Log in test user
    response = requests.post(f"{BASE_URL}/login", json={
        "email": TEST_USER["email"],
        "password": TEST_USER["password"]
    })

    if response.status_code != 200:
        print(f"Failed to log in test user: {response.text}")
        return None

    # Return session cookies
    return response.cookies


# Performance testing functions
def test_endpoint(session, method, endpoint, payload=None, files=None, params=None, name=None):
    """Test a specific endpoint and measure response time"""
    start_time = time.time()

    if method.upper() == "GET":
        response = session.get(f"{BASE_URL}{endpoint}", params=params)
    elif method.upper() == "POST":
        response = session.post(f"{BASE_URL}{endpoint}", json=payload, files=files, params=params)
    elif method.upper() == "PUT":
        response = session.put(f"{BASE_URL}{endpoint}", json=payload, params=params)
    elif method.upper() == "DELETE":
        response = session.delete(f"{BASE_URL}{endpoint}", params=params)
    else:
        raise ValueError(f"Unsupported HTTP method: {method}")

    end_time = time.time()
    response_time = (end_time - start_time) * 1000  # Convert to milliseconds

    endpoint_name = name if name else endpoint
    status = "SUCCESS" if 200 <= response.status_code < 300 else "FAIL"

    result = {
        "endpoint": endpoint_name,
        "method": method,
        "status_code": response.status_code,
        "response_time_ms": response_time,
        "status": status
    }

    return result

def run_load_test(endpoint, method, payload=None, files=None, params=None, name=None,
                  num_requests=100, concurrency=10):
    """Run a load test on a specific endpoint with concurrent requests"""
    session = requests.Session()
    cookies = setup_test_user()
    if cookies:
        session.cookies.update(cookies)

    results = []

    def make_request():
        return test_endpoint(session, method, endpoint, payload, files, params, name)

    with concurrent.futures.ThreadPoolExecutor(max_workers=concurrency) as executor:
        future_to_req = {executor.submit(make_request): i for i in range(num_requests)}
        for future in concurrent.futures.as_completed(future_to_req):
            result = future.result()
            results.append(result)

    return results


def analyze_results(results):
    """Analyze performance test results"""
    response_times = [r["response_time_ms"] for r in results if r["status"] == "SUCCESS"]
    if not response_times:
        return {
            "success_rate": 0,
            "total_requests": len(results),
            "min_response_time": 0,
            "max_response_time": 0,
            "avg_response_time": 0,
            "median_response_time": 0,
            "p90_response_time": 0,
            "p95_response_time": 0,
            "p99_response_time": 0
        }

    success_count = len(response_times)
    total_count = len(results)

    response_times.sort()
    p90_index = int(success_count * 0.9)
    p95_index = int(success_count * 0.95)
    p99_index = int(success_count * 0.99)

    return {
        "success_rate": (success_count / total_count) * 100,
        "total_requests": total_count,
        "min_response_time": min(response_times),
        "max_response_time": max(response_times),
        "avg_response_time": statistics.mean(response_times),
        "median_response_time": statistics.median(response_times),
        "p90_response_time": response_times[p90_index - 1] if p90_index > 0 else 0,
        "p95_response_time": response_times[p95_index - 1] if p95_index > 0 else 0,
        "p99_response_time": response_times[p99_index - 1] if p99_index > 0 else 0
    }



def plot_results(results, title):
    """Generate a plot of response times"""
    response_times = [r["response_time_ms"] for r in results if r["status"] == "SUCCESS"]
    if not response_times:
        print(f"No successful requests for {title}")
        return

    plt.figure(figsize=(10, 6))
    plt.hist(response_times, bins=20, alpha=0.7)
    plt.axvline(statistics.mean(response_times), color='r', linestyle='dashed', linewidth=1)
    plt.axvline(statistics.median(response_times), color='g', linestyle='dashed', linewidth=1)

    plt.title(f"Response Time Distribution: {title}")
    plt.xlabel("Response Time (ms)")
    plt.ylabel("Frequency")
    plt.legend(['Mean', 'Median', 'Response Times'])
    plt.savefig(f"{title.replace(' ', '_').lower()}_performance.png")
    plt.close()
