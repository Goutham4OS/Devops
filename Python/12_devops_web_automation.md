````markdown
# 🌐 DevOps Web Development & Automation

## Python for Web Services and Automation

Python is the standard tool for DevOps automation because of its excellent support for:
- Data serialization (JSON, YAML)
- HTTP requests and REST APIs
- Building web services (Flask, FastAPI)
- Infrastructure automation

### The DevOps Data Flow

Almost every DevOps workflow follows this pattern:

```
┌──────────────┐    HTTP/API    ┌──────────────┐    Store     ┌──────────────┐
│  Your Script │ ─────────────→ │   Service    │ ───────────→ │   Database   │
│  (Python)    │ ←───────────── │   (REST)     │ ←─────────── │   or File    │
└──────────────┘    JSON/YAML   └──────────────┘              └──────────────┘
```

**Every step involves data serialization:**
- Config files (YAML) → Python objects → API calls (JSON) → Responses (JSON)

### Why JSON and YAML Dominate DevOps

| Format | Strengths | Common Uses |
|--------|-----------|-------------|
| **JSON** | Fast parsing, universal support, strict syntax | API requests/responses, cloud provider outputs |
| **YAML** | Human-readable, supports comments, less verbose | Kubernetes, Ansible, Docker Compose, CI/CD |

**Rule of thumb:**
- **Machine-to-machine** → JSON (APIs, data interchange)
- **Human-to-machine** → YAML (config files you edit by hand)

---

## 📦 PART 1: Data Serialization Recap

### JSON - The Standard for APIs

JSON is the **fastest textual interchange format** and is natively supported by Python.

```python
import json

# Python → JSON
data = {
    "name": "web-01",
    "ip": "10.0.0.1",
    "ports": [80, 443],
    "active": True,
    "metadata": None
}

json_string = json.dumps(data, indent=2)
print(json_string)

# JSON → Python
parsed = json.loads(json_string)
print(parsed["name"])  # web-01
```

### YAML - The DevOps Standard

YAML is the **"missing battery"** in Python—preferred for DevOps (Ansible, Docker, Kubernetes) but requires the PyYAML library.

```bash
pip install pyyaml
```

```python
import yaml

# Python → YAML
config = {
    "apiVersion": "v1",
    "kind": "Pod",
    "metadata": {"name": "nginx"},
    "spec": {
        "containers": [{
            "name": "nginx",
            "image": "nginx:latest",
            "ports": [{"containerPort": 80}]
        }]
    }
}

yaml_string = yaml.dump(config, default_flow_style=False)
print(yaml_string)

# YAML → Python (ALWAYS use safe_load!)
with open("deployment.yaml", "r") as f:
    k8s_config = yaml.safe_load(f)
```

---

## 📡 PART 2: HTTP Requests with `requests`

The `requests` library is the standard for interacting with REST APIs.

```bash
pip install requests
```

### Basic Requests

```python
import requests

# GET request
response = requests.get("https://api.github.com/users/octocat")
print(response.status_code)  # 200
print(response.json())       # Parsed JSON response

# POST request
data = {"name": "new-server", "region": "us-east-1"}
response = requests.post(
    "https://api.example.com/servers",
    json=data,  # Automatically serializes to JSON
    headers={"Authorization": "Bearer token123"}
)

# Other methods
requests.put(url, json=data)
requests.patch(url, json=data)
requests.delete(url)
```

### Request Parameters

```python
# Query parameters
response = requests.get(
    "https://api.example.com/servers",
    params={"region": "us-east-1", "status": "running"}
)
# URL becomes: https://api.example.com/servers?region=us-east-1&status=running

# Headers
response = requests.get(
    "https://api.example.com/data",
    headers={
        "Authorization": "Bearer token123",
        "Accept": "application/json",
        "X-Custom-Header": "value"
    }
)

# Timeout (always set this!)
response = requests.get(url, timeout=30)  # 30 seconds

# Basic authentication
response = requests.get(url, auth=("username", "password"))
```

