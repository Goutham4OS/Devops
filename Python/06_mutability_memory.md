# 🔄 Mutability, Memory & Function Behavior in Python

## Understanding How Python Manages Memory

This guide covers one of the most important concepts in Python: **mutability**—whether an object's contents can change after creation, and how this affects memory management and function behavior.

### Why Mutability Matters in DevOps

Consider this scenario: You write a function to add a tag to a server configuration. You call it on one server, but suddenly ALL your server configs have the same tag. What happened?

This is the **aliasing trap**—one of the most common bugs in Python, caused by misunderstanding mutability. By the end of this guide, you'll:

- Know which types are mutable vs immutable
- Understand why `a = b` doesn't always create a copy
- Avoid the "mutable default argument" trap
- Write safer code with defensive copying

```
┌───────────────────────────────────────────────────────────────┐
│  The Core Question: Does modifying X affect Y?                │
│                                                               │
│  IMMUTABLE (int, str, tuple):                                 │
│    x = "hello"                                                │
│    y = x                                                      │
│    x = x + " world"  →  y is still "hello" ✓                 │
│                                                               │
│  MUTABLE (list, dict, set):                                   │
│    x = [1, 2, 3]                                              │
│    y = x                                                      │
│    x.append(4)  →  y is now [1, 2, 3, 4] too! ⚠️              │
└───────────────────────────────────────────────────────────────┘
```

---

## 📦 PART 1: Mutable vs Immutable Objects

### What is Mutability?

**Mutability** refers to whether an object's state (content) can be changed after it's created.

| Type | Mutable? | Can modify in-place? | Examples |
|------|----------|---------------------|----------|
| `int` | ❌ Immutable | No | `42`, `0`, `-5` |
| `float` | ❌ Immutable | No | `3.14`, `0.0` |
| `str` | ❌ Immutable | No | `"hello"`, `''` |
| `tuple` | ❌ Immutable | No | `(1, 2, 3)` |
| `frozenset` | ❌ Immutable | No | `frozenset({1, 2})` |
| `bool` | ❌ Immutable | No | `True`, `False` |
| `list` | ✅ Mutable | Yes | `[1, 2, 3]` |
| `dict` | ✅ Mutable | Yes | `{"a": 1}` |
| `set` | ✅ Mutable | Yes | `{1, 2, 3}` |
| Custom objects | ✅ Usually Mutable | Yes | Class instances |

---

### Immutable Objects: Content Cannot Change

When you "modify" an immutable object, Python creates a **new object**.

```python
# Strings are IMMUTABLE
name = "hello"
print(f"Original: id={id(name)}")  # id = 140234567890

name = name.upper()  # Creates NEW string
print(f"After upper(): id={id(name)}")  # id = 140234567999 (DIFFERENT!)

# The original string "hello" still exists (until garbage collected)
# We just reassigned 'name' to point to a NEW object "HELLO"
```

```python
# Integers are IMMUTABLE
x = 10
print(f"x = {x}, id = {id(x)}")  # id = 140234500100

x = x + 5  # Creates NEW integer
print(f"x = {x}, id = {id(x)}")  # id = 140234500120 (DIFFERENT!)

# Demonstration
a = 10
b = a
print(a is b)  # True - same object

a = a + 5
print(a)  # 15
print(b)  # 10 - UNCHANGED! b still points to original object
print(a is b)  # False - now different objects
```

```python
# Tuples are IMMUTABLE
coords = (10, 20)
print(f"id = {id(coords)}")

# This will raise an error!
try:
    coords[0] = 50
except TypeError as e:
    print(f"Error: {e}")  # 'tuple' object does not support item assignment

# To "modify" a tuple, create a new one
new_coords = (50,) + coords[1:]
print(new_coords)  # (50, 20)
```

---

### Mutable Objects: Content CAN Change

Mutable objects can be modified **in-place** without changing their identity.

