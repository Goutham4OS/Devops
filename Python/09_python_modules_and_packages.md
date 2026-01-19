# Python Modules & Packages: Complete Guide

Understanding how to create, organize, and use Python modules and packages.

---

## 📦 PART 1: What is a Module?

A **module** is simply a `.py` file containing Python code (functions, classes, variables).

```python
# mymodule.py - This is a module!
def greet(name):
    return f"Hello, {name}!"

VERSION = "1.0.0"

class Calculator:
    def add(self, a, b):
        return a + b
```

**Using the module:**
```python
# main.py
import mymodule

print(mymodule.greet("DevOps"))  # Hello, DevOps!
print(mymodule.VERSION)          # 1.0.0

calc = mymodule.Calculator()
print(calc.add(5, 3))            # 8
```

---

## 📦 PART 2: What is a Package?

A **package** is a folder containing multiple modules, with a special `__init__.py` file.

### Package Structure:
```
mypackage/
├── __init__.py         # Makes folder a package (can be empty)
├── core.py             # Module 1
├── utils.py            # Module 2
├── helpers/            # Sub-package
│   ├── __init__.py
│   └── strings.py
```

---

## 📦 PART 3: Understanding `__init__.py`

### 3.1 What is `__init__.py`?

- **Makes a directory a Python package**
- **Runs when package is imported**
- **Controls what gets exported**
- Can be **empty** (just marks folder as package)
- Can contain **initialization code**

### 3.2 Empty `__init__.py`
```python
# mypackage/__init__.py
# Empty file - just makes mypackage a package
```

```python
# Usage
from mypackage import core
from mypackage.utils import some_function
```

### 3.3 `__init__.py` with Imports (Recommended)
```python
# mypackage/__init__.py
"""
MyPackage - A DevOps automation toolkit
"""

# Package metadata
__version__ = "1.0.0"
__author__ = "DevOps Team"

# Import key items to make them available at package level
from .core import Server, Database
from .utils import format_size, parse_config
from .helpers.strings import slugify

# Define what gets exported with "from mypackage import *"
__all__ = [
    'Server',
    'Database', 
    'format_size',
    'parse_config',
    'slugify'
]
```

**Now users can do:**
```python
# Clean imports!
from mypackage import Server, format_size

# Instead of:
from mypackage.core import Server
from mypackage.utils import format_size
```

### 3.4 `__init__.py` with Initialization
```python
# mypackage/__init__.py
import logging
import os

# Setup logging when package is imported
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load configuration on import
CONFIG_PATH = os.getenv('MYPACKAGE_CONFIG', 'config.yaml')

def _load_config():
    """Private function to load config"""
    if os.path.exists(CONFIG_PATH):
        import yaml
        with open(CONFIG_PATH) as f:
            return yaml.safe_load(f)
    return {}

# Run on import
config = _load_config()
logger.info(f"Package initialized with config: {CONFIG_PATH}")

# Public exports
from .core import Server
from .utils import format_size
```

---

## 📦 PART 4: Special Dunder Variables

### 4.1 `__name__`
```python
# mymodule.py
print(f"__name__ = {__name__}")

def main():
    print("Running main function")

# This block runs ONLY if file is executed directly
if __name__ == "__main__":
    main()
```

**Results:**
```bash
# When imported:
>>> import mymodule
__name__ = mymodule

# When run directly:
$ python mymodule.py
__name__ = __main__
Running main function
```

### 4.2 `__file__`
```python
# Get path of current module
import os

print(__file__)  # /path/to/mymodule.py

# Get directory containing the module
module_dir = os.path.dirname(os.path.abspath(__file__))
print(module_dir)  # /path/to

# Load file relative to module
config_path = os.path.join(module_dir, 'config.yaml')
```

### 4.3 `__all__`
```python
# mymodule.py

# Controls "from mymodule import *"
__all__ = ['public_function', 'PublicClass']

def public_function():
    pass

def _private_function():  # Convention: prefix with _
    pass

class PublicClass:
    pass

class _InternalClass:  # Not exported
    pass
```

### 4.4 `__version__`
```python
# mypackage/__init__.py
__version__ = "1.2.3"

# Access from outside:
import mypackage
print(mypackage.__version__)  # 1.2.3
```

### 4.5 `__doc__`
```python
"""This is the module docstring."""

def my_function():
    """This is the function docstring."""
    pass

print(__doc__)  # This is the module docstring.
print(my_function.__doc__)  # This is the function docstring.
```

---

## 📦 PART 5: Import Patterns

### 5.1 Different Import Styles
```python
# Import entire module
import os
os.path.exists('file.txt')

# Import specific items
from os import path, getcwd
path.exists('file.txt')

# Import with alias
import pandas as pd
import numpy as np

# Import everything (not recommended)
from os import *

# Relative imports (within package)
from . import sibling_module       # Same directory
from .sibling import function      # From sibling module
from .. import parent_module       # Parent package
from ..utils import helper         # From parent's utils
```

### 5.2 Conditional Imports
```python
# Handle optional dependencies
try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False

def load_config(path):
    if path.endswith('.yaml'):
        if not HAS_YAML:
            raise ImportError("PyYAML required: pip install pyyaml")
        with open(path) as f:
            return yaml.safe_load(f)
```

### 5.3 Lazy Imports (Performance)
```python
# Don't import heavy modules at top
# Import when needed

def process_data(data):
    import pandas as pd  # Only imported when function called
    df = pd.DataFrame(data)
    return df.describe()
```

