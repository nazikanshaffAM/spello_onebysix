# import requests
import os
import sys
import time

# Get API credentials from environment variables
API_TOKEN = os.environ.get("PYTHONANYWHERE_API_TOKEN")
USERNAME = os.environ.get("PYTHONANYWHERE_USERNAME", "spello")
APP_DIRECTORY = os.environ.get("APP_DIRECTORY", "/home/spello/spellomine")
# Get the GitHub repository from environment or default to the current repository
GITHUB_REPO = os.environ.get("GITHUB_REPOSITORY", "spello100/your-repo-name")
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

def create_console_and_run_command():
    """Create a console to run git pull and update dependencies"""
    print("Creating console for deployment commands...")
    
    # Enhanced update command with specific focus on project structure
    update_command = (
        f"cd {APP_DIRECTORY} && "
        "echo '=== Current directory contents ===' && ls -la && "
        "if [ -d .git ]; then "
        "    echo '=== Updating existing git repository ===' && "
        "    git fetch --verbose && "
        f"    git checkout {GITHUB_BRANCH} && "
        "    git pull --verbose && "
        "    echo '=== Git repository updated ===' && "
        "else "
        "    echo 'ERROR: No git repository found. Cannot update.' && "
        "    exit 1; "
        "fi && "
        "echo '=== Directory contents after update ===' && ls -la && "
        "# If Backend directory exists, check its contents too\n"
        "if [ -d Backend ]; then\n"
        "    echo '=== Backend directory contents ==='\n"
        "    ls -la Backend\n"
        "fi && "
        "echo '=== Installing dependencies ===' && "
        "if [ -f requirements.txt ]; then "
        "    pip install -r requirements.txt --user "
        "elif [ -f Backend/requirements.txt ]; then "
        "    pip install -r Backend/requirements.txt --user "
        "else "
        "    echo 'WARNING: No requirements.txt found' "
        "fi && "
        f"echo '=== Touching WSGI file at {WSGI_FILE} ===' && "
        f"touch {WSGI_FILE} && "
        "echo '=== All deployment steps completed successfully ==='"
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

def check_console_output(console_id, max_wait=300):
    """Check console output to see if commands completed successfully"""
    print(f"Checking console output (ID: {console_id})...")
    
    console_url = f"{CONSOLES_URL}{console_id}/get_latest_output/"
    start_time = time.time()
    success_marker = "=== All deployment steps completed successfully ==="
    error_marker = "ERROR:"
    
    while time.time() - start_time < max_wait:
        try:
            response = requests.get(console_url, headers=headers)
            response.raise_for_status()
            output = response.json()["output"]
            
            # Check for success message
            if success_marker in output:
                print("Deployment commands completed successfully!")
                return True
            
            # Check for error message
            if error_marker in output:
                print(f"Error detected in console output: {output}")
                return False
                
            # Continue waiting
            print("Waiting for deployment commands to complete...")
            time.sleep(10)
            
        except requests.exceptions.RequestException as e:
            print(f"Error checking console output: {str(e)}")
            time.sleep(10)
    
    print(f"Timed out waiting for deployment commands to complete after {max_wait} seconds")
    return False

def reload_webapp():
    """Reload the web application"""
    print("Reloading web application...")
    
    try:
        response = requests.post(f"{WEBAPP_URL}/reload/", headers=headers)
        response.raise_for_status()
        print("Web app reload initiated successfully!")
        
        # Wait for the reload to complete
        print("Waiting for webapp reload to complete...")
        time.sleep(60)  # Give more time for the reload to fully take effect
        
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
    print(f"WSGI file: {WSGI_FILE}")
    
    # Step 1: Create a console and run update commands
    console_id = create_console_and_run_command()
    if not console_id:
        print("Deployment failed: Could not create console")
        return False
    
    # Step 2: Wait for commands to complete with verification
    if not check_console_output(console_id):
        print("Deployment failed: Commands did not complete successfully")
        return False
    
    # Step 3: Reload the web application
    if not reload_webapp():
        print("Deployment failed: Could not reload web app")
        return False
    
    print("Deployment completed successfully!")
    return True

if __name__ == "__main__":
    success = deploy()
    sys.exit(0 if success else 1)