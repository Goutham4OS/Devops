
# 🎯 Core Philosophy: "Everything is an Object" in Python

## Understanding Python's Fundamental Principle

Python is built on one fundamental principle that sets it apart from many other programming languages: **Everything is an object**. This means every value—including integers, strings, functions, and even classes themselves—is an instance of a class with its own state (data) and behavior (methods).

### Why Does This Matter?

Understanding this principle changes how you think about Python code:

1. **Consistency** - The same rules apply everywhere. Integers, strings, functions, and classes all behave predictably.

2. **Power** - You can pass functions as arguments, store classes in lists, and create methods dynamically.

3. **Debugging** - When something goes wrong, you can inspect any value with `type()`, `dir()`, and `id()`.

4. **Library Usage** - Understanding objects helps you use libraries like `requests`, `boto3`, and `kubernetes` effectively.

```
┌──────────────────────────────────────────────────────────────┐
│  In Python, EVERYTHING follows the same pattern:             │
│                                                              │
│    42          →  Object of type 'int'                       │
│    "hello"     →  Object of type 'str'                       │
│    [1, 2, 3]   →  Object of type 'list'                      │
│    print       →  Object of type 'builtin_function_or_method'│
│    int         →  Object of type 'type' (a class!)           │
└──────────────────────────────────────────────────────────────┘
```

---

## 🔍 What Does "Everything is an Object" Mean?

### 1. No Primitives - Everything Has Methods

Unlike languages like C, C++, or Java (which have primitives), Python treats **all values** as full-fledged objects.

#### Why Do C/C++/Java Have Primitives?

**Primitives** are basic data types stored directly in memory and manipulated by CPU instructions. They exist for one reason: **raw performance**.

```
┌─────────────────────────────────────────────────────────────────────┐
│  C/C++ Primitive Integer:                                           │
│  ┌──────────────────────┐                                           │
│  │  4 bytes of memory   │  ← Just the number, nothing else          │
│  │  Value: 42           │  ← CPU can add/subtract directly          │
│  └──────────────────────┘  ← No overhead, maximum speed             │
│                                                                     │
│  Python Object Integer:                                             │
│  ┌──────────────────────────────────────────────────────────┐       │
│  │  PyObject Header (16+ bytes)                              │       │
│  │  ├── Reference count (for garbage collection)             │       │
│  │  ├── Type pointer (points to 'int' class)                 │       │
│  │  └── Value: 42                                            │       │
│  └──────────────────────────────────────────────────────────┘       │
│  ↑ More memory, but consistent behavior and rich functionality      │
└─────────────────────────────────────────────────────────────────────┘
```

**The Trade-off:**

| Aspect | Primitives (C/C++/Java) | Objects (Python) |
|--------|-------------------------|------------------|
| Memory | 4-8 bytes per int | 28+ bytes per int |
| Speed | Direct CPU operations | Method dispatch overhead |
| Simplicity | Two systems (primitives + objects) | One unified system |
| Flexibility | Limited operations | Rich methods available |
| Consistency | `int` ≠ `Integer` in Java | Everything works the same |

#### Why Did Python Choose "Everything is an Object"?

Python's creator, Guido van Rossum, prioritized **simplicity and consistency** over raw speed:

1. **One Mental Model**: You don't need to remember "is this a primitive or object?" Everything behaves the same way.

2. **No Boxing/Unboxing**: In Java, converting between `int` (primitive) and `Integer` (object) is called boxing. Python doesn't need this complexity.

3. **Everything Has Methods**: Even `42` can have methods like `.bit_length()`. No special cases.

4. **Duck Typing Works Everywhere**: If it walks like a duck and quacks like a duck, it's a duck—even for numbers.

5. **Metaprogramming**: You can inspect, modify, and extend any value because everything is an object.

```
┌─────────────────────────────────────────────────────────────────────┐
│  Java's Two Worlds:                                                 │
│                                                                     │
│    int x = 42;              ← Primitive (fast, limited)             │
│    Integer y = 42;          ← Object (slower, has methods)          │
│    List<int> nums;          ← ERROR! Can't use primitives here      │
│    List<Integer> nums;      ← Must use wrapper class                │
│                                                                     │
│  Python's One World:                                                │
│                                                                     │
│    x = 42                   ← Object (consistent, has methods)      │
│    nums = [42, 43, 44]      ← Just works, no special handling       │
│    x.bit_length()           ← Methods available on everything       │
└─────────────────────────────────────────────────────────────────────┘
```

#### How Does Python Make This Work Efficiently?

Python uses several optimizations to reduce the overhead of "everything is an object":

1. **Integer Caching**: Small integers (-5 to 256) are pre-created and reused.

2. **String Interning**: Common strings are stored once and shared.

