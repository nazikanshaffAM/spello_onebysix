import requests
import os
import sys
import time

# Get API credentials from environment variables
API_TOKEN = os.environ.get("PYTHONANYWHERE_API_TOKEN")
USERNAME = os.environ.get("PYTHONANYWHERE_USERNAME")
APP_DIRECTORY = os.environ.get("APP_DIRECTORY", f"/home/{USERNAME}/mysite")
# Get the GitHub repository from environment or default to the current repository
GITHUB_REPO = os.environ.get("GITHUB_REPOSITORY", "spello100/your-repo-name")
GITHUB_BRANCH = os.environ.get("GITHUB_REF_NAME", "main")

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
    
    # Simplified git command sequence focused on pulling updates
    update_command = (
        f"cd {APP_DIRECTORY} && "
        "echo 'Current directory contents:' && ls -la && "
        "if [ -d .git ]; then "
        "    echo 'Updating existing git repository...' && "
        "    git fetch && "  # Fetch all branches
        f"    git checkout {GITHUB_BRANCH} && "  # Make sure we're on the right branch
        "    git pull && "  # Pull changes
        "    echo 'Git repository updated'; "
        "else "
        "    echo 'Warning: No git repository found. Cannot pull updates.' && "
        "    echo 'Please ensure your app directory contains a git repository.'; "
        "fi && "
        "echo 'Directory contents after update:' && ls -la && "
        "echo 'Installing dependencies...' && "
        "pip install -r requirements.txt --user"
    )
    
    data = {
        "executable": "bash",
        "working_directory": f"/home/{USERNAME}",
        "arguments": f"-c '{update_command}'"
    }
    
    try:
        response = requests.post(CONSOLES_URL, headers=headers, json=data)
        response.raise_for_status()
        console_id = response.json()["id"]
        print(f"Console created with ID: {console_id}")
        return console_id
    except requests.exceptions.RequestException as e:
        print(f"Failed to create console: {str(e)}")
        if hasattr(e, 'response') and e.response:
            print(f"Response: {e.response.status_code}, {e.response.text}")
        return None

def reload_webapp():
    """Reload the web application"""
    print("Reloading web application...")
    
    try:
        response = requests.post(f"{WEBAPP_URL}/reload/", headers=headers)
        response.raise_for_status()
        print("Web app reloaded successfully!")
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
    print(f"GitHub repository: {GITHUB_REPO}")
    print(f"Branch: {GITHUB_BRANCH}")
    
    # Step 1: Create a console and run update commands
    console_id = create_console_and_run_command()
    if not console_id:
        print("Deployment failed: Could not create console")
        return False
    
    # Give some time for git operations and dependency installation to complete
    print("Waiting for update commands to complete...")
    time.sleep(30)  # Reduced wait time since pulling is faster than cloning
    
    # Step 2: Reload the web application
    if not reload_webapp():
        print("Deployment failed: Could not reload web app")
        return False
    
    print("Deployment completed successfully!")
    return True

if __name__ == "__main__":
    success = deploy()
    sys.exit(0 if success else 1)