### Response Handling

```python
response = requests.get("https://api.example.com/data")

# Status code
print(response.status_code)    # 200, 404, 500, etc.
print(response.ok)             # True if 200-299

# Check for errors
response.raise_for_status()    # Raises HTTPError if 4xx/5xx

# Response body
print(response.text)           # Raw text
print(response.json())         # Parsed JSON
print(response.content)        # Raw bytes

# Headers
print(response.headers)        # Response headers
print(response.headers["Content-Type"])

# Timing
print(response.elapsed.total_seconds())  # Request duration
```

### Session for Multiple Requests

```python
# Use Session for connection pooling and persistent headers
session = requests.Session()
session.headers.update({
    "Authorization": "Bearer token123",
    "Content-Type": "application/json"
})

# All requests use same session
response1 = session.get("https://api.example.com/servers")
response2 = session.get("https://api.example.com/databases")
response3 = session.post("https://api.example.com/deploy", json={...})

# Session keeps cookies automatically
session.cookies  # CookieJar
```

---

## 🔄 PART 3: Resilient Requests

### Why "Just Send a Request" Isn't Enough

In a perfect world:
```python
response = requests.get(url)  # Always works!
```

In the real world:
- Networks have latency and packet loss
- Services restart during deployments
- Load balancers return 503 during scaling
- Rate limits kick in during peak usage
- DNS occasionally fails to resolve

**Production-ready code must handle these realities.**

### The Three Pillars of Resilience

```
┌────────────────┐   ┌────────────────┐   ┌────────────────┐
│    TIMEOUTS     │   │     RETRIES    │   │ CIRCUIT BREAKER│
├────────────────┤   ├────────────────┤   ├────────────────┤
│ Don't wait      │   │ Try again on   │   │ Stop calling   │
│ forever for a   │   │ transient      │   │ a dead service │
│ dead service    │   │ failures       │   │ immediately    │
└────────────────┘   └────────────────┘   └────────────────┘
```

### Retry with Exponential Backoff

Robust automation scripts must include **retry mechanisms** with exponential backoff.

```python
import time
import logging
import requests
from requests.exceptions import RequestException

logger = logging.getLogger(__name__)

def resilient_request(
    method: str,
    url: str,
    max_retries: int = 5,
    base_delay: float = 1.0,
    max_delay: float = 60.0,
    **kwargs
):
    """
    Make HTTP request with exponential backoff retry
    
    Args:
        method: HTTP method (GET, POST, etc.)
        url: Request URL
        max_retries: Maximum retry attempts
        base_delay: Initial delay between retries
        max_delay: Maximum delay between retries
        **kwargs: Additional arguments for requests
    
    Returns:
        Response object
    
    Raises:
        RequestException: If all retries fail
    """
    # Always set a timeout
    kwargs.setdefault("timeout", 30)
    
    last_exception = None
    
    for attempt in range(1, max_retries + 1):
        try:
            logger.debug(f"Request attempt {attempt}: {method} {url}")
            
            response = requests.request(method, url, **kwargs)
            response.raise_for_status()
            
            logger.info(f"Request successful: {response.status_code}")
            return response
            
        except RequestException as e:
            last_exception = e
            
            if attempt == max_retries:
                logger.error(f"All {max_retries} attempts failed")
                raise
            
            # Exponential backoff: 1s, 2s, 4s, 8s, ...
            delay = min(base_delay * (2 ** (attempt - 1)), max_delay)
            
            logger.warning(
                f"Attempt {attempt} failed: {e}. "
                f"Retrying in {delay:.1f}s..."
            )
            time.sleep(delay)
    
    raise last_exception

# Usage
try:
    response = resilient_request(
        "GET",
        "https://api.example.com/data",
        headers={"Authorization": "Bearer token"}
    )
    data = response.json()
except RequestException as e:
    logger.error(f"Failed to fetch data: {e}")
```

### Using urllib3 Retry Adapter

