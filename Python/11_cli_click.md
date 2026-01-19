````markdown
# 🖥️ Command-Line Interfaces (CLI) & The Click Library

## Why CLI Matters in DevOps

Most DevOps tools are command-line applications. Understanding how to build proper CLIs means:
- Scripts can be customized without code changes
- Tools integrate with automation pipelines
- Users get professional help messages
- Configuration can be passed via environment variables

### The Command-Line is DevOps Native

Think about the tools you use daily: `git`, `docker`, `kubectl`, `terraform`, `ansible`. They're all CLIs. A well-designed CLI:

1. **Self-documents** with `--help`
2. **Fails gracefully** with clear error messages
3. **Supports automation** via exit codes and machine-readable output
4. **Respects conventions** (short flags `-v`, long flags `--verbose`)
5. **Integrates with environment** (reads from env vars, config files)

```
┌────────────────────────────────────────────────────────────────┐
│  Anatomy of a Great CLI Tool                                   │
│                                                                │
│  $ mytool deploy api-service --env production --version 2.0   │
│    │       │       │            │                │             │
│    │       │       │            │                └─ Option     │
│    │       │       │            └─ Option with value           │
│    │       │       └─ Argument (required)                      │
│    │       └─ Subcommand                                       │
│    └─ Tool name                                                │
│                                                                │
│  $ mytool --help     ←  Built-in documentation                 │
│  $ mytool -v -v -v   ←  Increasing verbosity                   │
│  $ echo $?           ←  Exit code (0=success, non-zero=error)  │
└────────────────────────────────────────────────────────────────┘
```

### Arguments vs Options: A Key Distinction

- **Arguments** are positional and usually required (like `git clone <url>`)
- **Options** are named flags, usually optional (like `--verbose`)

Good CLI design puts the "what" as arguments and the "how" as options.

---

## 📦 PART 1: Standard Library Tools

### 1.1 sys.argv - The Basics

The simplest way to get command-line arguments.

```python
# my_script.py
import sys

# sys.argv is a list of strings
print(f"Script name: {sys.argv[0]}")
print(f"All arguments: {sys.argv}")
print(f"Number of args: {len(sys.argv)}")

# Running: python my_script.py hello world 123
# Output:
#   Script name: my_script.py
#   All arguments: ['my_script.py', 'hello', 'world', '123']
#   Number of args: 4
```

### Proper sys.argv Usage

```python
import sys

def main():
    # Always check argument count
    if len(sys.argv) < 3:
        print("Usage: python deploy.py <environment> <service>")
        print("Example: python deploy.py production api-gateway")
        sys.exit(1)
    
    environment = sys.argv[1]
    service = sys.argv[2]
    
    # Optional arguments
    version = sys.argv[3] if len(sys.argv) > 3 else "latest"
    
    print(f"Deploying {service} v{version} to {environment}")

if __name__ == "__main__":
    main()
```

**Limitations of sys.argv:**
- No type conversion (everything is string)
- No automatic help
- No validation
- Manual parsing for optional args

---

### 1.2 argparse - The Standard Solution

Python's built-in argument parser with auto-generated help.

```python
import argparse

def main():
    # Create parser
    parser = argparse.ArgumentParser(
        description="Deploy services to different environments",
        epilog="Example: python deploy.py production api-gateway --version 2.0"
    )
    
    # Required positional arguments
    parser.add_argument(
        "environment",
        choices=["development", "staging", "production"],
        help="Target environment"
    )
    parser.add_argument(
        "service",
        help="Service name to deploy"
    )
    
    # Optional arguments with flags
    parser.add_argument(
        "-v", "--version",
        default="latest",
        help="Version to deploy (default: latest)"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without executing"
    )
    parser.add_argument(
        "--replicas",
        type=int,
        default=2,
        help="Number of replicas (default: 2)"
    )
    parser.add_argument(
        "--verbose",
        action="count",
        default=0,
        help="Increase verbosity (-v, -vv, -vvv)"
    )
    
    # Parse arguments
    args = parser.parse_args()
    
    # Use the arguments
    print(f"Environment: {args.environment}")
    print(f"Service: {args.service}")
    print(f"Version: {args.version}")
    print(f"Dry run: {args.dry_run}")
    print(f"Replicas: {args.replicas}")
    print(f"Verbosity: {args.verbose}")

if __name__ == "__main__":
    main()
```

