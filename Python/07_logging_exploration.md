
# 📝 Logging in Python - The Built-in "Batteries"

## Why Logging Over Print?

In DevOps, `print()` statements are fine for quick debugging but **terrible for production**. Here's why logging is essential:

### The Problem with Print Statements

When you write `print("Server started")`, it seems harmless. But in production:

1. **No timestamps** - When did this happen? You have no idea.
2. **No severity** - Is "Connection failed" a warning or a critical failure?
3. **No filtering** - You can't turn off debug messages without editing code.
4. **Lost output** - If your script runs as a service, stdout may go nowhere.
5. **No rotation** - Logs grow forever until your disk fills up.

The `logging` module solves all of these problems with minimal extra effort.

| Feature | `print()` | `logging` |
|---------|-----------|-----------|
| Severity levels | ❌ | ✅ DEBUG, INFO, WARNING, ERROR, CRITICAL |
| Timestamps | ❌ Manual | ✅ Automatic |
| Output destinations | ❌ stdout only | ✅ File, console, network, etc. |
| Filtering | ❌ None | ✅ By level, module, etc. |
| Production ready | ❌ | ✅ |
| Performance | ❌ Always executes | ✅ Can disable by level |
| Context info | ❌ Manual | ✅ Module, line, function |

---

## 📦 PART 1: Basic Logging

### Quick Start

```python
import logging

# Basic configuration (do this ONCE at start of program)
logging.basicConfig(level=logging.INFO)

# Now you can log!
logging.debug("This won't show (DEBUG < INFO)")
logging.info("Application started")
logging.warning("This is a warning")
logging.error("Something went wrong")
logging.critical("System is down!")
```

**Output:**
```
INFO:root:Application started
WARNING:root:This is a warning
ERROR:root:Something went wrong
CRITICAL:root:System is down!
```

---

### Logging Levels (Severity)

Think of logging levels like a **volume knob** for your application's verbosity. In development, you want to hear everything (DEBUG). In production, you only want to hear important things (WARNING and above).

The levels form a hierarchy—setting a level means you see that level **and everything more severe**:

```
DEBUG → INFO → WARNING → ERROR → CRITICAL
  ↑                                    ↑
 Most verbose                    Most critical
 (development)                   (production)
```

| Level | Numeric | When to Use |
|-------|---------|-------------|
| `DEBUG` | 10 | Detailed diagnostic info (development only) |
| `INFO` | 20 | Confirmation that things work as expected |
| `WARNING` | 30 | Something unexpected, but not an error |
| `ERROR` | 40 | Serious problem, function couldn't execute |
| `CRITICAL` | 50 | Critical error, program may crash |

**Real-world guidance:**
- **DEBUG**: Variable values, loop iterations, function entry/exit
- **INFO**: "Deployment started", "Connected to database", "Job completed"
- **WARNING**: "Disk at 80%", "Deprecated API used", "Retry attempt 2/5"
- **ERROR**: "Cannot connect to database", "File not found", "API returned 500"
- **CRITICAL**: "Out of memory", "Security breach", "Data corruption detected"

```python
import logging

logging.basicConfig(level=logging.DEBUG)

# All levels in order of severity
logging.debug("Checking configuration...")
logging.info("Server started on port 8080")
logging.warning("Disk usage is at 85%")
logging.error("Failed to connect to database")
logging.critical("Security breach detected!")

# Setting level filters messages
# level=INFO means DEBUG messages won't appear
# level=WARNING means DEBUG and INFO won't appear
```

---

### Adding Format and Timestamps

```python
import logging

# Custom format
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

logging.info("Application started")
logging.warning("Low memory")
```

**Output:**
```
2026-01-14 10:30:45 - INFO - Application started
2026-01-14 10:30:45 - WARNING - Low memory
```

### Available Format Fields

| Field | Description | Example |
|-------|-------------|---------|
| `%(asctime)s` | Human-readable time | `2026-01-14 10:30:45` |
| `%(levelname)s` | Level name | `INFO`, `ERROR` |
| `%(message)s` | The log message | Your message |
| `%(name)s` | Logger name | `root`, `myapp` |
| `%(filename)s` | Source filename | `app.py` |
| `%(funcName)s` | Function name | `main` |
| `%(lineno)d` | Line number | `42` |
| `%(module)s` | Module name | `app` |
| `%(process)d` | Process ID | `12345` |
| `%(thread)d` | Thread ID | `67890` |

---

## 📝 PART 2: Logging to Files

### Basic File Logging

```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(name)s - %(message)s',
    filename='application.log',  # Log to file
    filemode='a'  # 'a' = append, 'w' = overwrite
)

logging.info("Application started")
logging.error("Database connection failed")
```

### Logging to Both Console AND File

