---
title: 'See all available functions and attributes'
---

    # 🔍 Python Modules: JSON & YAML - Essential for DevOps

## What You'll Learn

- How to check what's inside a Python module
- Working with **JSON** (APIs, configs, cloud outputs)
- Working with **YAML** (Kubernetes, Ansible, Docker Compose)
- Real DevOps examples

---

## 🔍 Part 1: Checking Module Attributes

### Why Do You Need This?

When you import a module, you often need to know:
- What functions are available?
- What does this function do?
- What parameters does it accept?

### Method 1: Using `dir()` - List Everything

```python
import json

# See all available functions and attributes
print(dir(json))

# Output: ['JSONDecoder', 'JSONEncoder', 'dump', 'dumps', 'load', 'loads', ...]
```

**What you get**: A list of everything in the module

---

### Method 2: Using `help()` - Get Documentation

```python
import json

# Help for entire module
help(json)

# Help for specific function
help(json.dumps)

# Help for specific method
help(str.split)
```

**What you get**: Detailed documentation with examples

**Tip**: Press `q` to exit help mode

---

### Method 3: Using `inspect` Module

```python
import json
import inspect

# Get all functions in a module
functions = inspect.getmembers(json, inspect.isfunction)
for name, func in functions:
    print(name)
    
# Get function signature
sig = inspect.signature(json.dumps)
print(sig)  # (obj, *, skipkeys=False, ensure_ascii=True, ...)

# Get function docstring
print(inspect.getdoc(json.dumps))
```

**When to use**: When you need programmatic access to module information

---

### Method 4: Check Module Attributes

```python
import json

# Module name
print(json.__name__)  # json

# Module file location
print(json.__file__)  # /usr/lib/python3.x/json/__init__.py

# Module docstring
print(json.__doc__)  # JSON encoder and decoder

# Check if attribute exists
if hasattr(json, 'dumps'):
    print("json.dumps exists!")
```

---

## 📄 Part 2: Working with JSON

### What is JSON?

**JSON** = JavaScript Object Notation
- Human-readable data format
- Used everywhere: APIs, configs, cloud outputs

### Why JSON in DevOps?

```
✅ REST APIs return JSON
✅ Cloud provider outputs (AWS, Azure, GCP)
✅ Configuration files
✅ CI/CD pipeline data
✅ Service communication
```

---

### JSON vs Python Data Types

| Python | JSON |
|--------|------|
| `dict` | `object` |
| `list` | `array` |
| `str` | `string` |
| `int`, `float` | `number` |
| `True` | `true` |
| `False` | `false` |
| `None` | `null` |

---

### JSON Operations - The Big 4

#### 1. `json.dumps()` - Python → JSON String

```python
import json

# Python dictionary
server = {
    "name": "web-01",
    "ip": "192.168.1.10",
    "port": 8080,
    "is_running": True
}

# Convert to JSON string
json_string = json.dumps(server)
print(json_string)
# {"name": "web-01", "ip": "192.168.1.10", "port": 8080, "is_running": true}

# Pretty print (indent)
json_pretty = json.dumps(server, indent=2)
print(json_pretty)
"""
{
  "name": "web-01",
  "ip": "192.168.1.10",
  "port": 8080,
  "is_running": true
}
"""
```

**When to use**: Sending data to APIs, saving to string

---

#### 2. `json.loads()` - JSON String → Python

```python
import json

# JSON string (from API response)
json_response = '{"status": "success", "code": 200}'

# Parse to Python dict
data = json.loads(json_response)

print(data['status'])  # success
print(type(data))  # <class 'dict'>
```

**When to use**: Reading API responses, parsing JSON strings

---

#### 3. `json.dump()` - Python → JSON File

```python
import json

servers = [
    {"name": "web-01", "cpu": 75.5},
    {"name": "web-02", "cpu": 45.2}
]

# Write to file
with open('servers.json', 'w') as f:
    json.dump(servers, f, indent=2)

# File contents:
"""
[
  {
    "name": "web-01",
    "cpu": 75.5
  },
  {
    "name": "web-02",
    "cpu": 45.2
  }
]
"""
```

**When to use**: Saving configuration, exporting data

---

#### 4. `json.load()` - JSON File → Python

