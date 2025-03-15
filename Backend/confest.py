import os
import sys
import pytest
import mongomock
from unittest.mock import patch

# This file helps with test setup and fixture configuration

def pytest_configure(config):
    """
    Allows plugins and conftest files to perform initial configuration.
    This hook is called for every plugin and conftest file after command line options have been parsed.
    """
    # Add the current directory to sys.path to ensure app can be imported
    sys.path.append(os.path.dirname(os.path.abspath(__file__)))