3. **C Implementation**: CPython's core types (int, str, list) are implemented in C for speed.

4. **Specialized Bytecode**: Common operations like integer addition have optimized paths.

5. **PyPy JIT**: Alternative Python implementations can compile hot paths to machine code.

```python
# Despite being objects, Python optimizes common cases:

# These share the same object (cached)
a = 100
b = 100
print(a is b)  # True - same object, no extra memory!

# The interpreter optimizes arithmetic
x = 1 + 2 + 3  # Computed at compile time, not runtime
```

#### When Does This Matter?

For most DevOps scripts, the object overhead is **negligible**. Where it matters:

| Scenario | Impact | Solution |
|----------|--------|----------|
| Processing millions of numbers | High memory usage | Use `numpy` (C arrays under the hood) |
| Tight loops with arithmetic | Slower than C | Use `numba` JIT or write critical parts in C |
| Normal scripting/automation | Unnoticeable | Just use Python normally |

**The Python philosophy**: Developer time is more valuable than CPU time. A consistent, simple language helps you write correct code faster.

```python
# In C/C++: integers are "primitives" handled directly by CPU
# In Python: integers are OBJECTS with methods!

# The number 42 is an object
num = 42
print(type(num))  # <class 'int'>
print(id(num))    # 140234567890 (unique memory address)

# You can call methods on integers!
print((42).bit_length())  # 6 (bits needed to represent 42)
print((42).to_bytes(2, 'big'))  # b'\x00*'

# Even simple operations are method calls internally!
# 1 + 1 is actually: (1).__add__(1)
result = (1).__add__(1)
print(result)  # 2
```

### 2. Strings Are Objects

```python
# String is an object with many methods
name = "devops"
print(type(name))  # <class 'str'>

# Call methods on strings
print(name.upper())       # DEVOPS
print(name.capitalize())  # Devops
print(name.replace('o', '0'))  # dev0ps

# Even string literals are objects!
print("hello".upper())  # HELLO

# Check all string methods
print(dir(str))
# ['__add__', 'capitalize', 'casefold', 'center', 'count', ...]
```

### 3. Functions Are Objects

```python
# Functions are first-class objects!
def greet(name):
    """A simple greeting function"""
    return f"Hello, {name}!"

# Functions have attributes
print(type(greet))       # <class 'function'>
print(greet.__name__)    # greet
print(greet.__doc__)     # A simple greeting function

# Assign functions to variables
say_hi = greet
print(say_hi("DevOps"))  # Hello, DevOps!

# Pass functions as arguments
def call_twice(func, arg):
    return func(arg) + " " + func(arg)

print(call_twice(greet, "World"))  # Hello, World! Hello, World!

# Store functions in data structures
operations = {
    'upper': str.upper,
    'lower': str.lower,
    'title': str.title
}
print(operations['upper']("hello"))  # HELLO
```

### 4. Classes Are Objects (Metaclasses)

```python
# Even classes are objects!
class Server:
    pass

# Class is an object of type 'type'
print(type(Server))      # <class 'type'>
print(Server.__name__)   # Server
print(Server.__bases__)  # (<class 'object'>,)

# You can assign classes to variables
MyClass = Server
server = MyClass()
print(type(server))  # <class '__main__.Server'>
```

---

## 🆔 Identity and Type: The Two Pillars

Every object in Python has two fundamental properties:

### 1. Identity (`id()`)

The unique identifier (memory address) that never changes during the object's lifetime.

```python
# Every object has a unique ID
a = "hello"
b = "hello"  
c = a

print(f"id(a) = {id(a)}")
print(f"id(b) = {id(b)}")
print(f"id(c) = {id(c)}")

# a and b might share ID (string interning optimization)
# a and c DEFINITELY share ID (same reference)
print(a is c)  # True (same object)

# Compare identity vs equality
x = [1, 2, 3]
y = [1, 2, 3]
z = x

print(x == y)   # True (same VALUE)
print(x is y)   # False (different OBJECTS)
print(x is z)   # True (same OBJECT)
```

### 2. Type (`type()`)

The class that defines the object's behavior. Determined at runtime (dynamic typing).

```python
# Type determines what operations are valid
num = 42
text = "42"
items = [1, 2, 3]

print(type(num))    # <class 'int'>
print(type(text))   # <class 'str'>
print(type(items))  # <class 'list'>

# Different types = different behaviors
print(num + 8)      # 50 (integer addition)
print(text + "8")   # 428 (string concatenation)
# print(num + text) # TypeError! Can't mix types

# Types can be checked
if isinstance(num, int):
    print("It's an integer!")
    
# Dynamic typing: variables can change type
value = 42
print(type(value))  # <class 'int'>

value = "hello"
print(type(value))  # <class 'str'>

value = [1, 2, 3]
print(type(value))  # <class 'list'>
```