```python
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

def create_session_with_retries(
    total_retries: int = 5,
    backoff_factor: float = 0.5,
    status_forcelist: tuple = (500, 502, 503, 504)
) -> requests.Session:
    """
    Create session with automatic retry on failure
    """
    session = requests.Session()
    
    retry = Retry(
        total=total_retries,
        backoff_factor=backoff_factor,  # 0.5, 1, 2, 4, 8 seconds
        status_forcelist=status_forcelist,  # Retry on these status codes
        allowed_methods=["HEAD", "GET", "PUT", "DELETE", "OPTIONS", "TRACE"]
    )
    
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    
    return session

# Usage
session = create_session_with_retries()
response = session.get("https://api.example.com/data", timeout=30)
```

### Circuit Breaker for APIs

Prevent cascade failures by stopping requests when a service is down.

```python
import time
from dataclasses import dataclass, field
from typing import Optional
import requests

@dataclass
class APICircuitBreaker:
    """
    Circuit breaker for API calls
    
    States:
    - CLOSED: Normal, making requests
    - OPEN: Too many failures, rejecting requests
    - HALF_OPEN: Testing if service recovered
    """
    failure_threshold: int = 5
    recovery_timeout: float = 30.0
    
    _failure_count: int = field(default=0, repr=False)
    _last_failure_time: float = field(default=0, repr=False)
    _state: str = field(default="CLOSED", repr=False)
    
    @property
    def is_open(self) -> bool:
        if self._state == "OPEN":
            if time.time() - self._last_failure_time > self.recovery_timeout:
                self._state = "HALF_OPEN"
                return False
            return True
        return False
    
    def record_success(self):
        self._failure_count = 0
        self._state = "CLOSED"
    
    def record_failure(self):
        self._failure_count += 1
        self._last_failure_time = time.time()
        
        if self._failure_count >= self.failure_threshold:
            self._state = "OPEN"
    
    def request(
        self,
        method: str,
        url: str,
        **kwargs
    ) -> Optional[requests.Response]:
        """Make request through circuit breaker"""
        
        if self.is_open:
            raise CircuitBreakerOpenError(
                f"Circuit open. Retry after {self.recovery_timeout}s"
            )
        
        try:
            response = requests.request(method, url, timeout=30, **kwargs)
            response.raise_for_status()
            self.record_success()
            return response
            
        except requests.RequestException as e:
            self.record_failure()
            raise

class CircuitBreakerOpenError(Exception):
    """Raised when circuit breaker is open"""
    pass

# Usage
api_breaker = APICircuitBreaker(failure_threshold=3, recovery_timeout=60)

try:
    response = api_breaker.request("GET", "https://api.example.com/health")
except CircuitBreakerOpenError:
    # Use cached data or return error
    print("Service unavailable, using cached data")
except requests.RequestException:
    print("Request failed, circuit breaker tracking")
```

---

## 🏗️ PART 4: Flask - Quick REST APIs

Flask is the classic choice for building REST APIs quickly.

### When to Choose Flask

Flask follows the "micro-framework" philosophy—it gives you the basics and lets you add what you need:

| Use Flask When... | Because... |
|-------------------|------------|
| Building a simple internal API | Minimal setup, quick to start |
| You need maximum flexibility | No opinions, add any extension |
| Team knows Flask already | Familiarity speeds development |
| Prototyping/MVPs | Get something working fast |

**Flask's philosophy:** "Here's the minimum. Add what you need."

```bash
pip install flask
```

### Basic Flask API

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

# In-memory storage
servers = []

@app.route("/")
def index():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "service": "server-api"})

@app.route("/servers", methods=["GET"])
def list_servers():
    """List all servers"""
    return jsonify({"servers": servers})

@app.route("/servers", methods=["POST"])
def create_server():
    """Create a new server"""
    data = request.get_json()
    
    if not data or "name" not in data:
        return jsonify({"error": "name is required"}), 400
    
    server = {
        "id": len(servers) + 1,
        "name": data["name"],
        "ip": data.get("ip", "0.0.0.0"),
        "status": "stopped"
    }
    servers.append(server)
    
    return jsonify(server), 201