```python
import logging

# Create logger
logger = logging.getLogger('my_app')
logger.setLevel(logging.DEBUG)

# Create formatters
file_formatter = logging.Formatter(
    '%(asctime)s - %(levelname)s - %(funcName)s:%(lineno)d - %(message)s'
)
console_formatter = logging.Formatter(
    '%(levelname)s: %(message)s'
)

# File handler (detailed logs)
file_handler = logging.FileHandler('detailed.log')
file_handler.setLevel(logging.DEBUG)
file_handler.setFormatter(file_formatter)

# Console handler (important logs only)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.WARNING)
console_handler.setFormatter(console_formatter)

# Add handlers to logger
logger.addHandler(file_handler)
logger.addHandler(console_handler)

# Usage
logger.debug("Detailed debug info")      # File only
logger.info("Server started")             # File only
logger.warning("Disk usage high")         # Both
logger.error("Connection failed")         # Both
```

---

## 🔄 PART 3: RotatingFileHandler (Production Ready)

For long-running applications, log files can grow too large. Use `RotatingFileHandler` to automatically manage log files.

### Why Log Rotation Matters

Imagine a deployment script that logs every action. After a year:
- Without rotation: One 50GB log file that crashes your editor and fills your disk
- With rotation: Five 10MB files, automatically managed, easy to search

Log rotation is **essential** for any production application. There are two strategies:

| Strategy | Best For | How It Works |
|----------|----------|---------------|
| **Size-based** | High-volume logging | Rotates when file reaches size limit |
| **Time-based** | Compliance/auditing | Rotates at scheduled intervals (daily, weekly) |

### Size-Based Rotation

```python
import logging
from logging.handlers import RotatingFileHandler

# Create logger
logger = logging.getLogger('production_app')
logger.setLevel(logging.INFO)

# Rotating handler: max 5MB per file, keep 3 backup files
handler = RotatingFileHandler(
    'app.log',
    maxBytes=5*1024*1024,  # 5 MB
    backupCount=3           # Keep app.log.1, app.log.2, app.log.3
)

formatter = logging.Formatter(
    '%(asctime)s - %(levelname)s - %(message)s'
)
handler.setFormatter(formatter)
logger.addHandler(handler)

# When app.log reaches 5MB:
# 1. app.log.2 → app.log.3
# 2. app.log.1 → app.log.2
# 3. app.log   → app.log.1
# 4. New empty app.log created
```

### Time-Based Rotation

```python
import logging
from logging.handlers import TimedRotatingFileHandler

logger = logging.getLogger('daily_logs')
logger.setLevel(logging.INFO)

# Rotate at midnight, keep 30 days of logs
handler = TimedRotatingFileHandler(
    'app.log',
    when='midnight',      # Rotate at midnight
    interval=1,           # Every 1 day
    backupCount=30        # Keep 30 days
)

# File naming: app.log.2026-01-14, app.log.2026-01-13, etc.
handler.suffix = "%Y-%m-%d"

formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
```

**Rotation options for `when`:**
| Value | Interval |
|-------|----------|
| `S` | Seconds |
| `M` | Minutes |
| `H` | Hours |
| `D` | Days |
| `midnight` | At midnight |
| `W0`-`W6` | Weekday (0=Monday) |

---

## 🔍 PART 4: Exploring Modules with dir() and help()

One of Python's greatest strengths is its **introspection** capabilities—the ability to examine objects at runtime. This is incredibly useful when:

- Learning a new library without leaving your terminal
- Debugging unexpected behavior
- Understanding what methods are available
- Writing documentation or tutorials

Think of `dir()` as asking "What can you do?" and `help()` as asking "How do you do it?"

```
┌─────────────────────────────────────────────────────────┐
│  Your Exploration Toolkit                               │
├─────────────────────────────────────────────────────────┤
│  dir(obj)     →  List all attributes and methods       │
│  help(obj)    →  Show documentation and examples       │
│  type(obj)    →  What class is this object?            │
│  hasattr()    →  Does this attribute exist?            │
│  inspect      →  Deep dive into signatures & source    │
└─────────────────────────────────────────────────────────┘
```

### Using `dir()` to List Attributes

```python
import logging

# See everything in logging module
print(dir(logging))
# ['BASIC_FORMAT', 'BufferingFormatter', 'CRITICAL', 'DEBUG', 'ERROR',
#  'FileHandler', 'Filter', 'Formatter', 'Handler', 'INFO', ...]

# See methods on a logger
logger = logging.getLogger()
print(dir(logger))
# ['addFilter', 'addHandler', 'critical', 'debug', 'error', 'exception',
#  'fatal', 'getChild', 'getEffectiveLevel', 'handle', 'hasHandlers', ...]

# Filter to show only public methods
public_methods = [m for m in dir(logger) if not m.startswith('_')]
print(public_methods)
```

### Using `help()` for Documentation