**Running with --help:**
```bash
$ python deploy.py --help
usage: deploy.py [-h] [-v VERSION] [--dry-run] [--replicas REPLICAS]
                 [--verbose]
                 {development,staging,production} service

Deploy services to different environments

positional arguments:
  {development,staging,production}
                        Target environment
  service               Service name to deploy

optional arguments:
  -h, --help            show this help message and exit
  -v VERSION, --version VERSION
                        Version to deploy (default: latest)
  --dry-run             Show what would be done without executing
  --replicas REPLICAS   Number of replicas (default: 2)
  --verbose             Increase verbosity (-v, -vv, -vvv)

Example: python deploy.py production api-gateway --version 2.0
```

### argparse Advanced Features

```python
import argparse

parser = argparse.ArgumentParser()

# Mutually exclusive options
group = parser.add_mutually_exclusive_group()
group.add_argument("--start", action="store_true")
group.add_argument("--stop", action="store_true")

# List of values
parser.add_argument(
    "--servers",
    nargs="+",  # One or more
    help="List of servers"
)
# Usage: --servers web-01 web-02 web-03

# Choices
parser.add_argument(
    "--log-level",
    choices=["DEBUG", "INFO", "WARNING", "ERROR"],
    default="INFO"
)

# File types
parser.add_argument(
    "--config",
    type=argparse.FileType('r'),
    help="Config file to read"
)

# Subcommands (like git commit, git push)
subparsers = parser.add_subparsers(dest="command")

start_parser = subparsers.add_parser("start", help="Start a service")
start_parser.add_argument("service_name")

stop_parser = subparsers.add_parser("stop", help="Stop a service")
stop_parser.add_argument("service_name")
```

---

## 🖱️ PART 2: The Click Library

**Click** is a modern, decorator-based CLI library that's much cleaner than argparse.

### Installation

```bash
pip install click
```

### Basic Click Example

```python
import click

@click.command()
@click.argument("name")
def hello(name):
    """Simple program that greets NAME."""
    click.echo(f"Hello, {name}!")

if __name__ == "__main__":
    hello()
```

```bash
$ python hello.py World
Hello, World!

$ python hello.py --help
Usage: hello.py [OPTIONS] NAME

  Simple program that greets NAME.

Options:
  --help  Show this message and exit.
```

---

### 2.1 Arguments vs Options

| Feature | Argument | Option |
|---------|----------|--------|
| Syntax | Positional | Named (--flag) |
| Required | Usually yes | Usually no |
| Order | Matters | Doesn't matter |
| Example | `script.py config.yaml` | `script.py --config config.yaml` |

```python
import click

@click.command()
@click.argument("environment")  # Required, positional
@click.option("--version", "-v", default="latest", help="Version to deploy")
@click.option("--dry-run", is_flag=True, help="Preview without executing")
def deploy(environment, version, dry_run):
    """Deploy to ENVIRONMENT."""
    if dry_run:
        click.echo(f"[DRY RUN] Would deploy v{version} to {environment}")
    else:
        click.echo(f"Deploying v{version} to {environment}")

if __name__ == "__main__":
    deploy()
```

```bash
$ python deploy.py production --version 2.0 --dry-run
[DRY RUN] Would deploy v2.0 to production
```

---

### 2.2 Option Types and Validation