```python
# Lists are MUTABLE
servers = ["web-01", "web-02"]
print(f"Original: {servers}, id = {id(servers)}")

servers.append("web-03")  # Modifies in-place
print(f"After append: {servers}, id = {id(servers)}")  # SAME id!

servers[0] = "web-00"  # Modifies in-place
print(f"After modify: {servers}, id = {id(servers)}")  # SAME id!
```

```python
# Dictionaries are MUTABLE
config = {"host": "localhost", "port": 8080}
original_id = id(config)

config["ssl"] = True  # Add key
config["port"] = 443  # Modify key
del config["host"]    # Delete key

print(f"Same object? {id(config) == original_id}")  # True!
print(config)  # {'port': 443, 'ssl': True}
```

```python
# Sets are MUTABLE
active_servers = {"web-01", "web-02"}
original_id = id(active_servers)

active_servers.add("web-03")
active_servers.remove("web-01")

print(f"Same object? {id(active_servers) == original_id}")  # True!
```

---

### ⚠️ The Aliasing Trap

Mutable objects can have **multiple references** (aliases), which can lead to unexpected behavior.

```python
# THE TRAP: Two variables pointing to same list
list_a = [1, 2, 3]
list_b = list_a  # NOT a copy! Same object!

print(f"list_a is list_b: {list_a is list_b}")  # True

# Modifying through one variable affects the other!
list_b.append(4)
print(list_a)  # [1, 2, 3, 4] - CHANGED!
print(list_b)  # [1, 2, 3, 4]
```

```python
# THE FIX: Create a copy
list_a = [1, 2, 3]
list_b = list_a.copy()  # Creates new list

print(f"list_a is list_b: {list_a is list_b}")  # False

list_b.append(4)
print(list_a)  # [1, 2, 3] - UNCHANGED!
print(list_b)  # [1, 2, 3, 4]
```

### Different Ways to Copy

```python
import copy

original = [1, [2, 3], {"a": 1}]

# 1. Slice copy (shallow)
copy1 = original[:]

# 2. list() constructor (shallow)
copy2 = list(original)

# 3. .copy() method (shallow)
copy3 = original.copy()

# 4. Shallow copy (copies outer, references inner)
copy4 = copy.copy(original)

# 5. Deep copy (copies EVERYTHING recursively)
copy5 = copy.deepcopy(original)

# Shallow vs Deep - the difference
original[1].append(999)

print(copy3)  # [1, [2, 3, 999], {'a': 1}] - nested list changed!
print(copy5)  # [1, [2, 3], {'a': 1}] - deep copy unaffected
```

---

## 🧠 PART 2: Memory Optimization - Integer Caching

### Why Does Python Cache Integers?

Creating objects takes time and memory. Since small integers are used **constantly** in programs (loop counters, array indices, return codes), Python pre-creates integers from -5 to 256 when it starts up.

```
When Python starts:
┌───────────────────────────────────────────────────────────┐
│  Integer Cache: [-5] [-4] ... [0] [1] [2] ... [256]  │
│                                                       │
│  Every time you use 42, Python returns the SAME object│
└───────────────────────────────────────────────────────────┘
```

**Why -5 to 256?**
- Negative numbers for error codes (-1, -2)
- 0 through 255 cover byte values, ASCII, common counts
- 256 is a common boundary (2^8)

### Small Integer Caching

Python pre-allocates integers from **-5 to 256** for performance. These are reused, not recreated.

```python
# Small integers are cached (same object)
a = 256
b = 256
print(f"a is b: {a is b}")  # True - same object!
print(f"id(a) = {id(a)}, id(b) = {id(b)}")

# Large integers create new objects
x = 257
y = 257
print(f"x is y: {x is y}")  # False - different objects!
print(f"id(x) = {id(x)}, id(y) = {id(y)}")

# Why? Performance optimization
# Small integers are used frequently, so caching saves memory and time
```

### String Interning

Python also "interns" (reuses) certain strings:

