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


# Base URL for your API
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
def test_endpoint(sessions, method, endpoint, payload=None, files=None, params=None, name=None):
    """Test a specific endpoint and measure response time"""
    start_time = time.time()

    if method.upper() == "GET":
        response = sessions.get(f"{BASE_URL}{endpoint}", params=params)
    elif method.upper() == "POST":
        response = sessions.post(f"{BASE_URL}{endpoint}", json=payload, files=files, params=params)
    elif method.upper() == "PUT":
        response = sessions.put(f"{BASE_URL}{endpoint}", json=payload, params=params)
    elif method.upper() == "DELETE":
        response = sessions.delete(f"{BASE_URL}{endpoint}", params=params)
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


def run_full_test_suite():
    """Run a comprehensive test suite on all major endpoints"""
    # Ensure we have a dummy audio file
    create_dummy_audio()

    # Create a session with logged-in user
    session = requests.Session()
    cookies = setup_test_user()
    if cookies:
        session.cookies.update(cookies)
    else:
        print("Failed to set up test user. Aborting tests.")
        return

    # Define test scenarios
    test_scenarios = [
        {
            "name": "Login API",
            "endpoint": "/login",
            "method": "POST",
            "payload": {"email": TEST_USER["email"], "password": TEST_USER["password"]},
            "concurrency": 20,
            "requests": 100
        },
        {
            "name": "Get User Profile",
            "endpoint": "/get_user",
            "method": "GET",
            "params": {"email": TEST_USER["email"]},
            "concurrency": 20,
            "requests": 100
        },
        {
            "name": "Get Target Word",
            "endpoint": "/get-target-word",
            "method": "GET",
            "params": {"sounds": "p,t,k"},
            "concurrency": 20,
            "requests": 100
        },
        {
            "name": "Dashboard Data",
            "endpoint": "/dashboard",
            "method": "GET",
            "concurrency": 20,
            "requests": 100
        }
    ]

    # Additional test for speech-to-text API with audio file
    # Note: This is a special case because it needs file upload
    def test_speech_to_text():
        results = []
        for i in range(50):  # Reduce number for speech API as it's more resource-intensive
            with open(SAMPLE_AUDIO_PATH, 'rb') as audio_file:
                start_time = time.time()
                files = {'audio': audio_file}
                response = session.post(f"{BASE_URL}/speech-to-text", files=files)
                end_time = time.time()

                response_time = (end_time - start_time) * 1000
                status = "SUCCESS" if response.status_code == 200 else "FAIL"

                results.append({
                    "endpoint": "/speech-to-text",
                    "method": "POST",
                    "status_code": response.status_code,
                    "response_time_ms": response_time,
                    "status": status
                })

        return results

    # Run all test scenarios
    all_results = {}

    for scenario in test_scenarios:
        print(f"Running performance test for: {scenario['name']}")
        results = run_load_test(
            endpoint=scenario["endpoint"],
            method=scenario["method"],
            payload=scenario.get("payload"),
            params=scenario.get("params"),
            name=scenario["name"],
            num_requests=scenario["requests"],
            concurrency=scenario["concurrency"]
        )

        analysis = analyze_results(results)
        all_results[scenario["name"]] = {
            "results": results,
            "analysis": analysis
        }

        print(f"Completed {scenario['name']} test:")
        print(f"  Success Rate: {analysis['success_rate']:.2f}%")
        print(f"  Avg Response Time: {analysis['avg_response_time']:.2f} ms")
        print(f"  95th Percentile: {analysis['p95_response_time']:.2f} ms")

        plot_results(results, scenario["name"])

    # Run speech-to-text test separately
    print("Running performance test for: Speech-to-Text API")
    speech_results = test_speech_to_text()
    speech_analysis = analyze_results(speech_results)
    all_results["Speech-to-Text API"] = {
        "results": speech_results,
        "analysis": speech_analysis
    }

    print(f"Completed Speech-to-Text API test:")
    print(f"  Success Rate: {speech_analysis['success_rate']:.2f}%")
    print(f"  Avg Response Time: {speech_analysis['avg_response_time']:.2f} ms")
    print(f"  95th Percentile: {speech_analysis['p95_response_time']:.2f} ms")

    plot_results(speech_results, "Speech-to-Text API")

    # Generate overall performance report
    generate_performance_report(all_results)


