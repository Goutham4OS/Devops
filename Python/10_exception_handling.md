````markdown
# ⚠️ Exception Handling - Building Resilient Applications

## Why Exception Handling Matters in DevOps

In DevOps, **up to 1% of network requests fail** due to transient issues. Without proper error handling:
- Scripts crash unexpectedly
- Partial work is lost
- No visibility into what went wrong
- Automated processes break silently

Exception handling is **critical** for building resilient automation.

### The Reality of Distributed Systems

In the real world, things fail constantly:

| Failure Type | Frequency | Example |
|--------------|-----------|----------|
| Network timeout | ~0.1-1% | API doesn't respond in time |
| DNS resolution | ~0.01% | Can't resolve hostname |
| TLS/SSL errors | Rare | Certificate expired |
| Rate limiting | Common | Too many requests |
| Service unavailable | ~0.1% | 503 errors during deployment |

**The Eight Fallacies of Distributed Computing** remind us:
1. The network is NOT reliable
2. Latency is NOT zero
3. Bandwidth is NOT infinite
4. The network is NOT secure

Your code must expect and handle these failures gracefully.

```
┌─────────────────────────────────────────────────────────────┐
│  Without Exception Handling:                                │
│    Script runs → Error occurs → CRASH → 3 AM phone call    │
│                                                              │
│  With Exception Handling:                                    │
│    Script runs → Error occurs → Logged → Retry → Success   │
│                        ↓                                     │
│                   Alert sent → You fix it during work hours │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 PART 1: Basic Exception Handling

### The try/except Pattern

```python
try:
    # Code that might fail
    result = risky_operation()
except ExceptionType:
    # Handle the error
    handle_error()
```

### Simple Example

```python
# Without exception handling
numbers = [1, 2, 3]
print(numbers[10])  # IndexError: list index out of range
# Program crashes! ❌

# With exception handling
numbers = [1, 2, 3]
try:
    print(numbers[10])
except IndexError:
    print("Index out of range!")  # Program continues ✅
