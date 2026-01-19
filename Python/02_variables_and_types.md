# 📦 Variables and Data Types - Building Blocks

## What is a Variable?

A variable is like a **labeled box** that stores data.

```python
# Create a variable
server_name = "web-server-01"

# Use it later
print(server_name)  # Output: web-server-01
```

---

## Basic Data Types

### 1. **String (Text)** - `str`

```python
# Text inside quotes
server_name = "web-01"
environment = 'production'  # Single or double quotes work

# Why we use strings in DevOps:
- Server names: "web-01", "db-master"
- IP addresses: "192.168.1.10"
- Status messages: "Deployment successful"
- File paths: "/var/log/app.log"
```

**Common Operations:**

```python
# Combine strings
full_name = "server-" + "01"  # "server-01"

# String formatting (modern way)
name = "web-01"
message = f"Deploying to {name}"  # "Deploying to web-01"

# Check what's inside
if "prod" in environment:
    print("This is production!")

# Change case
server_name.upper()  # "WEB-01"
server_name.lower()  # "web-01"
```

---

### 2. **Integer (Whole Numbers)** - `int`

```python
# Numbers without decimals
port = 8080
cpu_count = 4
disk_size_gb = 500

# Why we use integers in DevOps:
- Port numbers: 80, 443, 8080
- Resource counts: 4 CPUs, 16GB RAM
- Timeouts: 30 seconds
- Exit codes: 0 (success), 1 (error)
```

**Common Operations:**

```python
# Math
total_servers = 10 + 5  # 15
half = 10 / 2  # 5.0 (becomes float)
cpu_cores = 2 * 4  # 8

# Comparisons
if cpu_count > 2:
    print("Multi-core server")

# Convert to string
port_str = str(port)  # "8080"
```

---

### 3. **Float (Decimal Numbers)** - `float`

```python
# Numbers with decimals
cpu_usage = 78.5
memory_percent = 85.2
response_time = 0.125

# Why we use floats in DevOps:
- Percentages: 78.5% CPU usage
- Response times: 0.125 seconds
- Costs: $123.45
- Load averages: 2.5
```

**Common Operations:**

```python
# Rounding
cpu_rounded = round(78.543, 2)  # 78.54

# Comparisons
if cpu_usage > 80.0:
    print("High CPU!")
```

---

### 4. **Boolean (True/False)** - `bool`

```python
# Only two values: True or False
is_production = True
service_running = False

# Why we use booleans in DevOps:
- Status checks: is_running = True
- Feature flags: enable_ssl = True
- Validation: config_valid = False
- Conditions: should_restart = True
```

**Common Operations:**

```python
# Logical operations
is_healthy = service_running and cpu_usage < 80

# Negation
if not service_running:
    print("Service is down!")

# Comparisons create booleans
is_full = disk_usage > 90  # True or False
```

---

### 5. **List (Collection of Items)** - `list`

```python
# Ordered collection, can change
servers = ["web-01", "web-02", "web-03"]
ports = [80, 443, 8080]
mixed = ["web-01", 8080, True]  # Can mix types

# Why we use lists in DevOps:
- Server inventory: ["web-01", "web-02"]
- Port lists: [80, 443, 8080]
- Log entries: ["ERROR", "WARNING", "INFO"]
- Task queue: ["deploy", "backup", "restart"]
```

**Common Operations:**

```python
# Access by index (starts at 0!)
first_server = servers[0]  # "web-01"
last_server = servers[-1]  # "web-03"

# Add items
servers.append("web-04")  # Add to end
servers.insert(0, "web-00")  # Add at position

# Remove items
servers.remove("web-02")  # Remove specific item
last = servers.pop()  # Remove and return last item

# Check length
count = len(servers)  # How many servers?

# Loop through list
for server in servers:
    print(f"Checking {server}")

# Check if item exists
if "web-01" in servers:
    print("Server exists!")
```

---

### 6. **Dictionary (Key-Value Pairs)** - `dict`

```python
# Like a real dictionary: word → definition
server = {
    "name": "web-01",
    "ip": "192.168.1.10",
    "port": 8080,
    "status": "running"
}

# Why we use dictionaries in DevOps:
- Configuration: {"host": "localhost", "port": 5432}
- Server metadata: {"name": "web-01", "region": "us-east"}
- API responses: {"status": "success", "data": [...]}
- Environment variables: {"ENV": "prod", "DEBUG": "false"}
```