def generate_performance_report(all_results):
    """Generate a comprehensive performance report"""
    with open("performance_report.md", "w") as f:
        f.write("# Spello Backend Performance Test Report\n\n")
        f.write(f"Test executed on: {time.strftime('%Y-%m-%d %H:%M:%S')}\n\n")

        f.write("## Summary\n\n")
        f.write("| API Endpoint | Success Rate | Avg Response (ms) | Median (ms) | 95th Percentile (ms) | Max (ms) |\n")
        f.write("|-------------|--------------|-------------------|-------------|----------------------|---------|\n")

        for name, data in all_results.items():
            analysis = data["analysis"]
            f.write(f"| {name} | {analysis['success_rate']:.2f}% | {analysis['avg_response_time']:.2f} | " +
                    f"{analysis['median_response_time']:.2f} | {analysis['p95_response_time']:.2f} | " +
                    f"{analysis['max_response_time']:.2f} |\n")

        f.write("\n## Detailed Results\n\n")

        for name, data in all_results.items():
            analysis = data["analysis"]
            f.write(f"### {name}\n\n")
            f.write(f"- **Total Requests**: {analysis['total_requests']}\n")
            f.write(f"- **Success Rate**: {analysis['success_rate']:.2f}%\n")
            f.write(f"- **Min Response Time**: {analysis['min_response_time']:.2f} ms\n")
            f.write(f"- **Max Response Time**: {analysis['max_response_time']:.2f} ms\n")
            f.write(f"- **Average Response Time**: {analysis['avg_response_time']:.2f} ms\n")
            f.write(f"- **Median Response Time**: {analysis['median_response_time']:.2f} ms\n")
            f.write(f"- **90th Percentile**: {analysis['p90_response_time']:.2f} ms\n")
            f.write(f"- **95th Percentile**: {analysis['p95_response_time']:.2f} ms\n")
            f.write(f"- **99th Percentile**: {analysis['p99_response_time']:.2f} ms\n\n")

            f.write(f"![Response Time Distribution for {name}]({name.replace(' ', '_').lower()}_performance.png)\n\n")

        f.write("## Recommendations\n\n")

        # Automatically identify potential bottlenecks
        bottlenecks = []
        for name, data in all_results.items():
            analysis = data["analysis"]
            if analysis['p95_response_time'] > 1000:  # More than 1 second is slow
                bottlenecks.append((name, analysis['p95_response_time']))

        if bottlenecks:
            f.write("The following endpoints have slow response times (95th percentile > 1000ms):\n\n")
            for endpoint, time_ms in bottlenecks:
                f.write(f"- **{endpoint}**: {time_ms:.2f} ms\n")

            f.write("\nPossible improvement areas:\n\n")
            f.write("1. Implement caching for frequently accessed data\n")
            f.write("2. Optimize database queries\n")
            f.write("3. Consider implementing connection pooling\n")
            f.write("4. Review any heavy processing in these endpoints\n")
        else:
            f.write("All endpoints are performing within acceptable response time thresholds.\n")


# Locust performance testing class (for distributed load testing)
class SpelloUser(HttpUser):
    wait_time = between(1, 3)

    def on_start(self):
        # Log in at the start of the test
        response = self.client.post("/login", json={
            "email": TEST_USER["email"],
            "password": TEST_USER["password"]
        })

        if response.status_code != 200:
            # Try to register if login fails
            self.client.post("/register", json=TEST_USER)
            # Try login again
            self.client.post("/login", json={
                "email": TEST_USER["email"],
                "password": TEST_USER["password"]
            })

    @task(3)
    def get_dashboard(self):
        self.client.get("/dashboard")

    @task(5)
    def get_target_word(self):
        sounds = ["p", "b", "t", "d", "k"]
        selected_sounds = random.sample(sounds, k=random.randint(1, 3))
        self.client.get(f"/get-target-word?sounds={','.join(selected_sounds)}")

    @task(1)
    def get_profile(self):
        self.client.get(f"/get_user?email={TEST_USER['email']}")

    @task(1)
    def update_selected_sounds(self):
        sounds = ["p", "b", "t", "d", "k"]
        selected_sounds = random.sample(sounds, k=random.randint(1, 3))
        self.client.post("/update_selected_sounds",
                         json={"selected_sounds": selected_sounds, "email": TEST_USER["email"]})


if __name__ == "__main__":
    print("Starting Spello Backend Performance Tests...")
    run_full_test_suite()
    print("Performance tests completed. See performance_report.md for results.")