```python
import click

@click.command()
@click.option(
    "--count", "-c",
    type=int,
    default=1,
    help="Number of times"
)
@click.option(
    "--ratio",
    type=float,
    default=0.5,
    help="Ratio value"
)
@click.option(
    "--environment",
    type=click.Choice(["dev", "staging", "prod"], case_sensitive=False),
    default="dev",
    help="Target environment"
)
@click.option(
    "--config",
    type=click.Path(exists=True),  # Validates file exists
    help="Config file path"
)
@click.option(
    "--output",
    type=click.File("w"),  # Opens file for writing
    default="-",  # stdout by default
    help="Output file"
)
def process(count, ratio, environment, config, output):
    """Process with validated options."""
    output.write(f"Count: {count}\n")
    output.write(f"Ratio: {ratio}\n")
    output.write(f"Environment: {environment}\n")
    if config:
        output.write(f"Config: {config}\n")

if __name__ == "__main__":
    process()
```

---

### 2.3 Flags and Boolean Options

```python
import click

@click.command()
@click.option("--verbose", "-v", is_flag=True, help="Enable verbose output")
@click.option("--quiet", "-q", is_flag=True, help="Suppress output")
@click.option("--force/--no-force", default=False, help="Force operation")
@click.option("--color/--no-color", default=True, help="Colorize output")
def run(verbose, quiet, force, color):
    """Run with flag options."""
    if verbose:
        click.echo("Verbose mode enabled")
    if force:
        click.echo("Force mode enabled")
    if color:
        click.echo(click.style("Colorized!", fg="green"))

if __name__ == "__main__":
    run()
```

```bash
$ python run.py --verbose --force --no-color
Verbose mode enabled
Force mode enabled
```

---

### 2.4 Multiple Values

```python
import click

@click.command()
@click.option(
    "--server", "-s",
    multiple=True,
    help="Server to deploy to (can be used multiple times)"
)
@click.option(
    "--tag",
    nargs=2,
    type=str,
    multiple=True,
    help="Tag as KEY VALUE pairs"
)
def deploy(server, tag):
    """Deploy to multiple servers with tags."""
    click.echo(f"Deploying to: {', '.join(server)}")
    for key, value in tag:
        click.echo(f"Tag: {key} = {value}")

if __name__ == "__main__":
    deploy()
```

```bash
$ python deploy.py -s web-01 -s web-02 --tag env prod --tag team platform
Deploying to: web-01, web-02
Tag: env = prod
Tag: team = platform
```

---

### 2.5 Password Prompts (Hidden Input)

```python
import click

@click.command()
@click.option(
    "--username", "-u",
    prompt="Username",
    help="Username for authentication"
)
@click.option(
    "--password", "-p",
    prompt=True,
    hide_input=True,
    confirmation_prompt=True,
    help="Password (will be prompted securely)"
)
def login(username, password):
    """Login with credentials."""
    click.echo(f"Logging in as {username}...")
    # Password is hidden when typed
    
if __name__ == "__main__":
    login()
```

```bash
$ python login.py
Username: admin
Password: 
Repeat for confirmation: 
Logging in as admin...
```

---

### 2.6 Environment Variables

```python
import click

@click.command()
@click.option(
    "--api-key",
    envvar="API_KEY",  # Read from environment variable
    help="API key (or set API_KEY env var)"
)
@click.option(
    "--debug",
    envvar="DEBUG",
    is_flag=True,
    help="Enable debug mode"
)
@click.option(
    "--config",
    envvar=["APP_CONFIG", "CONFIG_FILE"],  # Multiple env vars (first found)
    type=click.Path(exists=True),
    help="Config file path"
)
def run(api_key, debug, config):
    """Run with environment variable support."""
    if not api_key:
        raise click.UsageError("API key required: --api-key or set API_KEY")
    
    click.echo(f"API Key: {api_key[:4]}...")
    click.echo(f"Debug: {debug}")
    if config:
        click.echo(f"Config: {config}")

if __name__ == "__main__":
    run()
```

```bash
$ export API_KEY="secret123"
$ python run.py --debug
API Key: secr...
Debug: True
```

---

### 2.7 Subcommands (Command Groups)

Like `git commit`, `git push`, `docker run`, etc.

