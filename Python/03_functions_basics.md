# ⚙️ Functions - Reusable Code Blocks

## What is a Function?

A function is like a **recipe** - a set of instructions you can use over and over.

```python
# Without function (repetitive)
print("Checking web-01...")
print("web-01 is healthy")

print("Checking web-02...")
print("web-02 is healthy")

print("Checking web-03...")
print("web-03 is healthy")

# With function (reusable!)
def check_server(name):
    print(f"Checking {name}...")
    print(f"{name} is healthy")

check_server("web-01")
check_server("web-02")
check_server("web-03")
```

---

## Why Use Functions?

```
✅ Don't Repeat Yourself (DRY principle)
✅ Easy to test individual parts
✅ Easy to fix bugs (change in one place)
✅ Code is easier to read
✅ Can reuse across projects
```

---

## Basic Function Syntax

```python
def function_name(parameters):
    """What the function does"""
    # Code goes here
    return result
```

### Parts Explained:

1. **`def`** - Keyword to define function
2. **`function_name`** - Name you choose (use `snake_case`)
3. **`parameters`** - Input values (optional)
4. **Docstring** - Description of what function does
5. **`return`** - Send result back (optional)

---

## Simple Examples

### Example 1: Function with No Parameters

```python
def say_hello():
    """Print a greeting"""
    print("Hello from DevOps!")

# Call the function
say_hello()  # Output: Hello from DevOps!
```

---

### Example 2: Function with One Parameter

```python
def greet_server(server_name):
    """Greet a specific server"""
    print(f"Hello, {server_name}!")

# Call it
greet_server("web-01")  # Output: Hello, web-01!
greet_server("db-01")   # Output: Hello, db-01!
```

---

### Example 3: Function with Return Value

```python
def calculate_disk_percentage(used_gb, total_gb):
    """Calculate disk usage percentage"""
    percentage = (used_gb / total_gb) * 100
    return percentage

# Use it
result = calculate_disk_percentage(450, 500)
print(f"Disk usage: {result}%")  # Disk usage: 90.0%
```

---

### Example 4: Multiple Parameters

```python
def create_server_url(protocol, host, port):
    """Build a server URL"""
    url = f"{protocol}://{host}:{port}"
    return url

# Use it
url = create_server_url("https", "example.com", 443)
print(url)  # https://example.com:443
```

---

### Example 5: Default Parameters

```python
def deploy_service(service_name, environment="development"):
    """Deploy service to environment (defaults to dev)"""
    print(f"Deploying {service_name} to {environment}")

# Call without environment (uses default)
deploy_service("api")  # Deploying api to development

# Call with environment
deploy_service("api", "production")  # Deploying api to production
```

---

## Return vs Print

### ❌ Common Beginner Mistake

```python
def add_numbers(a, b):
    print(a + b)  # Just prints, doesn't return!

result = add_numbers(5, 3)
print(result)  # Output: None (nothing was returned!)
```

### ✅ Correct Way

```python
def add_numbers(a, b):
    return a + b  # Return the value

result = add_numbers(5, 3)
print(result)  # Output: 8
```

**Key Difference:**
- **`print`** - Shows on screen, can't use result later
- **`return`** - Gives back a value you can use

---

## Real DevOps Examples

### Example 1: Check Server Health

```python
def is_server_healthy(cpu_percent, memory_percent, disk_percent):
    """
    Check if server is healthy
    Returns True if all metrics are below 80%
    """
    if cpu_percent < 80 and memory_percent < 80 and disk_percent < 80:
        return True
    else:
        return False

# Use it
healthy = is_server_healthy(cpu_percent=65, memory_percent=70, disk_percent=75)
if healthy:
    print("✅ Server is healthy")
else:
    print("⚠️ Server needs attention")
```

---

### Example 2: Format Log Message

```python
def format_log(level, message):
    """
    Create formatted log message
    level: INFO, WARNING, ERROR
    """
    from datetime import datetime
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return f"[{timestamp}] {level}: {message}"

# Use it
log_entry = format_log("ERROR", "Failed to connect to database")
print(log_entry)
# Output: [2026-01-07 14:30:45] ERROR: Failed to connect to database
```

---

### Example 3: Calculate Monthly Cost

```python
def calculate_monthly_cost(hours_used, hourly_rate=0.10):
    """
    Calculate monthly cost for a resource
    Assumes 730 hours per month
    """
    monthly_hours = 730
    total_cost = hours_used * hourly_rate
    return round(total_cost, 2)

# Use it
cost = calculate_monthly_cost(730, 0.15)
print(f"Monthly cost: ${cost}")  # Monthly cost: $109.5
```

