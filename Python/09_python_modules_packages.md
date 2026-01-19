# Python Modules & Packages: Complete Guide

Understanding how to create, organize, and distribute Python modules for DevOps automation.

---

## 📦 PART 1: What is a Module?

### 1.1 Module Basics

A **module** is simply a `.py` file containing Python code (functions, classes, variables).

```python
# my_module.py (This IS a module!)
def greet(name):
    return f"Hello, {name}!"

PI = 3.14159
VERSION = "1.0.0"
```

```python
# main.py (Using the module)
import my_module

print(my_module.greet("DevOps"))  # Hello, DevOps!
print(my_module.PI)               # 3.14159
```

### 1.2 Import Methods

```python
# Method 1: Import entire module
import my_module
my_module.greet("World")

# Method 2: Import with alias
import my_module as mm
mm.greet("World")

# Method 3: Import specific items
from my_module import greet, PI
greet("World")  # No prefix needed

# Method 4: Import all (NOT recommended)
from my_module import *
greet("World")

# Method 5: Import from subpackage
from utils.helpers import format_date
```

---

## 📦 PART 2: What is `__init__.py`?

### 2.1 Purpose of `__init__.py`

`__init__.py` marks a directory as a **Python package** and controls what gets exported.

```
my_package/
    __init__.py      ← Makes this a package
    core.py
    utils.py
    helpers.py
```

### 2.2 Empty `__init__.py`

```python
# my_package/__init__.py (Empty is valid!)
# Just makes the directory a package
```

```python
# Usage
from my_package import core
from my_package.utils import helper_function
```

### 2.3 `__init__.py` with Exports

```python
# my_package/__init__.py
"""My Package - DevOps Utilities"""

# Package metadata
__version__ = "1.0.0"
__author__ = "DevOps Team"

# Import from submodules to expose at package level
from .core import Server, Database
from .utils import format_bytes, parse_config
from .helpers import retry, timeout

# What gets exported with "from my_package import *"
__all__ = [
    'Server',
    'Database',
    'format_bytes',
    'parse_config',
    'retry',
    'timeout',
    '__version__'
]
```

```python
# Now you can do:
from my_package import Server, format_bytes
# Instead of:
from my_package.core import Server
from my_package.utils import format_bytes
```

### 2.4 Real-World Example: DevOps Package

```
devops_toolkit/
    __init__.py
    servers/
        __init__.py
        vm.py
        container.py
    deployments/
        __init__.py
        deploy.py
        rollback.py
    monitoring/
        __init__.py
        metrics.py
        alerts.py
    utils/
        __init__.py
        config.py
        logging.py
```

**devops_toolkit/__init__.py:**
```python
"""DevOps Toolkit - Infrastructure Automation"""

__version__ = "2.0.0"

# Expose main classes at package level
from .servers.vm import VirtualMachine
from .servers.container import Container
from .deployments.deploy import Deployer
from .monitoring.metrics import MetricsCollector

__all__ = [
    'VirtualMachine',
    'Container', 
    'Deployer',
    'MetricsCollector'
]
```

**devops_toolkit/servers/__init__.py:**
```python
"""Server management modules"""

from .vm import VirtualMachine, VMConfig
from .container import Container, ContainerConfig

__all__ = ['VirtualMachine', 'VMConfig', 'Container', 'ContainerConfig']
```

---

## 📦 PART 3: Special Module Attributes

### 3.1 `__name__` - Module Name

```python
# my_script.py
print(__name__)  # Prints: __main__ (when run directly)
                 # Prints: my_script (when imported)

# Common pattern for executable modules
if __name__ == "__main__":
    # This only runs when executed directly
    # Not when imported
    main()
```

### 3.2 `__file__` - Module File Path

```python
import os

# Get the module's file path
print(__file__)  # /path/to/my_module.py

# Get the directory containing the module
module_dir = os.path.dirname(os.path.abspath(__file__))

# Load config file relative to module
config_path = os.path.join(module_dir, 'config.yaml')
```

### 3.3 `__all__` - Export Control

```python
# utils.py
__all__ = ['public_function', 'PublicClass']

def public_function():
    """This IS exported with import *"""
    pass

def _private_function():
    """Underscore prefix = private convention"""
    pass

class PublicClass:
    """This IS exported"""
    pass

class _InternalClass:
    """This is NOT exported"""
    pass
```

### 3.4 `__doc__` - Module Documentation

```python
"""
DevOps Utilities Module

This module provides helper functions for server management.

Usage:
    from devops_utils import start_server, stop_server
"""

# Access docstring
print(__doc__)
```

### 3.5 `__version__` - Version Info

```python
# __init__.py
__version__ = "1.2.3"
__version_info__ = (1, 2, 3)

# Check version
import my_package
print(my_package.__version__)  # 1.2.3
```

---

## 📦 PART 4: Module Search Path

### 4.1 How Python Finds Modules