```python
import click

@click.group()
@click.option("--verbose", "-v", is_flag=True, help="Enable verbose output")
@click.pass_context
def cli(ctx, verbose):
    """Server management CLI."""
    ctx.ensure_object(dict)
    ctx.obj["verbose"] = verbose

@cli.command()
@click.argument("server_name")
@click.option("--port", "-p", default=8080, help="Port number")
@click.pass_context
def start(ctx, server_name, port):
    """Start a server."""
    if ctx.obj["verbose"]:
        click.echo(f"[VERBOSE] Starting {server_name} on port {port}")
    click.echo(f"Starting {server_name}...")

@cli.command()
@click.argument("server_name")
@click.option("--force", "-f", is_flag=True, help="Force stop")
@click.pass_context  
def stop(ctx, server_name, force):
    """Stop a server."""
    if force:
        click.echo(f"Force stopping {server_name}...")
    else:
        click.echo(f"Gracefully stopping {server_name}...")

@cli.command()
@click.pass_context
def status(ctx):
    """Show status of all servers."""
    if ctx.obj["verbose"]:
        click.echo("[VERBOSE] Fetching detailed status...")
    click.echo("web-01: running")
    click.echo("web-02: running")
    click.echo("db-01: stopped")

if __name__ == "__main__":
    cli()
```

```bash
$ python server.py --help
Usage: server.py [OPTIONS] COMMAND [ARGS]...

  Server management CLI.

Options:
  -v, --verbose  Enable verbose output
  --help         Show this message and exit.

Commands:
  start   Start a server.
  status  Show status of all servers.
  stop    Stop a server.

$ python server.py start web-01 --port 9000
Starting web-01...

$ python server.py -v status
[VERBOSE] Fetching detailed status...
web-01: running
web-02: running
db-01: stopped
```

---

### 2.8 Nested Command Groups

```python
import click

@click.group()
def cli():
    """DevOps toolkit."""
    pass

# First level: 'server' group
@cli.group()
def server():
    """Server management commands."""
    pass

@server.command()
@click.argument("name")
def create(name):
    """Create a new server."""
    click.echo(f"Creating server: {name}")

@server.command("list")  # Different command name
def list_servers():
    """List all servers."""
    click.echo("web-01, web-02, db-01")

# First level: 'deploy' group
@cli.group()
def deploy():
    """Deployment commands."""
    pass

@deploy.command()
@click.argument("service")
@click.option("--env", default="staging")
def service(service, env):
    """Deploy a service."""
    click.echo(f"Deploying {service} to {env}")

if __name__ == "__main__":
    cli()
```

```bash
$ python devops.py server create web-03
Creating server: web-03

$ python devops.py deploy service api-gateway --env production
Deploying api-gateway to production
```

---

## 🎨 PART 3: Click Output Formatting

### Colored Output

```python
import click

@click.command()
def demo():
    """Demonstrate styled output."""
    
    # Colored text
    click.echo(click.style("Success!", fg="green", bold=True))
    click.echo(click.style("Warning!", fg="yellow"))
    click.echo(click.style("Error!", fg="red", bold=True))
    
    # Background colors
    click.echo(click.style("Important", bg="blue", fg="white"))
    
    # Shorthand with secho
    click.secho("This is green", fg="green")
    click.secho("This is bold red", fg="red", bold=True)
    
    # Blinking (use sparingly!)
    click.secho("Alert!", blink=True, fg="red")

if __name__ == "__main__":
    demo()
```

### Progress Bars

```python
import click
import time

@click.command()
@click.option("--count", default=100)
def process(count):
    """Process items with progress bar."""
    
    with click.progressbar(
        range(count),
        label="Processing",
        show_percent=True,
        show_pos=True
    ) as items:
        for item in items:
            time.sleep(0.05)  # Simulate work

if __name__ == "__main__":
    process()
```

```bash
$ python process.py --count 50
Processing  [####################################]  100%  50/50
```

### Interactive Prompts