---

## 🔗 Unity of Data and Methods (Encapsulation)

Objects combine **data (attributes)** and **functions (methods)** into a single entity.

```python
class Server:
    """
    Encapsulates server data and operations together
    This is the essence of object-oriented programming
    """
    
    def __init__(self, name, ip, port=8080):
        # Data (attributes)
        self.name = name
        self.ip = ip
        self.port = port
        self.status = "stopped"
        self._connection_count = 0  # "private" attribute
    
    # Behavior (methods)
    def start(self):
        """Start the server"""
        self.status = "running"
        return f"{self.name} started on {self.ip}:{self.port}"
    
    def stop(self):
        """Stop the server"""
        self.status = "stopped"
        self._connection_count = 0
        return f"{self.name} stopped"
    
    def get_url(self):
        """Generate server URL"""
        return f"http://{self.ip}:{self.port}"
    
    def __str__(self):
        """String representation"""
        return f"Server({self.name}, {self.status})"

# Using the object
server = Server("web-01", "192.168.1.10")

# Access data
print(server.name)    # web-01
print(server.status)  # stopped

# Call methods (behavior)
print(server.start())    # web-01 started on 192.168.1.10:8080
print(server.get_url())  # http://192.168.1.10:8080
print(server.status)     # running

# Object knows its type
print(type(server))  # <class '__main__.Server'>
```

---

## 🧮 How Operators Really Work

Python operators are actually method calls on objects!

### Arithmetic Operators

```python
# What you write → What Python does
# a + b          → a.__add__(b)
# a - b          → a.__sub__(b)
# a * b          → a.__mul__(b)
# a / b          → a.__truediv__(b)
# a // b         → a.__floordiv__(b)
# a % b          → a.__mod__(b)
# a ** b         → a.__pow__(b)

# Example
x = 10
y = 3

# These are equivalent:
print(x + y)           # 13
print(x.__add__(y))    # 13

# You can define these for your own classes!
class Dollar:
    def __init__(self, amount):
        self.amount = amount
    
    def __add__(self, other):
        return Dollar(self.amount + other.amount)
    
    def __str__(self):
        return f"${self.amount:.2f}"

cost1 = Dollar(10.50)
cost2 = Dollar(5.25)
total = cost1 + cost2  # Uses __add__
print(total)  # $15.75
```

### Comparison Operators

```python
# What you write → What Python does
# a == b         → a.__eq__(b)
# a != b         → a.__ne__(b)
# a < b          → a.__lt__(b)
# a <= b         → a.__le__(b)
# a > b          → a.__gt__(b)
# a >= b         → a.__ge__(b)

# Example: Custom comparison
class Version:
    def __init__(self, major, minor, patch):
        self.major = major
        self.minor = minor
        self.patch = patch
    
    def __lt__(self, other):
        return (self.major, self.minor, self.patch) < \
               (other.major, other.minor, other.patch)
    
    def __eq__(self, other):
        return (self.major, self.minor, self.patch) == \
               (other.major, other.minor, other.patch)
    
    def __str__(self):
        return f"{self.major}.{self.minor}.{self.patch}"

v1 = Version(1, 0, 0)
v2 = Version(2, 0, 0)
v3 = Version(1, 0, 0)

print(v1 < v2)   # True
print(v1 == v3)  # True
print(v2 > v1)   # True
```

---

## 📦 Common Magic Methods (Dunder Methods)

```python
class Container:
    """Demonstrates common magic methods"""
    
    def __init__(self, items=None):
        """Called when creating new instance"""
        self.items = items or []
    
    def __str__(self):
        """String representation for users (print)"""
        return f"Container with {len(self.items)} items"
    
    def __repr__(self):
        """String representation for developers (debugging)"""
        return f"Container({self.items!r})"
    
    def __len__(self):
        """Called by len()"""
        return len(self.items)
    
    def __getitem__(self, index):
        """Called by container[index]"""
        return self.items[index]
    
    def __setitem__(self, index, value):
        """Called by container[index] = value"""
        self.items[index] = value
    
    def __iter__(self):
        """Makes object iterable (for loops)"""
        return iter(self.items)
    
    def __contains__(self, item):
        """Called by 'in' operator"""
        return item in self.items
    
    def __bool__(self):
        """Called for truth testing"""
        return len(self.items) > 0

# Usage
c = Container([1, 2, 3])

print(str(c))      # Container with 3 items
print(repr(c))     # Container([1, 2, 3])
print(len(c))      # 3
print(c[0])        # 1
print(2 in c)      # True
print(bool(c))     # True

for item in c:     # Uses __iter__
    print(item)

# Empty container
empty = Container()
print(bool(empty)) # False
```

---

## 💡 Why This Matters for DevOps

### 1. Understanding APIs and Libraries