---

## 📦 PART 6: Complete Package Example

### Project Structure:
```
devops_toolkit/
├── __init__.py
├── servers/
│   ├── __init__.py
│   ├── manager.py
│   └── models.py
├── storage/
│   ├── __init__.py
│   ├── blob.py
│   └── disk.py
├── utils/
│   ├── __init__.py
│   ├── strings.py
│   ├── files.py
│   └── network.py
└── config.py
```

### Root `__init__.py`:
```python
# devops_toolkit/__init__.py
"""
DevOps Toolkit - Infrastructure automation library
"""

__version__ = "2.0.0"
__author__ = "DevOps Team"

# Expose main classes at package level
from .servers import ServerManager, Server
from .storage import BlobClient, DiskManager
from .config import Config

# What "from devops_toolkit import *" exports
__all__ = [
    'ServerManager',
    'Server', 
    'BlobClient',
    'DiskManager',
    'Config'
]

# Package-level initialization
import logging
logging.getLogger(__name__).addHandler(logging.NullHandler())
```

### Sub-package `__init__.py`:
```python
# devops_toolkit/servers/__init__.py
"""Server management module"""

from .manager import ServerManager
from .models import Server, ServerStatus

__all__ = ['ServerManager', 'Server', 'ServerStatus']
```

### Module Example:
```python
# devops_toolkit/servers/models.py
from enum import Enum
from dataclasses import dataclass
from datetime import datetime

class ServerStatus(Enum):
    RUNNING = "running"
    STOPPED = "stopped"
    ERROR = "error"

@dataclass
class Server:
    id: int
    name: str
    ip: str
    status: ServerStatus = ServerStatus.STOPPED
    created_at: datetime = None
    
    def __post_init__(self):
        if self.created_at is None:
            self.created_at = datetime.now()
    
    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'ip': self.ip,
            'status': self.status.value,
            'created_at': self.created_at.isoformat()
        }
```

### Usage:
```python
# After package is installed or in PYTHONPATH
from devops_toolkit import ServerManager, Server
from devops_toolkit.servers import ServerStatus
from devops_toolkit.storage import DiskManager

# Or import everything
import devops_toolkit as dt
server = dt.Server(id=1, name="web-01", ip="10.0.0.1")
```

---

## 📦 PART 7: Making Package Installable

### 7.1 `setup.py` (Traditional)
```python
# setup.py
from setuptools import setup, find_packages

setup(
    name="devops-toolkit",
    version="2.0.0",
    author="DevOps Team",
    description="Infrastructure automation library",
    packages=find_packages(),
    install_requires=[
        'requests>=2.25.0',
        'pyyaml>=5.4',
    ],
    python_requires='>=3.8',
    entry_points={
        'console_scripts': [
            'devops-cli=devops_toolkit.cli:main',
        ],
    },
)
```

### 7.2 `pyproject.toml` (Modern - Recommended)
```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "devops-toolkit"
version = "2.0.0"
description = "Infrastructure automation library"
readme = "README.md"
requires-python = ">=3.8"
license = {text = "MIT"}
authors = [
    {name = "DevOps Team", email = "devops@example.com"}
]
dependencies = [
    "requests>=2.25.0",
    "pyyaml>=5.4",
]

[project.optional-dependencies]
dev = ["pytest", "black", "mypy"]
azure = ["azure-identity", "azure-mgmt-compute"]

[project.scripts]
devops-cli = "devops_toolkit.cli:main"
```

### 7.3 Installing Your Package
```bash
# Install in development mode (editable)
pip install -e .

# Install normally
pip install .

# Install with optional dependencies
pip install -e ".[dev,azure]"

# Build distribution
pip install build
python -m build

# Upload to PyPI
pip install twine
twine upload dist/*
```

---

## 📦 PART 8: Module Discovery & Introspection

```python
import mypackage

# See all attributes
print(dir(mypackage))

# Get module documentation
print(mypackage.__doc__)

# Get file location
print(mypackage.__file__)

# List submodules
import pkgutil
for importer, modname, ispkg in pkgutil.walk_packages(mypackage.__path__):
    print(f"{'Package' if ispkg else 'Module'}: {modname}")

# Inspect module contents
import inspect
for name, obj in inspect.getmembers(mypackage):
    if inspect.isfunction(obj):
        print(f"Function: {name}")
    elif inspect.isclass(obj):
        print(f"Class: {name}")
```

---

## 🎯 SUMMARY

| Item | Purpose |
|------|---------|
| Module | Single `.py` file |
| Package | Folder with `__init__.py` |
| `__init__.py` | Makes folder a package, controls exports |
| `__name__` | Module name, `"__main__"` when run directly |
| `__file__` | Path to module file |
| `__all__` | Controls `from x import *` |
| `__version__` | Package version string |
| Relative imports | `from . import` within packages |
| `setup.py` / `pyproject.toml` | Make package installable |

---

## ✅ BEST PRACTICES

1. **Keep `__init__.py` minimal** - only import what users need
2. **Use `__all__`** to define public API
3. **Prefix private items with `_`** - `_internal_function`
4. **Use relative imports** inside packages
5. **Add docstrings** to modules and packages
6. **Version your packages** with `__version__`
7. **Use `if __name__ == "__main__"`** for scripts
8. **Organize by feature**, not by type
9. **Keep packages focused** - one purpose per package
10. **Document dependencies** in requirements.txt or pyproject.toml