```python
# Simple strings are interned
a = "hello"
b = "hello"
print(a is b)  # True - same object

# Strings with spaces usually not interned
c = "hello world"
d = "hello world"
print(c is d)  # Might be False (implementation-dependent)

# You can force interning
import sys
e = sys.intern("hello world")
f = sys.intern("hello world")
print(e is f)  # True - forced to be same object
```

### Best Practice: Use `==` for Value Comparison

```python
# ALWAYS use == for comparing values
x = 500
y = 500
print(x == y)  # True - same VALUE

# Only use 'is' for:
# - None checks: if x is None
# - Singleton checks: if x is True
# - Identity checks: if obj1 is obj2
```

---

## 🔧 PART 3: Function Argument Passing

### Neither "By Value" Nor "By Reference"

If you come from other languages, you might ask: "Does Python pass by value or by reference?" The answer is **neither**—Python passes by **assignment** (also called "by object reference").

Here's what happens when you call `function(argument)`:

```
1. Before call:
   argument ─────────────→ [Object in memory]

2. During call (function receives 'parameter'):
   argument ─────────────→ [Object in memory]
   parameter ────────────┘  (same object!)

3. After function modifies:
   - If MUTABLE: Object is changed, caller sees change
   - If IMMUTABLE: New object created, parameter points to new object,
                   original unchanged
```

**The key insight:** The parameter is a **new name** pointing to the **same object**. What happens next depends on whether you **modify** the object or **reassign** the variable.

### Python Passes by Assignment (Object Reference)

Python doesn't use "pass by value" or "pass by reference" exactly. It uses **pass by assignment** (also called "pass by object reference").

```python
# When you call: function(argument)
# Python does: parameter = argument
# This creates a new reference to the SAME object

def example(param):
    print(f"Inside function: id = {id(param)}")

value = [1, 2, 3]
print(f"Before call: id = {id(value)}")
example(value)  # Same id printed!
```

### With Immutable Objects

```python
def try_modify_string(text):
    """Attempt to modify an immutable string"""
    print(f"Inside (before): {text}, id = {id(text)}")
    text = text + " modified"  # Creates NEW object, rebinds 'text'
    print(f"Inside (after): {text}, id = {id(text)}")  # Different id!
    return text

original = "hello"
print(f"Original: {original}, id = {id(original)}")

result = try_modify_string(original)

print(f"Original after call: {original}")  # Still "hello"!
print(f"Result: {result}")  # "hello modified"
```

**What happened:**
1. `text` started as a reference to the same object as `original`
2. `text + " modified"` created a NEW string object
3. `text =` reassigned the local variable to the new object
4. `original` was never affected

### With Mutable Objects

```python
def add_server(server_list, server_name):
    """Modifies the passed list"""
    print(f"Inside (before): {server_list}, id = {id(server_list)}")
    server_list.append(server_name)  # Modifies IN-PLACE
    print(f"Inside (after): {server_list}, id = {id(server_list)}")  # Same id!

servers = ["web-01", "web-02"]
print(f"Before: {servers}, id = {id(servers)}")

add_server(servers, "web-03")

print(f"After: {servers}")  # ['web-01', 'web-02', 'web-03'] - CHANGED!
```

### Reassignment vs Modification

```python
# MODIFICATION - affects original
def modify_in_place(my_list):
    my_list.append(99)  # Modifies the object
    my_list[0] = 0      # Modifies the object

# REASSIGNMENT - does NOT affect original
def reassign(my_list):
    my_list = [1, 2, 3]  # Creates new object, rebinds local variable
    # Original is NOT affected

data = [10, 20, 30]
modify_in_place(data)
print(data)  # [0, 20, 30, 99] - Modified!

data = [10, 20, 30]
reassign(data)
print(data)  # [10, 20, 30] - Unchanged!
```

---

## ⚠️ PART 4: Common Pitfalls

### Pitfall 1: Mutable Default Arguments