Python searches in this order:
1. Current directory
2. PYTHONPATH environment variable
3. Standard library
4. Site-packages (pip installed)

```python
import sys

# View search path
for path in sys.path:
    print(path)

# Add custom path at runtime
sys.path.insert(0, '/custom/module/path')

# Now you can import from that path
import custom_module
```

### 4.2 Relative vs Absolute Imports

```python
# Absolute import (recommended)
from devops_toolkit.servers.vm import VirtualMachine

# Relative import (within same package)
from .vm import VirtualMachine        # Same directory
from ..utils import format_bytes      # Parent directory
from ...core import main_function     # Grandparent
```

---

## 📦 PART 5: Creating a Distributable Package

### 5.1 Package Structure

```
my_devops_package/
    ├── README.md
    ├── LICENSE
    ├── setup.py                 # Or pyproject.toml
    ├── requirements.txt
    ├── my_devops_package/       # Source code
    │   ├── __init__.py
    │   ├── core.py
    │   ├── utils.py
    │   └── cli.py
    ├── tests/
    │   ├── __init__.py
    │   ├── test_core.py
    │   └── test_utils.py
    └── docs/
        └── README.md
```

### 5.2 setup.py (Traditional)

```python
from setuptools import setup, find_packages

setup(
    name="my-devops-package",
    version="1.0.0",
    author="Your Name",
    author_email="you@example.com",
    description="DevOps automation utilities",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/you/my-devops-package",
    packages=find_packages(),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.8",
    install_requires=[
        "requests>=2.25.0",
        "pyyaml>=5.4",
        "azure-identity>=1.0.0",
    ],
    entry_points={
        'console_scripts': [
            'devops-cli=my_devops_package.cli:main',
        ],
    },
)
```

### 5.3 pyproject.toml (Modern - Recommended)

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-devops-package"
version = "1.0.0"
description = "DevOps automation utilities"
readme = "README.md"
license = {text = "MIT"}
requires-python = ">=3.8"
authors = [
    {name = "Your Name", email = "you@example.com"}
]
classifiers = [
    "Programming Language :: Python :: 3",
    "License :: OSI Approved :: MIT License",
]
dependencies = [
    "requests>=2.25.0",
    "pyyaml>=5.4",
    "azure-identity>=1.0.0",
]

[project.optional-dependencies]
dev = ["pytest", "black", "flake8"]

[project.scripts]
devops-cli = "my_devops_package.cli:main"

[project.urls]
Homepage = "https://github.com/you/my-devops-package"
Documentation = "https://my-devops-package.readthedocs.io"
```

### 5.4 Install & Distribute

```bash
# Install locally in development mode
pip install -e .

# Build package
pip install build
python -m build

# Upload to PyPI
pip install twine
twine upload dist/*

# Install from PyPI
pip install my-devops-package
```

---

## 📦 PART 6: Best Practices

### 6.1 Module Organization

```python
# Good: One module = one responsibility
servers/
    vm.py           # VirtualMachine class only
    container.py    # Container class only
    kubernetes.py   # Kubernetes operations only

# Bad: Everything in one file
infrastructure.py   # 2000 lines of mixed code
```

### 6.2 Import Order (PEP 8)

```python
# 1. Standard library imports
import os
import sys
import json
from datetime import datetime

# 2. Third-party imports
import requests
import yaml
from azure.identity import DefaultAzureCredential

# 3. Local application imports
from .core import Server
from .utils import format_bytes
from ..config import settings
```

### 6.3 Lazy Loading (Performance)

```python
# __init__.py with lazy loading
def __getattr__(name):
    """Lazy load heavy modules only when needed"""
    if name == "HeavyClass":
        from .heavy_module import HeavyClass
        return HeavyClass
    raise AttributeError(f"module has no attribute '{name}'")
```

### 6.4 Type Hints for Modules

```python
# utils.py
from typing import List, Dict, Optional, Union

def process_servers(
    servers: List[str],
    config: Optional[Dict[str, str]] = None
) -> Dict[str, bool]:
    """Process list of servers and return status."""
    results: Dict[str, bool] = {}
    for server in servers:
        results[server] = ping(server)
    return results
```

---

## 📦 SUMMARY

| Concept | Purpose |
|---------|---------|
| `module.py` | Single Python file with code |
| `__init__.py` | Makes directory a package, controls exports |
| `__name__` | Module name (`__main__` when run directly) |
| `__file__` | Path to the module file |
| `__all__` | Controls `from module import *` |
| `__version__` | Package version string |
| `setup.py` | Package installation configuration |
| `pyproject.toml` | Modern package configuration |

**Key Takeaways:**
- Every `.py` file is a module
- `__init__.py` creates packages (can be empty)
- Use `__all__` to control public API
- Use `if __name__ == "__main__":` for executable scripts
- Prefer absolute imports over relative
- Use `pyproject.toml` for new projects

---