```python
# Every library returns objects with methods
import requests

response = requests.get("https://api.github.com")

# response is an object!
print(type(response))        # <class 'requests.models.Response'>
print(response.status_code)  # 200 (attribute)
print(response.json())       # {...} (method)
print(response.headers)      # {...} (attribute)

# Explore what's available
print(dir(response))
# ['content', 'cookies', 'headers', 'json', 'status_code', 'text', ...]
```

### 2. Working with Configuration Objects

```python
class ServerConfig:
    """Configuration as an object"""
    
    def __init__(self, name, region="us-east-1"):
        self.name = name
        self.region = region
        self.instance_type = "t3.micro"
        self.tags = {}
    
    def with_instance_type(self, instance_type):
        """Builder pattern - returns self for chaining"""
        self.instance_type = instance_type
        return self
    
    def with_tag(self, key, value):
        self.tags[key] = value
        return self
    
    def to_dict(self):
        return {
            "name": self.name,
            "region": self.region,
            "instance_type": self.instance_type,
            "tags": self.tags
        }

# Fluent interface - method chaining
config = (ServerConfig("web-01")
    .with_instance_type("t3.small")
    .with_tag("environment", "production")
    .with_tag("team", "platform"))

print(config.to_dict())
```

### 3. Custom DevOps Objects

```python
from datetime import datetime
from dataclasses import dataclass
from enum import Enum

class DeploymentStatus(Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    SUCCESS = "success"
    FAILED = "failed"
    ROLLED_BACK = "rolled_back"

@dataclass
class Deployment:
    """Represents a deployment as an object"""
    service: str
    version: str
    environment: str
    status: DeploymentStatus = DeploymentStatus.PENDING
    started_at: datetime = None
    completed_at: datetime = None
    
    def start(self):
        self.status = DeploymentStatus.IN_PROGRESS
        self.started_at = datetime.now()
        return self
    
    def complete(self, success=True):
        self.status = DeploymentStatus.SUCCESS if success else DeploymentStatus.FAILED
        self.completed_at = datetime.now()
        return self
    
    @property
    def duration(self):
        if self.started_at and self.completed_at:
            return (self.completed_at - self.started_at).total_seconds()
        return None

# Usage
deploy = Deployment(
    service="api-gateway",
    version="2.1.0",
    environment="production"
)

deploy.start()
# ... deployment happens ...
deploy.complete(success=True)

print(f"Deployment took {deploy.duration} seconds")
```

---

## 🔬 Introspection Tools

Python provides built-in tools to examine objects:

```python
# 1. type() - Get object's type
x = [1, 2, 3]
print(type(x))  # <class 'list'>

# 2. id() - Get object's unique identifier
print(id(x))  # 140234567890

# 3. dir() - List all attributes and methods
print(dir(x))  # ['append', 'clear', 'copy', ...]

# 4. isinstance() - Check type
print(isinstance(x, list))    # True
print(isinstance(x, (list, tuple)))  # True (either type)

# 5. hasattr() - Check if attribute exists
print(hasattr(x, 'append'))  # True
print(hasattr(x, 'missing'))  # False

# 6. getattr() - Get attribute by name
method = getattr(x, 'append')
method(4)  # Same as x.append(4)
print(x)  # [1, 2, 3, 4]

# 7. callable() - Check if object can be called
print(callable(print))  # True
print(callable(42))     # False

# 8. help() - Get documentation
help(list.append)
```

---

## 📊 Quick Reference

| Concept | Description | Example |
|---------|-------------|---------|
| Object | Instance of a class with state & behavior | `server = Server()` |
| Type | Class that defines behavior | `type(42)` → `<class 'int'>` |
| Identity | Unique ID (memory address) | `id(obj)` |
| Method | Function bound to object | `"hello".upper()` |
| Attribute | Data stored in object | `server.name` |
| Magic Method | Special method (`__xxx__`) | `__init__`, `__add__` |
| Introspection | Examining objects at runtime | `dir()`, `type()` |

---

## 🎯 Key Takeaways

✅ **Everything in Python is an object** - integers, strings, functions, classes  
✅ **Objects combine data + behavior** into one entity  
✅ **Every object has identity (id) and type**  
✅ **Operators are method calls** - `a + b` is `a.__add__(b)`  
✅ **Use `dir()` and `help()`** to explore objects  
✅ **Understanding objects** helps you use libraries effectively  
✅ **You can create custom objects** for DevOps workflows  

---

## 🚀 Next Steps

Now that you understand Python's object model:
1. **Variables and Memory** → See [06_mutability_memory.md](06_mutability_memory.md)
2. **Functions as Objects** → See [03_functions_basics.md](03_functions_basics.md)
3. **OOP Practice** → See [practice_03_oop.py](practice_03_oop.py)

````
.