```python
import logging

# Help for entire module (very long!)
help(logging)

# Help for specific function
help(logging.basicConfig)
# Shows parameters, description, examples

# Help for a class
help(logging.FileHandler)

# Help for a method
help(logging.Logger.setLevel)
```

### Quick Exploration Pattern

```python
import logging

# 1. What's available?
print("Available in module:", [x for x in dir(logging) if not x.startswith('_')])

# 2. What does something do?
print(logging.DEBUG)  # 10 (see the value)
print(type(logging.FileHandler))  # <class 'type'> (it's a class)

# 3. Get detailed help
help(logging.Formatter)

# 4. Try it!
formatter = logging.Formatter('%(levelname)s: %(message)s')
print(formatter.format(logging.LogRecord('test', logging.INFO, '', 0, 'Hello', None, None)))
```

---

## 🏗️ PART 5: Logger Hierarchy and Best Practices

### Named Loggers (Recommended)

```python
import logging

# Create named logger (use module name)
logger = logging.getLogger(__name__)

# Or use explicit name for clarity
db_logger = logging.getLogger('myapp.database')
api_logger = logging.getLogger('myapp.api')
auth_logger = logging.getLogger('myapp.auth')

# Loggers form a hierarchy:
# root
# └── myapp
#     ├── myapp.database
#     ├── myapp.api
#     └── myapp.auth
```

### Complete Production Setup

```python
import logging
import logging.handlers
import os
from datetime import datetime

def setup_logging(
    log_dir: str = 'logs',
    log_level: str = 'INFO',
    app_name: str = 'application'
):
    """
    Configure production-ready logging
    
    Args:
        log_dir: Directory for log files
        log_level: Minimum log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        app_name: Name for log files
    """
    # Create logs directory
    os.makedirs(log_dir, exist_ok=True)
    
    # Get numeric level
    numeric_level = getattr(logging, log_level.upper(), logging.INFO)
    
    # Create root logger
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)  # Capture all, filter at handler level
    
    # Clear existing handlers
    logger.handlers.clear()
    
    # === FILE HANDLER: All logs ===
    file_formatter = logging.Formatter(
        '%(asctime)s | %(levelname)-8s | %(name)s | %(funcName)s:%(lineno)d | %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    file_handler = logging.handlers.RotatingFileHandler(
        os.path.join(log_dir, f'{app_name}.log'),
        maxBytes=10*1024*1024,  # 10 MB
        backupCount=5
    )
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(file_formatter)
    logger.addHandler(file_handler)
    
    # === ERROR FILE HANDLER: Errors only ===
    error_handler = logging.handlers.RotatingFileHandler(
        os.path.join(log_dir, f'{app_name}_errors.log'),
        maxBytes=10*1024*1024,
        backupCount=5
    )
    error_handler.setLevel(logging.ERROR)
    error_handler.setFormatter(file_formatter)
    logger.addHandler(error_handler)
    
    # === CONSOLE HANDLER: Info and above ===
    console_formatter = logging.Formatter(
        '%(asctime)s | %(levelname)-8s | %(message)s',
        datefmt='%H:%M:%S'
    )
    
    console_handler = logging.StreamHandler()
    console_handler.setLevel(numeric_level)
    console_handler.setFormatter(console_formatter)
    logger.addHandler(console_handler)
    
    # Log initialization
    logging.info(f"Logging initialized: level={log_level}, dir={log_dir}")
    
    return logger

# Usage
if __name__ == "__main__":
    setup_logging(log_level='DEBUG', app_name='devops_tool')
    
    logger = logging.getLogger(__name__)
    logger.debug("Debug message - shows in file only")
    logger.info("Info message - shows everywhere")
    logger.warning("Warning message")
    logger.error("Error message - also in errors.log")
```

---

## 🛠️ PART 6: Real DevOps Examples

### Example 1: Deployment Script Logging

```python
import logging
from datetime import datetime

# Setup
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s | %(levelname)s | %(message)s',
    handlers=[
        logging.FileHandler(f'deploy_{datetime.now():%Y%m%d_%H%M%S}.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger('deployer')

def deploy_service(service_name: str, version: str, environment: str):
    """Deploy a service with proper logging"""
    
    logger.info(f"Starting deployment: {service_name} v{version} to {environment}")
    
    try:
        # Pre-deployment checks
        logger.debug(f"Checking prerequisites for {service_name}")
        
        # Stop current version
        logger.info(f"Stopping current {service_name} instance")
        
        # Deploy new version
        logger.info(f"Deploying {service_name} v{version}")
        
        # Health check
        logger.info("Running health checks")
        
        # Success
        logger.info(f"✅ Deployment successful: {service_name} v{version}")
        
    except Exception as e:
        logger.error(f"❌ Deployment failed: {e}")
        logger.exception("Full traceback:")  # Logs exception with traceback
        raise

# Run deployment
deploy_service("api-gateway", "2.1.0", "production")
```