```python
import json

# Read from file
with open('servers.json', 'r') as f:
    servers = json.load(f)

print(servers[0]['name'])  # web-01
```

**When to use**: Loading configuration files, reading saved data

---

### Real DevOps Example: API Response Handling

```python
import json
import requests

# Make API call (example)
response = requests.get('https://api.example.com/servers')

# Parse JSON response
data = json.loads(response.text)
# OR: data = response.json()  # requests has built-in JSON parsing

# Access data
for server in data['servers']:
    print(f"{server['name']}: {server['status']}")
    
    # Save unhealthy servers to file
    if server['status'] != 'healthy':
        with open('unhealthy_servers.json', 'w') as f:
            json.dump(server, f, indent=2)
```

---

### Common JSON Parameters

```python
# indent - Pretty printing
json.dumps(data, indent=2)  # 2 spaces
json.dumps(data, indent=4)  # 4 spaces

# sort_keys - Sort dictionary keys alphabetically
json.dumps(data, sort_keys=True)

# ensure_ascii - Handle non-ASCII characters
json.dumps({"name": "François"}, ensure_ascii=False)

# default - Handle non-serializable objects
import datetime
json.dumps({"time": datetime.datetime.now()}, default=str)
```

---

## 🗂️ Part 3: Working with YAML

### What is YAML?

**YAML** = YAML Ain't Markup Language
- Human-friendly data format
- More readable than JSON
- Supports comments

### Why YAML in DevOps?

```
✅ Kubernetes manifests
✅ Ansible playbooks
✅ Docker Compose files
✅ CI/CD configs (GitHub Actions, GitLab CI)
✅ Configuration management
```

---

### YAML vs JSON Example

**JSON:**
```json
{
  "server": {
    "name": "web-01",
    "ports": [80, 443],
    "enabled": true
  }
}
```

**YAML:**
```yaml
server:
  name: web-01
  ports:
    - 80
    - 443
  enabled: true
```

**YAML is cleaner!** ✨

---

### Installing PyYAML

```bash
# Install the YAML library
pip install pyyaml
```

---

### YAML Operations - The Main 4

#### 1. `yaml.safe_load()` - YAML String → Python

```python
import yaml

# YAML string
yaml_string = """
server:
  name: web-01
  ip: 192.168.1.10
  ports:
    - 80
    - 443
  enabled: true
"""

# Parse YAML
data = yaml.safe_load(yaml_string)

print(data['server']['name'])  # web-01
print(data['server']['ports'])  # [80, 443]
```

**⚠️ Important**: Always use `safe_load()`, NOT `load()`
- `safe_load()` is secure
- `load()` can execute arbitrary code (security risk!)

---

#### 2. `yaml.dump()` - Python → YAML String

```python
import yaml

# Python dictionary
config = {
    "database": {
        "host": "localhost",
        "port": 5432,
        "name": "myapp"
    },
    "features": ["auth", "api", "logging"]
}

# Convert to YAML
yaml_string = yaml.dump(config, default_flow_style=False)
print(yaml_string)
```

**Output:**
```yaml
database:
  host: localhost
  name: myapp
  port: 5432
features:
- auth
- api
- logging
```

---

#### 3. Read YAML File

```python
import yaml

# Read YAML file
with open('config.yaml', 'r') as f:
    config = yaml.safe_load(f)

print(config)
```

---

#### 4. Write YAML File

```python
import yaml

servers = {
    "production": [
        {"name": "web-01", "role": "frontend"},
        {"name": "db-01", "role": "database"}
    ],
    "staging": [
        {"name": "web-stg-01", "role": "frontend"}
    ]
}

# Write to file
with open('servers.yaml', 'w') as f:
    yaml.dump(servers, f, default_flow_style=False)
```

---

### YAML Special Features

#### 1. Comments (JSON doesn't have this!)

```yaml
# Server configuration
server:
  name: web-01  # Production server
  port: 8080    # HTTP port
```

#### 2. Multi-line Strings

```yaml
# Using | (preserves newlines)
script: |
  #!/bin/bash
  echo "Starting deployment"
  ./deploy.sh

# Using > (folds newlines into spaces)
description: >
  This is a long description
  that spans multiple lines
  but becomes one line.
```

#### 3. Anchors & References (Reuse content)