@app.route("/servers/<int:server_id>", methods=["GET"])
def get_server(server_id):
    """Get a specific server"""
    server = next((s for s in servers if s["id"] == server_id), None)
    
    if not server:
        return jsonify({"error": "Server not found"}), 404
    
    return jsonify(server)

@app.route("/servers/<int:server_id>", methods=["DELETE"])
def delete_server(server_id):
    """Delete a server"""
    global servers
    original_count = len(servers)
    servers = [s for s in servers if s["id"] != server_id]
    
    if len(servers) == original_count:
        return jsonify({"error": "Server not found"}), 404
    
    return "", 204

if __name__ == "__main__":
    app.run(debug=True, port=5000)
```

### Flask with Error Handling

```python
from flask import Flask, request, jsonify
from functools import wraps
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Error handlers
@app.errorhandler(400)
def bad_request(error):
    return jsonify({"error": "Bad request", "message": str(error)}), 400

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Not found"}), 404

@app.errorhandler(500)
def internal_error(error):
    logger.exception("Internal server error")
    return jsonify({"error": "Internal server error"}), 500

# Request logging decorator
def log_request(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        logger.info(f"{request.method} {request.path}")
        response = f(*args, **kwargs)
        return response
    return decorated

@app.route("/api/deploy", methods=["POST"])
@log_request
def deploy():
    data = request.get_json()
    
    if not data:
        return jsonify({"error": "JSON body required"}), 400
    
    required_fields = ["service", "version", "environment"]
    missing = [f for f in required_fields if f not in data]
    
    if missing:
        return jsonify({
            "error": "Missing required fields",
            "missing": missing
        }), 400
    
    # Process deployment...
    logger.info(f"Deploying {data['service']} v{data['version']}")
    
    return jsonify({
        "status": "success",
        "message": f"Deployed {data['service']} v{data['version']} to {data['environment']}"
    })
```

---

## ⚡ PART 5: FastAPI - Modern High-Performance APIs

FastAPI provides a modern, high-performance environment with automatic validation and documentation.

### When to Choose FastAPI

| Use FastAPI When... | Because... |
|---------------------|------------|
| Building production APIs | Type safety, auto-validation, great docs |
| Performance matters | Async support, one of the fastest Python frameworks |
| Team uses type hints | Leverages Python's type system |
| You want auto-documentation | Swagger/OpenAPI generated for free |

**FastAPI's philosophy:** "Modern Python features + best practices = developer happiness."

### FastAPI's Killer Features

1. **Automatic validation**: Pydantic models validate requests/responses
2. **Auto-generated docs**: Visit `/docs` for interactive Swagger UI
3. **Async native**: Use `async/await` for concurrent operations
4. **Type hints required**: Catch errors before runtime
5. **Dependency injection**: Clean, testable code structure

```bash
pip install fastapi uvicorn
```

### Basic FastAPI

```python
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

app = FastAPI(
    title="Server Management API",
    description="API for managing infrastructure",
    version="1.0.0"
)

# Pydantic models for validation
class ServerCreate(BaseModel):
    name: str
    ip: str
    port: int = 8080
    tags: Optional[List[str]] = []

class ServerResponse(BaseModel):
    id: int
    name: str
    ip: str
    port: int
    status: str
    created_at: datetime
    tags: List[str]

class ServerUpdate(BaseModel):
    name: Optional[str] = None
    ip: Optional[str] = None
    port: Optional[int] = None
    status: Optional[str] = None

# In-memory storage
servers_db: List[dict] = []

@app.get("/")
async def root():
    """Health check"""
    return {"status": "healthy", "service": "server-api"}

@app.get("/servers", response_model=List[ServerResponse])
async def list_servers(
    status: Optional[str] = None,
    tag: Optional[str] = None
):
    """List all servers with optional filters"""
    result = servers_db
    
    if status:
        result = [s for s in result if s["status"] == status]
    
    if tag:
        result = [s for s in result if tag in s.get("tags", [])]
    
    return result

@app.post("/servers", response_model=ServerResponse, status_code=201)
async def create_server(server: ServerCreate):
    """Create a new server"""
    new_server = {
        "id": len(servers_db) + 1,
        **server.dict(),
        "status": "stopped",
        "created_at": datetime.now()
    }
    servers_db.append(new_server)
    return new_server

@app.get("/servers/{server_id}", response_model=ServerResponse)
async def get_server(server_id: int):
    """Get server by ID"""
    server = next((s for s in servers_db if s["id"] == server_id), None)
    
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    
    return server

@app.patch("/servers/{server_id}", response_model=ServerResponse)
async def update_server(server_id: int, update: ServerUpdate):
    """Update server properties"""
    server = next((s for s in servers_db if s["id"] == server_id), None)
    
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    
    update_data = update.dict(exclude_unset=True)
    server.update(update_data)
    
    return server

@app.delete("/servers/{server_id}", status_code=204)
async def delete_server(server_id: int):
    """Delete a server"""
    global servers_db
    original_count = len(servers_db)
    servers_db = [s for s in servers_db if s["id"] != server_id]
    
    if len(servers_db) == original_count:
        raise HTTPException(status_code=404, detail="Server not found")

@app.post("/servers/{server_id}/start")
async def start_server(server_id: int):
    """Start a server"""
    server = next((s for s in servers_db if s["id"] == server_id), None)
    
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    
    if server["status"] == "running":
        raise HTTPException(status_code=400, detail="Server already running")
    
    server["status"] = "running"
    return {"message": f"Server {server['name']} started"}

# Run with: uvicorn main:app --reload
```

### FastAPI with Dependency Injection

```python
from fastapi import FastAPI, Depends, HTTPException, Header
from typing import Optional
import logging

app = FastAPI()
logger = logging.getLogger(__name__)

# Dependency for authentication
async def verify_token(authorization: Optional[str] = Header(None)):
    if not authorization:
        raise HTTPException(status_code=401, detail="Authorization header required")
    
    if not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Invalid authorization format")
    
    token = authorization.replace("Bearer ", "")
    
    # Validate token (simplified)
    if token != "valid-token":
        raise HTTPException(status_code=401, detail="Invalid token")
    
    return token

# Dependency for logging
async def log_request():
    logger.info("Request received")
    yield
    logger.info("Request completed")

@app.get("/protected", dependencies=[Depends(log_request)])
async def protected_route(token: str = Depends(verify_token)):
    """Protected endpoint requiring authentication"""
    return {"message": "Access granted", "token_valid": True}
```

### FastAPI Automatic Documentation

FastAPI generates interactive API documentation automatically:

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **OpenAPI JSON**: `http://localhost:8000/openapi.json`

---

## 📊 PART 6: Complete DevOps API Example

```python
"""
Complete DevOps API with FastAPI
Run with: uvicorn devops_api:app --reload
"""
from fastapi import FastAPI, HTTPException, BackgroundTasks, Query
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum
import logging
import asyncio

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="DevOps Platform API",
    description="Complete API for infrastructure management",
    version="2.0.0"
)

# ========== ENUMS ==========
class ServerStatus(str, Enum):
    STOPPED = "stopped"
    STARTING = "starting"
    RUNNING = "running"
    STOPPING = "stopping"
    ERROR = "error"

class DeploymentStatus(str, Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    SUCCESS = "success"
    FAILED = "failed"
    ROLLED_BACK = "rolled_back"

# ========== MODELS ==========
class ServerBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=50)
    ip: str
    port: int = Field(default=8080, ge=1, le=65535)
    region: str = "us-east-1"
    tags: Dict[str, str] = {}

class ServerCreate(ServerBase):
    pass

class ServerResponse(ServerBase):
    id: int
    status: ServerStatus
    cpu_percent: float = 0.0
    memory_percent: float = 0.0
    created_at: datetime
    updated_at: datetime

class DeploymentCreate(BaseModel):
    service: str
    version: str
    environment: str
    replicas: int = Field(default=2, ge=1, le=100)
    config: Dict[str, Any] = {}

class DeploymentResponse(BaseModel):
    id: int
    service: str
    version: str
    environment: str
    replicas: int
    status: DeploymentStatus
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    message: Optional[str]

# ========== DATABASE (In-Memory) ==========
servers_db: List[dict] = []
deployments_db: List[dict] = []

# ========== BACKGROUND TASKS ==========
async def simulate_deployment(deployment_id: int):
    """Simulate deployment process"""
    deployment = next(
        (d for d in deployments_db if d["id"] == deployment_id), None
    )
    
    if not deployment:
        return
    
    deployment["status"] = DeploymentStatus.IN_PROGRESS
    deployment["started_at"] = datetime.now()
    
    logger.info(f"Starting deployment {deployment_id}")
    
    # Simulate deployment time
    await asyncio.sleep(5)
    
    # 90% success rate
    import random
    if random.random() < 0.9:
        deployment["status"] = DeploymentStatus.SUCCESS
        deployment["message"] = "Deployment completed successfully"
    else:
        deployment["status"] = DeploymentStatus.FAILED
        deployment["message"] = "Deployment failed: health check timeout"
    
    deployment["completed_at"] = datetime.now()
    logger.info(f"Deployment {deployment_id} finished: {deployment['status']}")

# ========== ENDPOINTS ==========
@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "version": "2.0.0"
    }

# ----- Servers -----
@app.get("/api/v1/servers", response_model=List[ServerResponse])
async def list_servers(
    status: Optional[ServerStatus] = None,
    region: Optional[str] = None,
    limit: int = Query(default=100, le=1000),
    offset: int = Query(default=0, ge=0)
):
    """List servers with optional filters"""
    result = servers_db
    
    if status:
        result = [s for s in result if s["status"] == status]
    
    if region:
        result = [s for s in result if s["region"] == region]
    
    return result[offset:offset + limit]

@app.post("/api/v1/servers", response_model=ServerResponse, status_code=201)
async def create_server(server: ServerCreate):
    """Create a new server"""
    now = datetime.now()
    new_server = {
        "id": len(servers_db) + 1,
        **server.dict(),
        "status": ServerStatus.STOPPED,
        "cpu_percent": 0.0,
        "memory_percent": 0.0,
        "created_at": now,
        "updated_at": now
    }
    servers_db.append(new_server)
    logger.info(f"Created server: {new_server['name']}")
    return new_server

@app.get("/api/v1/servers/{server_id}", response_model=ServerResponse)
async def get_server(server_id: int):
    """Get server details"""
    server = next((s for s in servers_db if s["id"] == server_id), None)
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    return server

@app.post("/api/v1/servers/{server_id}/start")
async def start_server(server_id: int, background_tasks: BackgroundTasks):
    """Start a server"""
    server = next((s for s in servers_db if s["id"] == server_id), None)
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    
    if server["status"] == ServerStatus.RUNNING:
        raise HTTPException(status_code=400, detail="Server already running")
    
    server["status"] = ServerStatus.STARTING
    server["updated_at"] = datetime.now()
    
    # Simulate async startup
    async def complete_startup():
        await asyncio.sleep(2)
        server["status"] = ServerStatus.RUNNING
        server["cpu_percent"] = 15.5
        server["memory_percent"] = 32.0
    
    background_tasks.add_task(complete_startup)
    
    return {"message": f"Server {server['name']} is starting"}

@app.post("/api/v1/servers/{server_id}/stop")
async def stop_server(server_id: int):
    """Stop a server"""
    server = next((s for s in servers_db if s["id"] == server_id), None)
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")
    
    if server["status"] == ServerStatus.STOPPED:
        raise HTTPException(status_code=400, detail="Server already stopped")
    
    server["status"] = ServerStatus.STOPPED
    server["cpu_percent"] = 0.0
    server["memory_percent"] = 0.0
    server["updated_at"] = datetime.now()
    
    return {"message": f"Server {server['name']} stopped"}

# ----- Deployments -----
@app.get("/api/v1/deployments", response_model=List[DeploymentResponse])
async def list_deployments(
    status: Optional[DeploymentStatus] = None,
    environment: Optional[str] = None
):
    """List deployments"""
    result = deployments_db
    
    if status:
        result = [d for d in result if d["status"] == status]
    
    if environment:
        result = [d for d in result if d["environment"] == environment]
    
    return result

@app.post("/api/v1/deployments", response_model=DeploymentResponse, status_code=201)
async def create_deployment(
    deployment: DeploymentCreate,
    background_tasks: BackgroundTasks
):
    """Create a new deployment"""
    new_deployment = {
        "id": len(deployments_db) + 1,
        **deployment.dict(),
        "status": DeploymentStatus.PENDING,
        "started_at": None,
        "completed_at": None,
        "message": None
    }
    deployments_db.append(new_deployment)
    
    # Start deployment in background
    background_tasks.add_task(simulate_deployment, new_deployment["id"])
    
    logger.info(
        f"Created deployment: {deployment.service} v{deployment.version} "
        f"to {deployment.environment}"
    )
    
    return new_deployment

@app.get("/api/v1/deployments/{deployment_id}", response_model=DeploymentResponse)
async def get_deployment(deployment_id: int):
    """Get deployment status"""
    deployment = next(
        (d for d in deployments_db if d["id"] == deployment_id), None
    )
    if not deployment:
        raise HTTPException(status_code=404, detail="Deployment not found")
    return deployment

@app.post("/api/v1/deployments/{deployment_id}/rollback")
async def rollback_deployment(deployment_id: int):
    """Rollback a deployment"""
    deployment = next(
        (d for d in deployments_db if d["id"] == deployment_id), None
    )
    if not deployment:
        raise HTTPException(status_code=404, detail="Deployment not found")
    
    if deployment["status"] not in [DeploymentStatus.SUCCESS, DeploymentStatus.FAILED]:
        raise HTTPException(
            status_code=400,
            detail="Can only rollback completed deployments"
        )
    
    deployment["status"] = DeploymentStatus.ROLLED_BACK
    deployment["message"] = "Rolled back to previous version"
    
    return {"message": "Rollback initiated"}

# ========== RUN ==========
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

---

## 📊 Quick Reference

### Flask vs FastAPI

| Feature | Flask | FastAPI |
|---------|-------|---------|
| Speed | Slower | Very fast (async) |
| Validation | Manual | Automatic (Pydantic) |
| Documentation | Manual | Auto-generated |
| Type hints | Optional | Required |
| Async support | Limited | Native |
| Learning curve | Gentler | Slightly steeper |
| Best for | Simple APIs | Production APIs |

### HTTP Status Codes

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 | OK | Successful GET/PUT |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Invalid input |
| 401 | Unauthorized | Missing/invalid auth |
| 403 | Forbidden | Not allowed |
| 404 | Not Found | Resource doesn't exist |
| 500 | Server Error | Something broke |

---

## 🎯 Key Takeaways

✅ **Use `requests` library** for HTTP clients  
✅ **Always set timeouts** on HTTP requests  
✅ **Implement retry with exponential backoff** for resilience  
✅ **Use circuit breakers** to prevent cascade failures  
✅ **Flask** for quick, simple APIs  
✅ **FastAPI** for production with auto-validation and docs  
✅ **Use Pydantic models** for request/response validation  
✅ **Background tasks** for long-running operations  

---

## 🚀 Next Steps

1. **Practice**: Build your own API!
2. **Deploy**: See practice files for Docker examples
3. **See also**:
   - [practice_06_api_development.py](practice_06_api_development.py)
   - [practice_07_fastapi.py](practice_07_fastapi.py)
   - [practice_09_requests_server_disk.py](practice_09_requests_server_disk.py)

````