```python
import click

@click.command()
def interactive():
    """Interactive prompts demo."""
    
    # Simple prompt
    name = click.prompt("Enter your name")
    
    # Prompt with default
    port = click.prompt("Enter port", default=8080, type=int)
    
    # Confirmation
    if click.confirm("Do you want to continue?"):
        click.echo("Continuing...")
    
    # Choice menu
    choice = click.prompt(
        "Select environment",
        type=click.Choice(["dev", "staging", "prod"]),
        default="dev"
    )
    
    click.echo(f"Hello {name}, deploying to {choice} on port {port}")

if __name__ == "__main__":
    interactive()
```

---

## 🏗️ PART 4: Complete CLI Application

```python
#!/usr/bin/env python3
"""
DevOps CLI Tool - Complete Example
"""
import click
import json
import yaml
import logging
from pathlib import Path

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Shared context
pass_config = click.make_pass_decorator(dict, ensure=True)

@click.group()
@click.option(
    "--config", "-c",
    type=click.Path(exists=True),
    envvar="DEVOPS_CONFIG",
    help="Configuration file"
)
@click.option(
    "--verbose", "-v",
    count=True,
    help="Increase verbosity (-v, -vv, -vvv)"
)
@click.version_option(version="1.0.0")
@click.pass_context
def cli(ctx, config, verbose):
    """
    DevOps CLI - Manage your infrastructure
    
    Configure using --config or DEVOPS_CONFIG environment variable.
    """
    ctx.ensure_object(dict)
    
    # Set logging level based on verbosity
    levels = [logging.WARNING, logging.INFO, logging.DEBUG]
    level = levels[min(verbose, 2)]
    logging.getLogger().setLevel(level)
    
    # Load config if provided
    if config:
        config_path = Path(config)
        if config_path.suffix in [".yaml", ".yml"]:
            with open(config_path) as f:
                ctx.obj["config"] = yaml.safe_load(f)
        elif config_path.suffix == ".json":
            with open(config_path) as f:
                ctx.obj["config"] = json.load(f)
        logger.debug(f"Loaded config from {config}")
    else:
        ctx.obj["config"] = {}
    
    ctx.obj["verbose"] = verbose


# ========== SERVER COMMANDS ==========
@cli.group()
def server():
    """Server management commands."""
    pass

@server.command("list")
@click.option("--format", "-f", type=click.Choice(["table", "json"]), default="table")
@click.pass_context
def server_list(ctx, format):
    """List all servers."""
    servers = [
        {"name": "web-01", "status": "running", "ip": "10.0.0.1"},
        {"name": "web-02", "status": "running", "ip": "10.0.0.2"},
        {"name": "db-01", "status": "stopped", "ip": "10.0.0.10"},
    ]
    
    if format == "json":
        click.echo(json.dumps(servers, indent=2))
    else:
        click.echo("NAME     STATUS    IP")
        click.echo("-" * 30)
        for s in servers:
            status_color = "green" if s["status"] == "running" else "red"
            click.echo(
                f"{s['name']:<8} "
                f"{click.style(s['status']:<9, fg=status_color)} "
                f"{s['ip']}"
            )

@server.command()
@click.argument("name")
@click.option("--wait/--no-wait", default=True, help="Wait for startup")
@click.pass_context
def start(ctx, name, wait):
    """Start a server."""
    click.echo(f"Starting {name}...")
    if wait:
        with click.progressbar(range(10), label="Waiting") as bar:
            for _ in bar:
                import time
                time.sleep(0.1)
    click.secho(f"✓ {name} started", fg="green")

@server.command()
@click.argument("name")
@click.option("--force", "-f", is_flag=True, help="Force stop")
@click.confirmation_option(prompt="Are you sure you want to stop?")
def stop(name, force):
    """Stop a server."""
    action = "Force stopping" if force else "Stopping"
    click.echo(f"{action} {name}...")
    click.secho(f"✓ {name} stopped", fg="yellow")


# ========== DEPLOY COMMANDS ==========
@cli.group()
def deploy():
    """Deployment commands."""
    pass

@deploy.command()
@click.argument("service")
@click.argument("environment", type=click.Choice(["dev", "staging", "prod"]))
@click.option("--version", "-v", default="latest", help="Version to deploy")
@click.option("--replicas", "-r", type=int, default=2, help="Number of replicas")
@click.option("--dry-run", is_flag=True, help="Preview changes")
@click.pass_context
def service(ctx, service, environment, version, replicas, dry_run):
    """Deploy a service to an environment."""
    
    if dry_run:
        click.secho("[DRY RUN]", fg="yellow", bold=True)
    
    click.echo(f"Deploying {service} v{version} to {environment}")
    click.echo(f"  Replicas: {replicas}")
    
    if environment == "prod" and not dry_run:
        if not click.confirm("Deploy to PRODUCTION?"):
            raise click.Abort()
    
    if not dry_run:
        with click.progressbar(range(5), label="Deploying") as bar:
            for _ in bar:
                import time
                time.sleep(0.3)
        click.secho("✓ Deployment complete", fg="green")

@deploy.command()
@click.argument("service")
@click.argument("environment", type=click.Choice(["dev", "staging", "prod"]))
@click.option("--to-version", help="Rollback to specific version")
def rollback(service, environment, to_version):
    """Rollback a deployment."""
    version = to_version or "previous"
    click.secho(f"Rolling back {service} to {version} in {environment}...", fg="yellow")
    click.secho("✓ Rollback complete", fg="green")


# ========== CONFIG COMMANDS ==========
@cli.group()
def config():
    """Configuration management."""
    pass

@config.command("show")
@click.pass_context
def config_show(ctx):
    """Show current configuration."""
    cfg = ctx.obj.get("config", {})
    if cfg:
        click.echo(yaml.dump(cfg, default_flow_style=False))
    else:
        click.echo("No configuration loaded")

@config.command("validate")
@click.argument("file", type=click.Path(exists=True))
def config_validate(file):
    """Validate a configuration file."""
    try:
        path = Path(file)
        if path.suffix in [".yaml", ".yml"]:
            with open(path) as f:
                yaml.safe_load(f)
        elif path.suffix == ".json":
            with open(path) as f:
                json.load(f)
        click.secho(f"✓ {file} is valid", fg="green")
    except Exception as e:
        click.secho(f"✗ Invalid: {e}", fg="red")
        raise click.Abort()


if __name__ == "__main__":
    cli()
```

