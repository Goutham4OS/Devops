# 🔌 Understanding Python Imports - The Absolute Basics

## What is `import`?

Think of `import` like **borrowing tools** from a toolbox instead of building everything yourself.

### Real-World Analogy

```
🏠 Building a House:
   ❌ BAD: Make your own hammer, nails, saw from scratch
   ✅ GOOD: Use tools from the hardware store (import them!)

💻 Writing Python Code:
   ❌ BAD: Write code to read JSON files from scratch (hundreds of lines)
   ✅ GOOD: import json  (someone already wrote it for you!)
```

---

## Why Do We Use Import?

### 1. **Don't Reinvent the Wheel**

```python
# WITHOUT import (you'd have to write this yourself!)
def add_numbers(a, b):
    return a + b

def calculate_square_root(number):
    # Write complex math algorithm...
    pass

# WITH import (someone already wrote it!)
import math
result = math.sqrt(16)  # Just use it!
```

### 2. **Keep Code Organized**

```python
# Instead of one giant 10,000 line file:
# my_huge_file.py (10,000 lines) 😱

# Better: Split into logical pieces
import database_functions
import api_functions
import email_functions
```

---

## How Import Works - Step by Step

### Scenario: You want to work with dates

```python
# Step 1: Import the datetime module
import datetime

# Step 2: Use it!
today = datetime.date.today()
print(today)  # Output: 2026-01-07
```

### What Just Happened?

```
┌─────────────────────────────────────────────┐
│  1. You write: import datetime              │
│                                             │
│  2. Python searches for "datetime" module   │
│     (it's built into Python)                │
│                                             │
│  3. Python loads the code from that module  │
│                                             │
│  4. Now you can use: datetime.date.today()  │
└─────────────────────────────────────────────┘
```

---

## Types of Imports

### 1. **Import Entire Module**

```python
import os

# Use it with module name prefix
current_dir = os.getcwd()
```

**When to use**: When you need multiple things from a module

---

### 2. **Import Specific Function**

```python
from os import getcwd

# Use directly without prefix
current_dir = getcwd()
```

**When to use**: When you only need one or two specific things

---

### 3. **Import with Alias (Nickname)**

```python
import datetime as dt

# Use the shorter name
today = dt.date.today()
```

**When to use**: When module names are long (common in data science)

```python
import pandas as pd  # Everyone does this!
import numpy as np   # Standard practice
```

---

### 4. **Import Everything** (⚠️ Usually Avoid This)

```python
from os import *

# Can now use everything without prefix
current_dir = getcwd()
```

**Why avoid?**: 
- You don't know what you imported
- Can overwrite your own functions
- Makes code hard to understand

---

## Common Python Modules You'll Use

### Built-in Modules (Come with Python)

| Module | Purpose | Example Use in DevOps |
|--------|---------|----------------------|
| `os` | Operating system operations | Navigate folders, check if files exist |
| `sys` | System-specific parameters | Get command-line arguments, exit program |
| `json` | Work with JSON data | Parse API responses, config files |
| `datetime` | Date and time | Timestamps in logs, schedule tasks |
| `subprocess` | Run shell commands | Execute bash/PowerShell from Python |
| `pathlib` | File paths | Cross-platform path handling |
| `logging` | Log messages | Track what your scripts are doing |

### External Modules (Need to Install)

```bash
# Install with pip
pip install requests
pip install boto3
```

| Module | Purpose | Example Use in DevOps |
|--------|---------|----------------------|
| `requests` | Make HTTP requests | Call REST APIs |
| `boto3` | AWS SDK | Manage AWS resources |
| `paramiko` | SSH connections | Connect to servers |
| `docker` | Docker SDK | Manage containers |

---

## Practical Examples

### Example 1: Working with Files

```python
# Import the os module
import os

# Check if a config file exists
config_exists = os.path.exists('/etc/app/config.yaml')

if config_exists:
    print("Config file found!")
else:
    print("Config file missing!")
```

---

### Example 2: Making API Calls

```python
# Import requests (external module)
import requests

# Get data from an API
response = requests.get('https://api.github.com')
print(response.status_code)  # 200 means success
```

---

### Example 3: Running Shell Commands

```python
# Import subprocess
import subprocess

# Run a command
result = subprocess.run(['ls', '-l'], capture_output=True, text=True)
print(result.stdout)
```

---

## Import Errors - What They Mean

### Error 1: Module Not Found

```python
import requests
# ModuleNotFoundError: No module named 'requests'
```

**Fix**: Install it!
```bash
pip install requests
```

---

### Error 2: Can't Find Function

```python
import os
os.get_current_directory()  # Wrong name!
# AttributeError: module 'os' has no attribute 'get_current_directory'
```

**Fix**: Use correct name
```python
import os
os.getcwd()  # Correct!
```

---

## Where Do Imports Come From?

```
Python searches in this order:

1. Current directory (your project folder)
   ├── my_script.py
   └── my_module.py  ← Can import this!

2. Python's standard library
   └── (Built-in modules like os, sys, json)

3. Site-packages (installed via pip)
   └── (External libraries like requests, boto3)
```

---

## Practice Exercise

Try this in a Python file:

```python
# Import multiple modules
import os
import sys
from datetime import datetime

# Use them
print("Current directory:", os.getcwd())
print("Python version:", sys.version)
print("Current time:", datetime.now())
```

**Challenge**: What does each line do? Why do we import these modules?

---

## Key Takeaways

✅ **Import = Use pre-written code**  
✅ **Built-in modules are already installed**  
✅ **External modules need `pip install`**  
✅ **Use meaningful aliases for long names**  
✅ **Import only what you need**

---

## Next Steps

Now that you understand imports, let's learn about:
1. **Variables and Data Types** → See [02_variables_and_types.md](02_variables_and_types.md)