```python
# ❌ DANGEROUS: Mutable default argument
def add_item_bad(item, items=[]):
    items.append(item)
    return items

# The default list is created ONCE and reused!
print(add_item_bad("a"))  # ['a']
print(add_item_bad("b"))  # ['a', 'b'] - NOT what we expected!
print(add_item_bad("c"))  # ['a', 'b', 'c'] - It accumulates!
```

```python
# ✅ CORRECT: Use None as default
def add_item_good(item, items=None):
    if items is None:
        items = []  # Create new list each call
    items.append(item)
    return items

print(add_item_good("a"))  # ['a']
print(add_item_good("b"))  # ['b'] - Fresh list!
print(add_item_good("c"))  # ['c'] - Fresh list!
```

### Pitfall 2: Shared State in Loops

```python
# ❌ PROBLEM: All dictionaries share same list
servers = []
for i in range(3):
    server = {"name": f"web-0{i}", "tags": []}
    servers.append(server)

# Add a tag to first server
servers[0]["tags"].append("production")
print([s["tags"] for s in servers])  # [['production'], [], []]
# This is actually OK because we create new dict each iteration

# ❌ REAL PROBLEM: Using same object reference
default_tags = []  # Shared!
servers = []
for i in range(3):
    server = {"name": f"web-0{i}", "tags": default_tags}  # Same list!
    servers.append(server)

servers[0]["tags"].append("production")
print([s["tags"] for s in servers])  # [['production'], ['production'], ['production']]
```

```python
# ✅ FIX: Create new list for each
servers = []
for i in range(3):
    server = {"name": f"web-0{i}", "tags": []}  # New list each time
    servers.append(server)
```

### Pitfall 3: Modifying a List While Iterating

```python
# ❌ PROBLEM: Modifying list while iterating
numbers = [1, 2, 3, 4, 5]
for num in numbers:
    if num % 2 == 0:
        numbers.remove(num)  # DANGEROUS!

print(numbers)  # [1, 3, 5] - might skip items!
```

```python
# ✅ FIX: Create new list or iterate over copy
numbers = [1, 2, 3, 4, 5]

# Option 1: List comprehension (creates new list)
odds = [num for num in numbers if num % 2 != 0]

# Option 2: Iterate over copy
for num in numbers[:]:  # [:] creates copy
    if num % 2 == 0:
        numbers.remove(num)
```

---

## 🛡️ PART 5: Defensive Programming Patterns

### Pattern 1: Copy on Input

```python
def process_servers(servers):
    """
    Work with a copy to avoid modifying caller's data
    """
    # Create local copy
    local_servers = servers.copy()
    
    # Safe to modify
    local_servers.append({"name": "temp-server"})
    
    # Process...
    for server in local_servers:
        server["processed"] = True
    
    return local_servers

# Original unchanged
original = [{"name": "web-01"}]
result = process_servers(original)
print(original)  # [{'name': 'web-01'}] - unchanged
print(result)    # Modified version
```

### Pattern 2: Return New Objects

```python
def add_tag(server, tag):
    """
    Return new dict instead of modifying original
    (Functional programming style)
    """
    return {
        **server,  # Unpack original
        "tags": server.get("tags", []) + [tag]  # New list
    }

original = {"name": "web-01", "tags": ["prod"]}
updated = add_tag(original, "active")

print(original)  # {'name': 'web-01', 'tags': ['prod']} - unchanged
print(updated)   # {'name': 'web-01', 'tags': ['prod', 'active']}
```

### Pattern 3: Use Immutable Types

```python
from typing import Tuple, FrozenSet

# Use tuple instead of list for fixed data
def get_allowed_ports() -> Tuple[int, ...]:
    return (22, 80, 443, 8080)

ports = get_allowed_ports()
# ports.append(9000)  # AttributeError - can't modify!

# Use frozenset for immutable sets
def get_required_tags() -> FrozenSet[str]:
    return frozenset({"environment", "team", "cost-center"})

tags = get_required_tags()
# tags.add("new")  # AttributeError - can't modify!
```