**Common Operations:**

```python
# Access values by key
ip_address = server["ip"]  # "192.168.1.10"
server_name = server.get("name")  # Safer way

# Add/update values
server["region"] = "us-east-1"  # Add new key
server["port"] = 9090  # Update existing

# Check if key exists
if "status" in server:
    print(server["status"])

# Get all keys and values
keys = server.keys()  # ["name", "ip", "port", "status"]
values = server.values()  # ["web-01", "192.168.1.10", ...]

# Loop through dictionary
for key, value in server.items():
    print(f"{key}: {value}")
```

---

### 7. **Tuple (Unchangeable List)** - `tuple`

```python
# Like list, but can't change after creation
coordinates = (40.7128, -74.0060)  # Latitude, Longitude
database_creds = ("admin", "password123")

# Why we use tuples in DevOps:
- Coordinates: (latitude, longitude)
- Fixed configs: (host, port)
- Return multiple values from functions
- Dictionary keys (lists can't be keys!)
```

**Common Operations:**

```python
# Access like lists
lat = coordinates[0]  # 40.7128

# Can't modify (this will error!)
# coordinates[0] = 41.0  # TypeError!

# Unpacking
username, password = database_creds
```

---

### 8. **Set (Unique Items Only)** - `set`

```python
# Unordered collection, no duplicates
unique_ips = {"192.168.1.10", "192.168.1.11", "192.168.1.10"}
# Result: {"192.168.1.10", "192.168.1.11"}  # Duplicate removed!

# Why we use sets in DevOps:
- Remove duplicates from logs
- Find unique users/IPs
- Set operations (union, intersection)
- Membership testing (faster than lists)
```

**Common Operations:**

```python
# Add items
unique_ips.add("192.168.1.12")

# Remove items
unique_ips.remove("192.168.1.10")

# Set operations
servers_a = {"web-01", "web-02", "db-01"}
servers_b = {"web-02", "web-03", "db-01"}

common = servers_a & servers_b  # Intersection: {"web-02", "db-01"}
all_servers = servers_a | servers_b  # Union: all unique servers
only_in_a = servers_a - servers_b  # Difference: {"web-01"}
```

---

## Quick Reference Table

| Type | Example | Mutable? | Use Case |
|------|---------|----------|----------|
| `str` | `"web-01"` | No | Text, names, messages |
| `int` | `8080` | No | Counts, ports, codes |
| `float` | `78.5` | No | Percentages, measurements |
| `bool` | `True` | No | Flags, conditions |
| `list` | `["a", "b"]` | Yes | Ordered collections |
| `dict` | `{"key": "value"}` | Yes | Configuration, metadata |
| `tuple` | `(1, 2)` | No | Fixed data |
| `set` | `{1, 2, 3}` | Yes | Unique items |

**Mutable = Can change after creation**

---

## Type Conversion

```python
# String to int
port = int("8080")  # 8080

# Int to string
port_str = str(8080)  # "8080"

# String to float
cpu = float("78.5")  # 78.5

# List to set (remove duplicates)
unique = set([1, 2, 2, 3])  # {1, 2, 3}

# Check type
type(port)  # <class 'int'>
```

---

## Real DevOps Example

```python
# Server inventory
servers = [
    {
        "name": "web-01",
        "ip": "192.168.1.10",
        "port": 8080,
        "cpu_percent": 75.5,
        "is_running": True,
        "tags": ["production", "frontend"]
    },
    {
        "name": "db-01",
        "ip": "192.168.1.20",
        "port": 5432,
        "cpu_percent": 45.2,
        "is_running": True,
        "tags": ["production", "database"]
    }
]

# Use the data
for server in servers:
    if server["is_running"] and server["cpu_percent"] > 70:
        print(f"⚠️ {server['name']} high CPU: {server['cpu_percent']}%")
```

---

## Practice Exercises

### Exercise 1: Create Variables
```python
# Create these variables:
# - Your server name (string)
# - Port number (integer)
# - CPU usage (float)
# - Is it running? (boolean)

# Your code here:
```

### Exercise 2: Build a Server Dictionary
```python
# Create a dictionary with:
# - name
# - ip
# - status

# Your code here:
```

### Exercise 3: List Operations
```python
# Create a list of 3 server names
# Add one more server
# Print each server name

# Your code here:
```

---

## Next Step

Ready for **functions**? → See [03_functions_basics.md](03_functions_basics.md)