```yaml
# Define anchor
default: &default_settings
  timeout: 30
  retry: 3

# Use anchor
production:
  <<: *default_settings
  host: prod.example.com

staging:
  <<: *default_settings
  host: staging.example.com
```

---

## 🛠️ Real DevOps Examples

### Example 1: Parse Kubernetes Config

```python
import yaml

# Read Kubernetes deployment YAML
with open('deployment.yaml', 'r') as f:
    k8s_config = yaml.safe_load(f)

# Extract information
app_name = k8s_config['metadata']['name']
replicas = k8s_config['spec']['replicas']
image = k8s_config['spec']['template']['spec']['containers'][0]['image']

print(f"App: {app_name}")
print(f"Replicas: {replicas}")
print(f"Image: {image}")
```

---

### Example 2: Generate Ansible Inventory

```python
import yaml

# Create inventory structure
inventory = {
    "all": {
        "children": {
            "webservers": {
                "hosts": {
                    "web-01": {"ansible_host": "192.168.1.10"},
                    "web-02": {"ansible_host": "192.168.1.11"}
                }
            },
            "databases": {
                "hosts": {
                    "db-01": {"ansible_host": "192.168.1.20"}
                }
            }
        }
    }
}

# Save as YAML
with open('inventory.yaml', 'w') as f:
    yaml.dump(inventory, f, default_flow_style=False)
```

---

### Example 3: Convert JSON to YAML

```python
import json
import yaml

# Read JSON file
with open('config.json', 'r') as f:
    data = json.load(f)

# Write as YAML
with open('config.yaml', 'w') as f:
    yaml.dump(data, f, default_flow_style=False)

print("Converted config.json to config.yaml")
```

---

### Example 4: Validate Configuration

```python
import yaml
from pathlib import Path

def validate_server_config(config_file: str) -> bool:
    """
    Validate server configuration file
    Returns True if valid, False otherwise
    """
    try:
        with open(config_file, 'r') as f:
            config = yaml.safe_load(f)
        
        # Required fields
        required = ['server', 'database', 'logging']
        
        for field in required:
            if field not in config:
                print(f"❌ Missing required field: {field}")
                return False
        
        # Validate server section
        if 'host' not in config['server']:
            print("❌ Server must have 'host' field")
            return False
        
        print("✅ Configuration is valid")
        return True
        
    except yaml.YAMLError as e:
        print(f"❌ YAML parsing error: {e}")
        return False
    except FileNotFoundError:
        print(f"❌ File not found: {config_file}")
        return False

# Usage
validate_server_config('app-config.yaml')
```

---

## 📊 JSON vs YAML - When to Use What?

| Scenario | Use JSON | Use YAML |
|----------|----------|----------|
| API responses | ✅ | ❌ |
| REST API requests | ✅ | ❌ |
| Simple configs | ✅ | ✅ |
| Complex configs | ❌ | ✅ |
| Need comments | ❌ | ✅ |
| Kubernetes | ❌ | ✅ |
| Docker Compose | ❌ | ✅ |
| Ansible | ❌ | ✅ |
| CI/CD configs | ✅ | ✅ |
| Cloud outputs (AWS, Azure) | ✅ | ❌ |

---

## 🎯 Practice Exercise

Create a script that:

1. Reads a JSON file with server data
2. Filters servers by criteria (e.g., CPU > 80%)
3. Writes results to a YAML file

```python
import json
import yaml

# Read JSON
with open('servers.json', 'r') as f:
    servers = json.load(f)

# Filter high CPU servers
high_cpu = [s for s in servers if s['cpu'] > 80]

# Write to YAML with comments
output = {
    "alert": "High CPU Usage Detected",
    "timestamp": "2026-01-08",
    "servers": high_cpu
}

with open('alerts.yaml', 'w') as f:
    yaml.dump(output, f, default_flow_style=False)

print(f"Found {len(high_cpu)} servers with high CPU")
```

---

## 💡 Best Practices

### JSON Best Practices