### Example 2: Server Health Monitor

```python
import logging
import time
from logging.handlers import RotatingFileHandler

# Setup rotating logs
logger = logging.getLogger('health_monitor')
logger.setLevel(logging.INFO)

handler = RotatingFileHandler(
    'health_monitor.log',
    maxBytes=5*1024*1024,
    backupCount=7  # Keep a week of logs
)
handler.setFormatter(logging.Formatter(
    '%(asctime)s | %(levelname)s | %(message)s'
))
logger.addHandler(handler)

def check_server_health(server_name: str) -> dict:
    """Check server and log results"""
    logger.info(f"Checking health: {server_name}")
    
    # Simulate health check
    health = {
        'server': server_name,
        'cpu': 75.5,
        'memory': 60.2,
        'disk': 45.0,
        'status': 'healthy'
    }
    
    # Log based on thresholds
    if health['cpu'] > 90:
        logger.critical(f"{server_name}: CPU critical at {health['cpu']}%")
    elif health['cpu'] > 80:
        logger.warning(f"{server_name}: CPU high at {health['cpu']}%")
    else:
        logger.debug(f"{server_name}: CPU normal at {health['cpu']}%")
    
    if health['disk'] > 90:
        logger.error(f"{server_name}: Disk nearly full at {health['disk']}%")
    
    return health

# Monitor loop
servers = ['web-01', 'web-02', 'db-01']
for server in servers:
    check_server_health(server)
```

### Example 3: API Client with Logging

```python
import logging
import requests
from typing import Optional

logger = logging.getLogger('api_client')

class APIClient:
    """HTTP client with comprehensive logging"""
    
    def __init__(self, base_url: str, timeout: int = 30):
        self.base_url = base_url
        self.timeout = timeout
        self.session = requests.Session()
        logger.info(f"API client initialized: {base_url}")
    
    def get(self, endpoint: str) -> Optional[dict]:
        """Make GET request with logging"""
        url = f"{self.base_url}{endpoint}"
        logger.debug(f"GET request to: {url}")
        
        try:
            response = self.session.get(url, timeout=self.timeout)
            
            logger.info(
                f"GET {endpoint} - Status: {response.status_code} - "
                f"Time: {response.elapsed.total_seconds():.2f}s"
            )
            
            if response.status_code >= 400:
                logger.error(f"Request failed: {response.status_code} - {response.text}")
                return None
            
            return response.json()
            
        except requests.Timeout:
            logger.error(f"Request timeout after {self.timeout}s: {url}")
            raise
        except requests.RequestException as e:
            logger.exception(f"Request failed: {e}")
            raise
    
    def post(self, endpoint: str, data: dict) -> Optional[dict]:
        """Make POST request with logging"""
        url = f"{self.base_url}{endpoint}"
        logger.debug(f"POST request to: {url}, data: {data}")
        
        try:
            response = self.session.post(url, json=data, timeout=self.timeout)
            
            logger.info(
                f"POST {endpoint} - Status: {response.status_code} - "
                f"Time: {response.elapsed.total_seconds():.2f}s"
            )
            
            if response.status_code >= 400:
                logger.error(f"Request failed: {response.status_code}")
                return None
            
            return response.json()
            
        except Exception as e:
            logger.exception(f"POST request failed: {e}")
            raise
```

---

## 📊 Quick Reference

### Basic Setup

```python
import logging

# Quick setup
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Log messages
logging.debug("Detailed info")    # Level 10
logging.info("General info")      # Level 20
logging.warning("Warning")        # Level 30
logging.error("Error occurred")   # Level 40
logging.critical("Critical!")     # Level 50
```

### File Logging

```python
# Simple file logging
logging.basicConfig(filename='app.log', level=logging.INFO)

# Rotating file handler
from logging.handlers import RotatingFileHandler
handler = RotatingFileHandler('app.log', maxBytes=5*1024*1024, backupCount=3)
```

### Module Exploration

```python
# List what's in a module
dir(some_module)

# Get documentation
help(some_function)

# Check type
type(some_object)
```

---

## 🎯 Key Takeaways

✅ **Use logging, not print()** for production code  
✅ **Choose appropriate levels**: DEBUG < INFO < WARNING < ERROR < CRITICAL  
✅ **Use RotatingFileHandler** to prevent disk space issues  
✅ **Include timestamps and context** in log format  
✅ **Use named loggers** (`__name__`) for better organization  
✅ **Log exceptions with `logger.exception()`** for full tracebacks  
✅ **Use `dir()` and `help()`** to explore modules  

---

## 🚀 Next Steps
 [08_azure_devops_modules](08_azure_devops_modules.md)



````