```

### Catching Multiple Exception Types

```python
def read_config(filename):
    try:
        with open(filename, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Config file not found: {filename}")
        return {}
    except json.JSONDecodeError as e:
        print(f"Invalid JSON in config: {e}")
        return {}
    except PermissionError:
        print(f"Permission denied: {filename}")
        return {}
```

### Catching Multiple Exceptions in One Block

```python
try:
    data = process_data()
except (ValueError, TypeError, KeyError) as e:
    print(f"Data error: {e}")
```

---

## 🎯 PART 2: Common Exceptions in DevOps

### IndexError - Accessing Invalid Index

**Common cause:** Accessing `sys.argv` without checking length.

```python
import sys

# ❌ DANGEROUS
script_name = sys.argv[0]
config_file = sys.argv[1]  # IndexError if no argument provided!

# ✅ SAFE
if len(sys.argv) < 2:
    print("Usage: python script.py <config_file>")
    sys.exit(1)

config_file = sys.argv[1]
```

```python
# Another common pattern
servers = []

# ❌ DANGEROUS
first_server = servers[0]  # IndexError: list index out of range

# ✅ SAFE
try:
    first_server = servers[0]
except IndexError:
    first_server = None
    print("No servers found")

# ✅ SAFER - Check first
first_server = servers[0] if servers else None
```

---

### KeyError - Missing Dictionary Key

```python
config = {"host": "localhost"}

# ❌ DANGEROUS
port = config["port"]  # KeyError: 'port'

# ✅ SAFE - Use get() with default
port = config.get("port", 8080)

# ✅ SAFE - Check first
if "port" in config:
    port = config["port"]
else:
    port = 8080

# ✅ SAFE - Exception handling
try:
    port = config["port"]
except KeyError:
    port = 8080
```

---

### FileNotFoundError - Missing File

```python
import os

# ❌ DANGEROUS
with open("config.yaml", "r") as f:
    config = f.read()

# ✅ SAFE - Check existence first
if os.path.exists("config.yaml"):
    with open("config.yaml", "r") as f:
        config = f.read()
else:
    print("Config not found, using defaults")
    config = {}

# ✅ SAFE - Exception handling
try:
    with open("config.yaml", "r") as f:
        config = f.read()
except FileNotFoundError:
    print("Config not found, using defaults")
    config = {}
```

---

### ImportError / ModuleNotFoundError

```python
# ❌ DANGEROUS - Assumes module exists
import yaml

# ✅ SAFE - Check for optional dependency
try:
    import yaml
    HAS_YAML = True
except ImportError:
    HAS_YAML = False
    print("Warning: PyYAML not installed. YAML support disabled.")

def load_config(path):
    if path.endswith('.yaml'):
        if not HAS_YAML:
            raise ImportError("PyYAML required: pip install pyyaml")
        # ... load YAML
```

---

### StopIteration - Iterator Exhausted

```python
# Understanding iterators
numbers = iter([1, 2, 3])

print(next(numbers))  # 1
print(next(numbers))  # 2
print(next(numbers))  # 3
print(next(numbers))  # StopIteration! No more items

# ✅ SAFE - Use default value
numbers = iter([1, 2, 3])
value = next(numbers, None)  # Returns None if exhausted

# ✅ SAFE - Handle exception
try:
    while True:
        value = next(numbers)
        process(value)
except StopIteration:
    print("All items processed")
```

---

### ConnectionError / TimeoutError - Network Issues

```python
import requests
from requests.exceptions import ConnectionError, Timeout, RequestException

def fetch_data(url, timeout=30):
    """Fetch data with proper error handling"""
    try:
        response = requests.get(url, timeout=timeout)
        response.raise_for_status()  # Raises HTTPError for 4xx/5xx
        return response.json()
    
    except Timeout:
        print(f"Request timed out after {timeout}s")
        return None
    
    except ConnectionError:
        print(f"Cannot connect to {url}")
        return None
    
    except requests.HTTPError as e:
        print(f"HTTP error: {e.response.status_code}")
        return None
    
    except RequestException as e:
        print(f"Request failed: {e}")
        return None
```

---

### ValueError - Invalid Value

```python
# ❌ DANGEROUS
port = int(input("Enter port: "))  # ValueError if user enters "abc"

# ✅ SAFE
try:
    port = int(input("Enter port: "))
    if not 1 <= port <= 65535:
        raise ValueError("Port must be between 1 and 65535")
except ValueError as e:
    print(f"Invalid port: {e}")
    port = 8080
```

---

### TypeError - Wrong Type

```python
# ❌ Causes TypeError
result = "Hello" + 42  # TypeError: can only concatenate str to str

# ✅ SAFE
def concat_safely(a, b):
    try:
        return str(a) + str(b)
    except (TypeError, ValueError) as e:
        print(f"Cannot concatenate: {e}")
        return None
```

---

## 🔧 PART 3: Complete try/except/else/finally

```python
def process_config(filename):
    """
    Demonstrates all exception handling clauses
    """
    file_handle = None
    
    try:
        # Code that might fail
        file_handle = open(filename, 'r')
        content = file_handle.read()
        data = json.loads(content)
        
    except FileNotFoundError:
        # Specific exception handler
        print(f"File not found: {filename}")
        return None
        
    except json.JSONDecodeError as e:
        # Another specific exception
        print(f"Invalid JSON: {e}")
        return None
        
    except Exception as e:
        # Catch-all for unexpected errors
        print(f"Unexpected error: {e}")
        raise  # Re-raise the exception
        
    else:
        # Runs ONLY if no exception occurred
        print(f"Successfully loaded config")
        return data
        
    finally:
        # ALWAYS runs (cleanup code)
        if file_handle:
            file_handle.close()
        print("Cleanup complete")
```

### When to Use Each Clause

| Clause | Purpose | When It Runs |
|--------|---------|--------------|
| `try` | Code that might fail | Always (first) |
| `except` | Handle specific errors | Only if exception occurs |
| `else` | Code for success case | Only if NO exception |
| `finally` | Cleanup code | ALWAYS (even if exception) |

---

## 🔄 PART 4: Retry Patterns

### Why Retry?

Many failures are **transient**—they go away if you try again:
- Network blip: Works on second try
- Rate limit: Works after waiting
- Server restart: Works after 30 seconds

Instead of failing immediately, smart scripts retry with **exponential backoff**.

### What is Exponential Backoff?

Instead of retrying immediately (which can overwhelm a struggling server), wait progressively longer:

```
Attempt 1: Wait 1 second
Attempt 2: Wait 2 seconds  (1 × 2)
Attempt 3: Wait 4 seconds  (2 × 2)
Attempt 4: Wait 8 seconds  (4 × 2)
Attempt 5: Wait 16 seconds (8 × 2)
```

**Why this works:**
- Gives the service time to recover
- Prevents "thundering herd" (all clients retrying simultaneously)
- Spreads load over time
- Eventually succeeds or fails gracefully

**Adding jitter** (randomness) further prevents synchronized retries:

```
Attempt 1: Wait 0.8-1.2 seconds (1 × random)
Attempt 2: Wait 1.6-2.4 seconds (2 × random)
... and so on
```

### Simple Retry

```python
import time

def retry_operation(func, max_attempts=3, delay=1):
    """
    Retry a function with fixed delay
    """
    for attempt in range(1, max_attempts + 1):
        try:
            return func()
        except Exception as e:
            print(f"Attempt {attempt} failed: {e}")
            if attempt == max_attempts:
                raise
            time.sleep(delay)
```

### Exponential Backoff (Production Pattern)

```python
import time
import random
import logging

logger = logging.getLogger(__name__)

def retry_with_backoff(
    func,
    max_attempts: int = 5,
    base_delay: float = 1.0,
    max_delay: float = 60.0,
    exponential_base: float = 2.0,
    jitter: bool = True,
    retryable_exceptions: tuple = (Exception,)
):
    """
    Retry with exponential backoff
    
    Args:
        func: Function to call
        max_attempts: Maximum number of attempts
        base_delay: Initial delay in seconds
        max_delay: Maximum delay in seconds
        exponential_base: Base for exponential calculation
        jitter: Add randomness to prevent thundering herd
        retryable_exceptions: Tuple of exceptions to retry on
    
    Returns:
        Result of successful function call
    
    Raises:
        Last exception if all attempts fail
    """
    last_exception = None
    
    for attempt in range(1, max_attempts + 1):
        try:
            logger.debug(f"Attempt {attempt}/{max_attempts}")
            return func()
            
        except retryable_exceptions as e:
            last_exception = e
            
            if attempt == max_attempts:
                logger.error(f"All {max_attempts} attempts failed")
                raise
            
            # Calculate delay: base_delay * (exponential_base ^ attempt)
            delay = min(base_delay * (exponential_base ** (attempt - 1)), max_delay)
            
            # Add jitter (randomness) to prevent all clients retrying simultaneously
            if jitter:
                delay = delay * (0.5 + random.random())
            
            logger.warning(
                f"Attempt {attempt} failed: {e}. "
                f"Retrying in {delay:.2f}s..."
            )
            time.sleep(delay)
    
    raise last_exception

# Usage
def call_api():
    import requests
    response = requests.get("https://api.example.com/data", timeout=10)
    response.raise_for_status()
    return response.json()

# Retry on specific exceptions
from requests.exceptions import RequestException, Timeout
data = retry_with_backoff(
    call_api,
    max_attempts=5,
    retryable_exceptions=(RequestException, Timeout)
)
```

### Using tenacity Library (Recommended)

```python
# pip install tenacity
from tenacity import (
    retry,
    stop_after_attempt,
    wait_exponential,
    retry_if_exception_type
)
import requests

@retry(
    stop=stop_after_attempt(5),
    wait=wait_exponential(multiplier=1, min=1, max=60),
    retry=retry_if_exception_type((requests.RequestException,))
)
def fetch_with_retry(url):
    """Automatically retries with exponential backoff"""
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    return response.json()
```

---

## 🛡️ PART 5: Circuit Breaker Pattern

Prevents system overload by stopping requests when failures accumulate.

### The Problem: Cascade Failures

Imagine Service A calls Service B, which calls Service C:

```
┌───────────┐    ┌───────────┐    ┌───────────┐
│ Service A │────│ Service B │────│ Service C │ ← DOWN!
└───────────┘    └───────────┘    └───────────┘
```

If C is down:
1. Every request to B waits for C's timeout (30 seconds)
2. B's threads get exhausted waiting
3. A's requests to B start timing out
4. A's threads get exhausted
5. **Your entire system is down because of one service!**

### The Solution: Circuit Breakers

Like an electrical circuit breaker, it "trips" when there are too many failures:

```
┌─────────────┐              ┌─────────────┐              ┌─────────────┐
│   CLOSED    │  5 failures  │    OPEN     │   timeout    │  HALF-OPEN  │
│  (normal)   │ ─────────────→ │  (failing)  │ ────────────→ │  (testing)  │
└─────────────┘              └─────────────┘              └─────────────┘
      ↑                                                           │
      │                        success                            │
      └───────────────────────────────────────────────────────────┘
```

**States:**
- **CLOSED**: Normal operation. Requests flow through. Track failures.
- **OPEN**: Too many failures. Reject requests immediately (fail fast).
- **HALF-OPEN**: After timeout, try one request to see if service recovered.

```python
import time
from enum import Enum
from dataclasses import dataclass, field
from typing import Callable, Any

class CircuitState(Enum):
    CLOSED = "closed"      # Normal operation
    OPEN = "open"          # Failing, reject requests
    HALF_OPEN = "half_open"  # Testing if recovered

@dataclass
class CircuitBreaker:
    """
    Circuit breaker pattern implementation
    
    States:
    - CLOSED: Normal operation, counting failures
    - OPEN: Circuit tripped, rejecting requests immediately
    - HALF_OPEN: Testing if service recovered
    """
    name: str
    failure_threshold: int = 5      # Failures before opening
    recovery_timeout: float = 30.0  # Seconds before trying again
    
    state: CircuitState = field(default=CircuitState.CLOSED)
    failure_count: int = field(default=0)
    last_failure_time: float = field(default=0)
    
    def call(self, func: Callable, *args, **kwargs) -> Any:
        """Execute function through circuit breaker"""
        
        if self.state == CircuitState.OPEN:
            # Check if recovery timeout has passed
            if time.time() - self.last_failure_time > self.recovery_timeout:
                print(f"[{self.name}] Trying half-open state...")
                self.state = CircuitState.HALF_OPEN
            else:
                raise CircuitBreakerOpen(
                    f"Circuit {self.name} is OPEN. "
                    f"Try again in {self.recovery_timeout - (time.time() - self.last_failure_time):.1f}s"
                )
        
        try:
            result = func(*args, **kwargs)
            self._on_success()
            return result
        except Exception as e:
            self._on_failure()
            raise
    
    def _on_success(self):
        """Reset on successful call"""
        self.failure_count = 0
        if self.state == CircuitState.HALF_OPEN:
            print(f"[{self.name}] Service recovered! Closing circuit.")
        self.state = CircuitState.CLOSED
    
    def _on_failure(self):
        """Track failure"""
        self.failure_count += 1
        self.last_failure_time = time.time()
        
        if self.failure_count >= self.failure_threshold:
            print(f"[{self.name}] Threshold reached! Opening circuit.")
            self.state = CircuitState.OPEN

class CircuitBreakerOpen(Exception):
    """Raised when circuit breaker is open"""
    pass

# Usage
api_breaker = CircuitBreaker(name="external_api", failure_threshold=3)

def call_api():
    return api_breaker.call(requests.get, "https://api.example.com")

try:
    response = call_api()
except CircuitBreakerOpen as e:
    print(f"Service unavailable: {e}")
    # Return cached data or fallback
```

---

## 📝 PART 6: Custom Exceptions

### Creating Custom Exceptions

```python
# Basic custom exception
class DeploymentError(Exception):
    """Raised when deployment fails"""
    pass

# Custom exception with additional data
class ServerError(Exception):
    """Raised for server-related errors"""
    
    def __init__(self, server_name: str, message: str, status_code: int = None):
        self.server_name = server_name
        self.status_code = status_code
        super().__init__(f"[{server_name}] {message}")

# Exception hierarchy
class InfrastructureError(Exception):
    """Base class for infrastructure errors"""
    pass

class NetworkError(InfrastructureError):
    """Network-related errors"""
    pass

class StorageError(InfrastructureError):
    """Storage-related errors"""
    pass

class ComputeError(InfrastructureError):
    """Compute-related errors"""
    pass
```

### Using Custom Exceptions

```python
def deploy_to_server(server_name: str, package: str):
    """Deploy with custom exceptions"""
    
    if not server_name:
        raise ValueError("Server name is required")
    
    try:
        # Connect to server
        connection = connect(server_name)
    except ConnectionError:
        raise NetworkError(f"Cannot connect to {server_name}")
    
    try:
        # Deploy package
        connection.deploy(package)
    except Exception as e:
        raise DeploymentError(f"Deployment failed: {e}")

# Handling custom exceptions
try:
    deploy_to_server("web-01", "app-v2.0.tar.gz")
except NetworkError as e:
    print(f"Network issue: {e}")
    # Retry or use backup
except DeploymentError as e:
    print(f"Deployment failed: {e}")
    # Rollback
except InfrastructureError as e:
    print(f"Infrastructure problem: {e}")
    # Alert on-call
```

---

## 🎯 PART 7: Best Practices

### ✅ DO: Be Specific with Exceptions

```python
# ✅ GOOD - Catch specific exceptions
try:
    config = json.loads(config_text)
except json.JSONDecodeError as e:
    logger.error(f"Invalid JSON: {e}")
    config = {}

# ❌ BAD - Catches everything (hides bugs!)
try:
    config = json.loads(config_text)
except Exception:  # Catches TypeError, NameError, etc.
    config = {}
```

### ✅ DO: Use Context Managers

```python
# ✅ GOOD - Automatic cleanup
with open("file.txt", "r") as f:
    data = f.read()
# File automatically closed, even if exception occurs

# ❌ BAD - Manual cleanup (easy to forget)
f = open("file.txt", "r")
try:
    data = f.read()
finally:
    f.close()
```

### ✅ DO: Log Exceptions with Context

```python
import logging

logger = logging.getLogger(__name__)

try:
    process_data(data)
except Exception as e:
    # ✅ GOOD - Full context with traceback
    logger.exception(f"Failed to process data: {e}")
    
    # ❌ BAD - No traceback
    logger.error(f"Failed: {e}")
```

### ✅ DO: Fail Fast, Handle at Boundaries

```python
# ✅ GOOD - Handle at system boundary
def main():
    """Entry point - handle exceptions here"""
    try:
        result = run_deployment()
    except DeploymentError as e:
        logger.error(f"Deployment failed: {e}")
        sys.exit(1)
    except Exception as e:
        logger.exception(f"Unexpected error: {e}")
        sys.exit(2)

# ✅ GOOD - Let exceptions propagate from inner functions
def deploy_service(name):
    """Let exceptions propagate - don't catch and ignore"""
    connection = connect(name)  # Let ConnectionError propagate
    connection.deploy()         # Let DeploymentError propagate
```

### ❌ DON'T: Swallow Exceptions Silently

```python
# ❌ TERRIBLE - Silent failure
try:
    data = fetch_data()
except Exception:
    pass  # Error ignored completely!

# ✅ GOOD - At minimum, log it
try:
    data = fetch_data()
except Exception as e:
    logger.warning(f"Could not fetch data: {e}")
    data = get_cached_data()  # Fallback
```

---

## 📊 Quick Reference

### Common Exceptions

| Exception | Common Cause |
|-----------|--------------|
| `IndexError` | Accessing list index that doesn't exist |
| `KeyError` | Accessing dict key that doesn't exist |
| `ValueError` | Invalid value for operation |
| `TypeError` | Wrong type for operation |
| `FileNotFoundError` | File doesn't exist |
| `PermissionError` | No permission to access file |
| `ImportError` | Module cannot be imported |
| `ConnectionError` | Network connection failed |
| `TimeoutError` | Operation timed out |
| `StopIteration` | Iterator has no more items |

### Exception Hierarchy

```
BaseException
├── KeyboardInterrupt
├── SystemExit
└── Exception
    ├── ValueError
    ├── TypeError
    ├── LookupError
    │   ├── IndexError
    │   └── KeyError
    ├── OSError
    │   ├── FileNotFoundError
    │   ├── PermissionError
    │   └── ConnectionError
    └── ... (many more)
```

---

## 🎯 Key Takeaways

✅ **Always handle specific exceptions** - avoid bare `except:`  
✅ **Use `try/except/else/finally`** for complete control  
✅ **Implement retry with exponential backoff** for transient failures  
✅ **Use circuit breakers** to prevent cascade failures  
✅ **Log exceptions with full context** using `logger.exception()`  
✅ **Validate input early** - fail fast  
✅ **Create custom exceptions** for domain-specific errors  
✅ **Use context managers** (`with`) for automatic cleanup  

---

## 🚀 Next Steps

1. **CLI Development** → See [11_cli_click.md](11_cli_click.md)
2. **Web Development** → See [12_devops_web_automation.md](12_devops_web_automation.md)
3. **Practice** → See [practice_09_requests_server_disk.py](practice_09_requests_server_disk.py)

````