```python
# ✅ GOOD: Use indent for readability
json.dumps(data, indent=2)

# ✅ GOOD: Use ensure_ascii=False for international characters
json.dumps(data, ensure_ascii=False)

# ✅ GOOD: Always handle exceptions
try:
    data = json.loads(json_string)
except json.JSONDecodeError as e:
    print(f"Invalid JSON: {e}")

# ❌ BAD: Don't read entire file as string for large files
# data = json.loads(open('large.json').read())  # Memory issue!

# ✅ GOOD: Stream large files
with open('large.json', 'r') as f:
    data = json.load(f)  # Efficient
```

---

### YAML Best Practices

```python
# ✅ GOOD: Always use safe_load (security)
data = yaml.safe_load(yaml_string)

# ❌ BAD: Never use load (can execute code!)
# data = yaml.load(yaml_string)  # DANGEROUS!

# ✅ GOOD: Use default_flow_style=False for readability
yaml.dump(data, f, default_flow_style=False)

# ✅ GOOD: Validate structure after loading
if 'required_field' not in data:
    raise ValueError("Missing required field")

# ✅ GOOD: Handle parsing errors
try:
    data = yaml.safe_load(yaml_string)
except yaml.YAMLError as e:
    print(f"YAML error: {e}")
```

---

## 🔗 Integration Example: Config Manager

```python
import json
import yaml
from pathlib import Path
from typing import Dict, Any

class ConfigManager:
    """
    Load configuration from JSON or YAML
    Real-world: Support multiple config formats
    """
    
    def load_config(self, file_path: str) -> Dict[str, Any]:
        """Load config from JSON or YAML file"""
        path = Path(file_path)
        
        if not path.exists():
            raise FileNotFoundError(f"Config file not found: {file_path}")
        
        # Determine format by extension
        if path.suffix == '.json':
            return self._load_json(path)
        elif path.suffix in ['.yaml', '.yml']:
            return self._load_yaml(path)
        else:
            raise ValueError(f"Unsupported format: {path.suffix}")
    
    def _load_json(self, path: Path) -> Dict:
        with open(path, 'r') as f:
            return json.load(f)
    
    def _load_yaml(self, path: Path) -> Dict:
        with open(path, 'r') as f:
            return yaml.safe_load(f)
    
    def save_config(self, data: Dict, file_path: str, format: str = 'yaml'):
        """Save config to JSON or YAML"""
        path = Path(file_path)
        
        if format == 'json':
            with open(path, 'w') as f:
                json.dump(data, f, indent=2)
        elif format == 'yaml':
            with open(path, 'w') as f:
                yaml.dump(data, f, default_flow_style=False)
        else:
            raise ValueError(f"Unsupported format: {format}")

# Usage
config_mgr = ConfigManager()

# Load either format
config = config_mgr.load_config('app-config.yaml')
# OR
config = config_mgr.load_config('app-config.json')

# Convert between formats
config_mgr.save_config(config, 'output.json', format='json')
config_mgr.save_config(config, 'output.yaml', format='yaml')
```

---

## 📚 Quick Reference

### JSON Cheat Sheet

```python
import json

# String operations
json.dumps(obj)              # Python → JSON string
json.loads(string)           # JSON string → Python

# File operations
json.dump(obj, file)         # Python → JSON file
json.load(file)              # JSON file → Python

# Common parameters
json.dumps(obj, indent=2)    # Pretty print
json.dumps(obj, sort_keys=True)  # Sort keys
```

### YAML Cheat Sheet

```python
import yaml

# String operations
yaml.dump(obj)               # Python → YAML string
yaml.safe_load(string)       # YAML string → Python

# File operations (same as strings)
yaml.dump(obj, file)         # Python → YAML file
yaml.safe_load(file)         # YAML file → Python

# Common parameters
yaml.dump(obj, default_flow_style=False)  # Block style
```

---

## 🎓 Key Takeaways

✅ Use `dir()`, `help()`, `inspect` to explore modules  
✅ JSON for APIs and data exchange  
✅ YAML for configs (more readable)  
✅ Always use `yaml.safe_load()` (security!)  
✅ Handle parsing errors with try/except  
✅ Use `indent` for readable output  
✅ `dumps/loads` for strings, `dump/load` for files  

---

## 🚀 Next Steps

Practice with:
1. Read a JSON API response
2. Parse a Kubernetes YAML file
3. Convert between JSON and YAML formats
4. Build a config validator script

Check out:
1. **Everything is Object** → [05_everything_is_object.md](05_everything_is_object.html)