---

### Example 4: Validate Configuration

```python
def validate_config(config):
    """
    Check if config has required fields
    Returns: (is_valid, error_message)
    """
    required_fields = ["host", "port", "username"]
    
    for field in required_fields:
        if field not in config:
            return False, f"Missing required field: {field}"
    
    # Check port is valid
    if config["port"] < 1 or config["port"] > 65535:
        return False, "Port must be between 1 and 65535"
    
    return True, "Configuration is valid"

# Use it
config = {
    "host": "localhost",
    "port": 5432,
    "username": "admin"
}

is_valid, message = validate_config(config)
if is_valid:
    print("✅", message)
else:
    print("❌", message)
```

---

## Function Best Practices

### 1. **One Function = One Job**

```python
# ❌ BAD: Function does too much
def deploy_and_test_and_notify(service):
    deploy(service)
    test(service)
    send_notification(service)

# ✅ GOOD: Separate functions
def deploy(service):
    # Just deploy
    pass

def test(service):
    # Just test
    pass

def notify(service, status):
    # Just notify
    pass
```

---

### 2. **Use Descriptive Names**

```python
# ❌ BAD: Unclear names
def do_thing(x, y):
    return x / y

# ✅ GOOD: Clear names
def calculate_percentage(used, total):
    return (used / total) * 100
```

---

### 3. **Add Docstrings**

```python
def restart_service(service_name, wait_time=30):
    """
    Restart a service and wait for it to come up
    
    Args:
        service_name (str): Name of the service to restart
        wait_time (int): Seconds to wait after restart (default: 30)
    
    Returns:
        bool: True if restart successful, False otherwise
    """
    # Implementation here
    pass
```

---

### 4. **Keep Functions Short**

```python
# ✅ GOOD: Short and focused
def is_port_valid(port):
    """Check if port number is valid"""
    return 1 <= port <= 65535

# Rule of thumb: If it doesn't fit on your screen, it's too long!
```

---

## Common Patterns in DevOps

### Pattern 1: Retry Logic

```python
def retry_operation(func, max_attempts=3):
    """Try an operation multiple times"""
    for attempt in range(max_attempts):
        try:
            result = func()
            return result
        except Exception as e:
            if attempt == max_attempts - 1:
                raise
            print(f"Attempt {attempt + 1} failed, retrying...")
```

---

### Pattern 2: Validation Functions

```python
def validate_ip_address(ip):
    """Check if IP address is valid format"""
    parts = ip.split('.')
    if len(parts) != 4:
        return False
    
    for part in parts:
        if not part.isdigit():
            return False
        num = int(part)
        if num < 0 or num > 255:
            return False
    
    return True

# Use it
if validate_ip_address("192.168.1.1"):
    print("Valid IP")
```

---

### Pattern 3: Builder Functions

```python
def build_docker_command(image, port, environment="production"):
    """Build docker run command"""
    cmd = f"docker run -p {port}:80"
    cmd += f" -e ENV={environment}"
    cmd += f" {image}"
    return cmd

# Use it
command = build_docker_command("nginx:latest", 8080)
print(command)
# docker run -p 8080:80 -e ENV=production nginx:latest
```

---

## Practice Exercises

### Exercise 1: Temperature Converter
```python
def celsius_to_fahrenheit(celsius):
    """Convert Celsius to Fahrenheit"""
    # Your code here
    # Formula: (C × 9/5) + 32
    pass

# Test it
print(celsius_to_fahrenheit(0))   # Should be 32
print(celsius_to_fahrenheit(100)) # Should be 212
```

---

### Exercise 2: Uptime Calculator
```python
def calculate_uptime_percentage(total_hours, downtime_hours):
    """
    Calculate uptime percentage
    Return percentage rounded to 2 decimal places
    """
    # Your code here
    pass

# Test it
print(calculate_uptime_percentage(730, 1))  # Should be ~99.86%
```

---

### Exercise 3: Server Name Generator
```python
def generate_server_name(environment, service, number):
    """
    Generate server name in format: env-service-number
    Example: prod-web-01
    """
    # Your code here
    pass

# Test it
print(generate_server_name("prod", "web", 1))  # prod-web-01
print(generate_server_name("dev", "db", 5))    # dev-db-05
```

---

## Key Takeaways

✅ Functions make code **reusable**  
✅ Use `return` to send values back  
✅ Give functions **clear names**  
✅ One function = One job  
✅ Add **docstrings** to explain what they do

---

## Next Steps

Learn about:
Modules → [04_modules_json_yaml.md](04_modules_json_yaml.md)
