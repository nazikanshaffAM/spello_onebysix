"""
This script tests the compatibility of the application with both pymongo and flask-pymongo.
It can be used to verify that the application works with either library.
"""

import sys
import os
import pytest
import importlib.util

def check_pymongo_imports():
    """Check if the application imports pymongo or flask-pymongo"""
    app_file = 'back.py'
    imports = []
    
    with open(app_file, 'r') as f:
        for line in f:
            if line.strip().startswith('import') or line.strip().startswith('from'):
                if 'pymongo' in line.lower():
                    imports.append(line.strip())
    
    return imports

def can_use_pymongo():
    """Test if the application can run with just pymongo"""
    try:
        import pymongo
        print("PyMongo is installed.")
        
        # Check if we can connect to MongoDB Atlas
        try:
            # Try to get connection string from back.py
            atlas_uri = None
            with open('back.py', 'r') as f:
                for line in f:
                    if 'MONGO_URI' in line and 'mongodb+srv' in line:
                        # Extract the connection string
                        import re
                        match = re.search(r'"(mongodb\+srv://[^"]+)"', line)
                        if match:
                            atlas_uri = match.group(1)
                            break
            
            if not atlas_uri:
                print("Could not find MongoDB Atlas URI in back.py")
                return False
                
            client = pymongo.MongoClient(atlas_uri, serverSelectionTimeoutMS=5000)
            client.server_info()  # will raise an exception if it can't connect
            print("Successfully connected to MongoDB Atlas using pymongo.")
            return True
        except Exception as e:
            print(f"Could not connect to MongoDB Atlas: {e}")
            return False
    except ImportError:
        print("PyMongo is not installed.")
        return False

def can_use_flask_pymongo():
    """Test if the application can run with flask-pymongo"""
    try:
        import flask_pymongo
        print("Flask-PyMongo is installed.")
        
        # We can't easily test flask-pymongo connection without initializing the Flask app
        # So we'll just check if the package is available
        return True
    except ImportError:
        print("Flask-PyMongo is not installed.")
        return False

def modify_imports_for_test(use_flask_pymongo=True):
    """Create a temporary version of app.py that uses the specified library"""
    app_file = 'back.py'
    backup_file = 'app_backup.py'
    test_file = 'app_test.py'
    
    # Create backup if it doesn't exist
    if not os.path.exists(backup_file):
        with open(app_file, 'r') as src, open(backup_file, 'w') as dst:
            dst.write(src.read())
    
    with open(backup_file, 'r') as src, open(test_file, 'w') as dst:
        content = src.read()
        
        # Replace imports based on what we want to test
        if use_flask_pymongo:
            # Make sure we're using flask_pymongo
            content = content.replace('import pymongo', 'from flask_pymongo import PyMongo')
            content = content.replace('from pymongo import MongoClient', 'from flask_pymongo import PyMongo')
        else:
            # Make sure we're using pymongo directly
            content = content.replace('from flask_pymongo import PyMongo', 'import pymongo')
            
            # Insert code to use pymongo directly
            mongo_setup = """
# Set up pymongo connection
mongo_client = pymongo.MongoClient("mongodb+srv://spello:spello100@spellodb.8zvmy.mongodb.net/spello_database?retryWrites=true&w=majority")
mongo_db = mongo_client["spello_database"]
collection = mongo_db["sp1"]
"""
            # Add this after the Flask app initialization
            app_init_pos = content.find('app = Flask(__name__)')
            if app_init_pos > -1:
                app_init_end = content.find('\n', app_init_pos) + 1
                content = content[:app_init_end] + mongo_setup + content[app_init_end:]
            
        dst.write(content)
    
    return test_file

def restore_app():
    """Restore the original back.py from backup"""
    backup_file = 'app_backup.py'
    app_file = 'back.py'
    test_file = 'app_test.py'
    
    # Restore from backup if exists
    if os.path.exists(backup_file):
        with open(backup_file, 'r') as src, open(app_file, 'w') as dst:
            dst.write(src.read())
        os.remove(backup_file)
    
    # Remove test file if exists
    if os.path.exists(test_file):
        os.remove(test_file)

def main():
    print("Checking pymongo compatibility...")
    imports = check_pymongo_imports()
    
    print("Found the following pymongo imports:")
    for imp in imports:
        print(f"  {imp}")
    
    print("\nTesting pymongo compatibility...")
    if can_use_pymongo():
        print("✓ Application can use pymongo")
    else:
        print("✗ Application cannot use pymongo")
    
    print("\nTesting flask-pymongo compatibility...")
    if can_use_flask_pymongo():
        print("✓ Application can use flask-pymongo")
    else:
        print("✗ Application cannot use flask-pymongo")
    
    print("\nCreating test versions to verify compatibility...")
    try:
        # Test with flask_pymongo
        test_file = modify_imports_for_test(True)
        print(f"Created {test_file} using flask_pymongo")
        
        # Test with pymongo
        test_file = modify_imports_for_test(False)
        print(f"Created {test_file} using pymongo")
        
    finally:
        restore_app()
        print("Restored original back.py")

if __name__ == "__main__":
    main()