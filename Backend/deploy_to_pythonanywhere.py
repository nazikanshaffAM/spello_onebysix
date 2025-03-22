import requests
import os
import sys
import time

# Get API credentials from environment variables
API_TOKEN = os.environ.get("PYTHONANYWHERE_API_TOKEN")
USERNAME = os.environ.get("PYTHONANYWHERE_USERNAME", "spello")
APP_DIRECTORY = os.environ.get("APP_DIRECTORY", "/home/spello/spellomine")
GITHUB_BRANCH = os.environ.get("GITHUB_REF_NAME", "main")
WSGI_FILE = os.environ.get("WSGI_FILE", "/var/www/spello_pythonanywhere_com_wsgi.py")

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

def run_deployment_commands():
    """Run deployment commands directly instead of checking console output"""
    print("Running deployment commands...")
    
    # Simplified command approach - run multiple smaller commands instead of one big one
    commands = [
        # Check current directory
        f"cd {APP_DIRECTORY} && ls -la",
        
        # Update git repository
        f"cd {APP_DIRECTORY} && git fetch && git checkout {GITHUB_BRANCH} && git pull",
        
        # Install dependencies
        f"cd {APP_DIRECTORY} && pip install -r requirements.txt --user",
        
        # Touch WSGI file to ensure reload
        f"touch {WSGI_FILE}"
    ]
    
    for cmd in commands:
        print(f"Executing: {cmd}")
        try:
            # Create a new console for each command to avoid timeout issues
            data = {
                "executable": "bash",
                "working_directory": f"/home/{USERNAME}",
                "arguments": f"-c '{cmd}'"
            }
            
            response = requests.post(CONSOLES_URL, headers=headers, json=data)
            response.raise_for_status()
            console_id = response.json()["id"]
            print(f"Command started in console ID: {console_id}")
            
            # Give each command some time to complete
            time.sleep(15)
            
        except requests.exceptions.RequestException as e:
            print(f"Warning: Error executing command: {str(e)}")
            if hasattr(e, 'response') and e.response:
                print(f"Response: {e.response.status_code}, {e.response.text}")
    
    # Additional sleep to ensure all commands have completed
    print("Waiting for all commands to complete...")
    time.sleep(30)
    return True

def reload_webapp():
    """Reload the web application"""
    print("Reloading web application...")
    
    try:
        response = requests.post(f"{WEBAPP_URL}/reload/", headers=headers)
        response.raise_for_status()
        print("Web app reload initiated successfully!")
        
        # Wait for the reload to complete
        print("Waiting for webapp reload to complete...")
        time.sleep(60)
        
        return True
    except requests.exceptions.RequestException as e:
        print(f"Failed to reload web app: {str(e)}")
        if hasattr(e, 'response') and e.response:
            print(f"Response: {e.response.status_code}, {e.response.text}")
        return False

def deploy():
    """Main deployment function"""
    print(f"Starting deployment to PythonAnywhere for {USERNAME}...")
    print(f"Target directory: {APP_DIRECTORY}")
    print(f"Branch: {GITHUB_BRANCH}")
    print(f"WSGI file: {WSGI_FILE}")
    
    # Step 1: Run deployment commands
    if not run_deployment_commands():
        print("Deployment failed: Error running commands")
        return False
    
    # Step 2: Reload the web application
    if not reload_webapp():
        print("Deployment failed: Could not reload web app")
        return False
    
    print("Deployment completed successfully!")
    return True

if __name__ == "__main__":
    success = deploy()
    sys.exit(0 if success else 1)