import requests
import os
import sys
import time

# Get API credentials from environment variables
API_TOKEN = os.environ.get("PYTHONANYWHERE_API_TOKEN")
USERNAME = os.environ.get("PYTHONANYWHERE_USERNAME")
APP_DIRECTORY = os.environ.get("APP_DIRECTORY", f"/home/{USERNAME}/mysite")

if not API_TOKEN or not USERNAME:
    print("Error: Missing API token or username environment variables.")
    print("Please set PYTHONANYWHERE_API_TOKEN and PYTHONANYWHERE_USERNAME in your GitHub secrets.")
    sys.exit(1)

# API endpoints
API_BASE_URL = f"https://www.pythonanywhere.com/api/v0/user/{USERNAME}"
CONSOLES_URL = f"{API_BASE_URL}/consoles/"
WEBAPP_URL = f"{API_BASE_URL}/webapps/{USERNAME}.pythonanywhere.com"

# Request headers
headers = {"Authorization": f"Token {API_TOKEN}"}

def create_console_and_run_command():
    """Create a console to run git pull and update dependencies"""
    print("Creating console for deployment commands...")
    
    # Command to update the code and dependencies
    update_command = (
        f"cd {APP_DIRECTORY} && "
        "git pull origin main && "
        "pip install -r requirements.txt --user"
    )
    
    data = {
        "executable": "bash",
        "working_directory": f"/home/{USERNAME}",
        "arguments": f"-c '{update_command}'"
    }
    
    response = requests.post(CONSOLES_URL, headers=headers, json=data)
    
    if response.status_code == 201:
        console_id = response.json()["id"]
        print(f"Console created with ID: {console_id}")
        return console_id
    else:
        print(f"Failed to create console: {response.status_code}, {response.text}")
        return None

def reload_webapp():
    """Reload the web application"""
    print("Reloading web application...")
    
    response = requests.post(f"{WEBAPP_URL}/reload/", headers=headers)
    
    if response.status_code == 200:
        print("Web app reloaded successfully!")
        return True
    else:
        print(f"Failed to reload web app: {response.status_code}, {response.text}")
        return False

def deploy():
    """Main deployment function"""
    print(f"Starting deployment to PythonAnywhere for {USERNAME}...")
    print(f"Target directory: {APP_DIRECTORY}")
    
    # Step 1: Create a console and run update commands
    console_id = create_console_and_run_command()
    if not console_id:
        print("Deployment failed: Could not create console")
        return False
    
    # Give some time for git pull and dependency installation to complete
    print("Waiting for update commands to complete...")
    time.sleep(15)  # Increased wait time for dependency installation
    
    # Step 2: Reload the web application
    if not reload_webapp():
        print("Deployment failed: Could not reload web app")
        return False
    
    print("Deployment completed successfully!")
    return True

if __name__ == "__main__":
    success = deploy()
    sys.exit(0 if success else 1)