### Pattern 4: Explicit Mutation Markers

```python
class ServerList:
    """Wrapper that makes mutation explicit"""
    
    def __init__(self, servers: list):
        self._servers = list(servers)  # Copy on init
    
    def add(self, server: dict) -> 'ServerList':
        """Return NEW ServerList (immutable style)"""
        return ServerList(self._servers + [server])
    
    def add_in_place(self, server: dict) -> None:
        """Modify in place (name makes it clear!)"""
        self._servers.append(server)
    
    def as_list(self) -> list:
        return self._servers.copy()  # Return copy

servers = ServerList([{"name": "web-01"}])
new_servers = servers.add({"name": "web-02"})

print(servers.as_list())      # [{'name': 'web-01'}] - original unchanged
print(new_servers.as_list())  # [{'name': 'web-01'}, {'name': 'web-02'}]
```

---

## 📊 PART 6: Memory Reference Visualization

```python
# Visualizing what happens in memory

import sys

# Case 1: Immutable (integer)
a = 10
b = a
print(f"""
Integer Assignment:
a = 10, b = a
  a ──────┐
          │──→ [int: 10]
  b ──────┘
  
a is b: {a is b}
""")

a = a + 5
print(f"""
After a = a + 5:
  a ──────→ [int: 15]  (NEW object)
  b ──────→ [int: 10]  (unchanged)
  
a is b: {a is b}
""")

# Case 2: Mutable (list)
x = [1, 2, 3]
y = x
print(f"""
List Assignment:
x = [1, 2, 3], y = x
  x ──────┐
          │──→ [list: [1, 2, 3]]
  y ──────┘
  
x is y: {x is y}
""")

x.append(4)
print(f"""
After x.append(4):
  x ──────┐
          │──→ [list: [1, 2, 3, 4]]  (SAME object, modified)
  y ──────┘
  
y is now: {y}
x is y: {x is y}
""")

# Case 3: Copy
x = [1, 2, 3]
y = x.copy()
print(f"""
After y = x.copy():
  x ──────→ [list: [1, 2, 3]]  (original)
  y ──────→ [list: [1, 2, 3]]  (NEW object, copy)
  
x is y: {x is y}
x == y: {x == y}
""")
```

---

## 🎯 Key Takeaways

### Mutability Rules

| If Object Is... | Assignment (=) | Method Calls | Effect on Original |
|-----------------|----------------|--------------|-------------------|
| Immutable | Creates ref | Returns new obj | Never changed |
| Mutable | Creates ref | Modifies in-place | Can be changed |

### Best Practices

✅ **Use `==` for value comparison**, `is` only for `None`  
✅ **Copy mutable objects** when you don't want side effects  
✅ **Never use mutable default arguments** - use `None` instead  
✅ **Don't modify lists while iterating** - iterate over a copy  
✅ **Use `copy.deepcopy()`** for nested structures  
✅ **Prefer immutable types** when data shouldn't change  
✅ **Document mutation** - make it clear when functions modify inputs  

---

## 📚 Quick Reference

```python
# Check if mutable
def is_mutable(obj):
    """Check if object type is mutable"""
    mutable_types = (list, dict, set, bytearray)
    return isinstance(obj, mutable_types)

# Safe copy patterns
import copy

shallow_copy = original.copy()      # or list(original)
deep_copy = copy.deepcopy(original)

# Safe default argument
def func(items=None):
    items = items if items is not None else []

# Memory checks
id(obj)          # Object's unique identifier
obj1 is obj2     # Same object?
obj1 == obj2     # Same value?
sys.getsizeof(obj)  # Memory size in bytes
```

---

## 🚀 Next Steps

1. **Practice**: See [practice_04_memory_references.py](practice_04_memory_references.py)
2. **Functions Deep Dive**: See [03_functions_basics.md](03_functions_basics.md)
3. **OOP Concepts**: See [practice_03_oop.py](practice_03_oop.py)

````