---

## 📊 Quick Reference

### argparse vs Click

| Feature | argparse | Click |
|---------|----------|-------|
| Style | Imperative | Decorative |
| Learning curve | Steeper | Gentler |
| Subcommands | Verbose | Easy |
| Colors/progress | Manual | Built-in |
| Testing | Harder | Easier |
| Composability | Limited | Excellent |

### Common Click Decorators

```python
@click.command()           # Define a command
@click.group()             # Define a group of commands
@click.argument("name")    # Required positional arg
@click.option("--name")    # Optional flag
@click.pass_context        # Access context object
@click.version_option()    # Add --version
@click.confirmation_option()  # Add --yes confirmation
```

### Option Parameters

```python
@click.option(
    "--name", "-n",        # Long and short form
    default="value",       # Default value
    type=int,             # Type (int, float, str, etc.)
    required=True,        # Make it required
    multiple=True,        # Allow multiple values
    is_flag=True,         # Boolean flag
    envvar="NAME",        # Read from env var
    help="Description"    # Help text
)
```

---

## 🎯 Key Takeaways

✅ **Start with argparse** for simple scripts  
✅ **Use Click** for complex CLIs with subcommands  
✅ **Arguments are positional**, options are named flags  
✅ **Support environment variables** for CI/CD integration  
✅ **Add --help** automatically with both libraries  
✅ **Use password prompts** for sensitive input  
✅ **Add progress bars** for long operations  
✅ **Group related commands** with subcommands  

---

## 🚀 Next Steps

1. **Web Development** → See [12_devops_web_automation.md](12_devops_web_automation.md)


````
