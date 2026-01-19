# Common Python Modules for Azure DevOps

Essential Python libraries and modules for Azure infrastructure management, automation, and DevOps workflows.

---

## 📦 PART 1: Azure SDK Modules (Official Azure SDKs)

### 1.1 Azure Identity (Authentication)
```bash
pip install azure-identity
```

```python
from azure.identity import DefaultAzureCredential, ClientSecretCredential

# Multi-method authentication (CLI, Managed Identity, Environment Variables)
credential = DefaultAzureCredential()

# Service Principal authentication
credential = ClientSecretCredential(
    tenant_id="your-tenant-id",
    client_id="your-client-id",
    client_secret="your-secret"
)
```

**Use Cases:**
- Authenticate to Azure services
- Use Managed Identity in Azure VMs/containers
- Service Principal for automation
- Azure CLI authentication

---

### 1.2 Azure Resource Management
```bash
pip install azure-mgmt-resource
```

```python
from azure.mgmt.resource import ResourceManagementClient
from azure.identity import DefaultAzureCredential

credential = DefaultAzureCredential()
subscription_id = "your-subscription-id"

# Create resource client
resource_client = ResourceManagementClient(credential, subscription_id)

# List all resource groups
for rg in resource_client.resource_groups.list():
    print(f"Resource Group: {rg.name}, Location: {rg.location}")

# Create resource group
rg_result = resource_client.resource_groups.create_or_update(
    "my-rg",
    {"location": "eastus"}
)

# List resources in a resource group
for resource in resource_client.resources.list_by_resource_group("my-rg"):
    print(f"{resource.name} ({resource.type})")
```

**Use Cases:**
- Manage resource groups
- Deploy ARM templates
- Query resources
- Tag management

---

### 1.3 Azure Compute (Virtual Machines)
```bash
pip install azure-mgmt-compute
```

```python
from azure.mgmt.compute import ComputeManagementClient
from azure.identity import DefaultAzureCredential

credential = DefaultAzureCredential()
compute_client = ComputeManagementClient(credential, "subscription-id")

# List all VMs
for vm in compute_client.virtual_machines.list_all():
    print(f"VM: {vm.name}, Size: {vm.hardware_profile.vm_size}")

# Start VM
async_vm_start = compute_client.virtual_machines.begin_start(
    resource_group_name="my-rg",
    vm_name="my-vm"
)
async_vm_start.result()  # Wait for completion

# Stop VM
async_vm_stop = compute_client.virtual_machines.begin_deallocate(
    "my-rg", "my-vm"
)
async_vm_stop.result()

# Get VM details
vm = compute_client.virtual_machines.get("my-rg", "my-vm")
print(f"Status: {vm.provisioning_state}")
```

**Use Cases:**
- VM lifecycle management (start/stop/restart)
- Create/delete VMs
- Resize VMs
- VM monitoring and metrics

---

### 1.4 Azure Storage
```bash
pip install azure-storage-blob azure-storage-file-share
```

```python
from azure.storage.blob import BlobServiceClient, BlobClient
from azure.identity import DefaultAzureCredential

# Using Managed Identity
credential = DefaultAzureCredential()
blob_service_client = BlobServiceClient(
    account_url="https://mystorageaccount.blob.core.windows.net",
    credential=credential
)

# Or using connection string
connection_string = "DefaultEndpointsProtocol=https;AccountName=..."
blob_service_client = BlobServiceClient.from_connection_string(connection_string)

# Upload file
blob_client = blob_service_client.get_blob_client(
    container="deployments",
    blob="app-v1.2.3.zip"
)
with open("app.zip", "rb") as data:
    blob_client.upload_blob(data, overwrite=True)

# Download file
with open("downloaded.zip", "wb") as download_file:
    download_file.write(blob_client.download_blob().readall())

# List blobs
container_client = blob_service_client.get_container_client("deployments")
for blob in container_client.list_blobs():
    print(f"Blob: {blob.name}, Size: {blob.size} bytes")
```

**Use Cases:**
- Artifact storage
- Backup and restore
- Log file storage
- Configuration file management

---

### 1.5 Azure Container Instances (ACI)
```bash
pip install azure-mgmt-containerinstance
```

```python
from azure.mgmt.containerinstance import ContainerInstanceManagementClient
from azure.mgmt.containerinstance.models import (
    Container, ContainerGroup, ResourceRequirements, 
    ResourceRequests, OperatingSystemTypes
)

aci_client = ContainerInstanceManagementClient(credential, subscription_id)

# Create container
container_resource_requests = ResourceRequests(memory_in_gb=1, cpu=1.0)
container_resource_requirements = ResourceRequirements(requests=container_resource_requests)

container = Container(
    name="my-app",
    image="nginx:latest",
    resources=container_resource_requirements,
    ports=[{"port": 80}]
)

container_group = ContainerGroup(
    location="eastus",
    containers=[container],
    os_type=OperatingSystemTypes.linux,
    ip_address={"type": "Public", "ports": [{"protocol": "TCP", "port": 80}]}
)

aci_client.container_groups.begin_create_or_update(
    "my-rg",
    "my-container-group",
    container_group
)

# Get container logs
logs = aci_client.containers.list_logs("my-rg", "my-container-group", "my-app")
print(logs.content)
```

**Use Cases:**
- Run batch jobs
- CI/CD build agents
- Temporary workloads
- Event-driven processing

---

### 1.6 Azure Kubernetes Service (AKS)
```bash
pip install azure-mgmt-containerservice
```

```python
from azure.mgmt.containerservice import ContainerServiceClient

aks_client = ContainerServiceClient(credential, subscription_id)

# List AKS clusters
for cluster in aks_client.managed_clusters.list():
    print(f"Cluster: {cluster.name}, Version: {cluster.kubernetes_version}")

# Get cluster credentials
credentials = aks_client.managed_clusters.list_cluster_admin_credentials(
    "my-rg",
    "my-aks-cluster"
)

# Scale node pool
aks_client.agent_pools.begin_create_or_update(
    resource_group_name="my-rg",
    resource_name="my-aks-cluster",
    agent_pool_name="nodepool1",
    parameters={"count": 5}
)
```

**Use Cases:**
- Manage AKS clusters
- Scale node pools
- Get cluster credentials
- Update cluster configuration

---

### 1.7 Azure Key Vault
```bash
pip install azure-keyvault-secrets azure-keyvault-keys
```

```python
from azure.keyvault.secrets import SecretClient
from azure.identity import DefaultAzureCredential

credential = DefaultAzureCredential()
vault_url = "https://my-keyvault.vault.azure.net/"
secret_client = SecretClient(vault_url=vault_url, credential=credential)

# Set secret
secret_client.set_secret("db-password", "super-secret-password")

# Get secret
secret = secret_client.get_secret("db-password")
print(f"Secret value: {secret.value}")

# List secrets
for secret_properties in secret_client.list_properties_of_secrets():
    print(f"Secret: {secret_properties.name}")

# Delete secret
secret_client.begin_delete_secret("db-password")
```

**Use Cases:**
- Store passwords, API keys, certificates
- Rotate secrets automatically
- Centralized secret management
- Application configuration

---

### 1.8 Azure Monitor
```bash
pip install azure-mgmt-monitor azure-monitor-query
```

```python
from azure.mgmt.monitor import MonitorManagementClient
from azure.monitor.query import LogsQueryClient, MetricsQueryClient
from datetime import datetime, timedelta

monitor_client = MonitorManagementClient(credential, subscription_id)

# Get metrics
metrics_client = MetricsQueryClient(credential)
response = metrics_client.query_resource(
    resource_uri="/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/my-vm",
    metric_names=["Percentage CPU"],
    timespan=timedelta(hours=1)
)

for metric in response.metrics:
    print(f"Metric: {metric.name}")
    for time_series in metric.timeseries:
        for data_point in time_series.data:
            print(f"{data_point.time_stamp}: {data_point.average}%")

# Query logs (Log Analytics)
logs_client = LogsQueryClient(credential)
query = """
AzureActivity
| where TimeGenerated > ago(1h)
| summarize count() by OperationNameValue
| order by count_ desc
"""

response = logs_client.query_workspace(
    workspace_id="workspace-id",
    query=query,
    timespan=timedelta(hours=1)
)

for table in response.tables:
    for row in table.rows:
        print(row)
```

**Use Cases:**
- Query application logs
- Get resource metrics
- Create custom alerts
- Performance monitoring

---

### 1.9 Azure DevOps (Python API)
```bash
pip install azure-devops
```

```python
from azure.devops.connection import Connection
from msrest.authentication import BasicAuthentication

# Connect to Azure DevOps
personal_access_token = "your-pat-token"
organization_url = "https://dev.azure.com/your-org"

credentials = BasicAuthentication('', personal_access_token)
connection = Connection(base_url=organization_url, creds=credentials)

# Get build client
build_client = connection.clients.get_build_client()

# List builds
builds = build_client.get_builds(project="MyProject")
for build in builds:
    print(f"Build #{build.id}: {build.status}")

# Queue new build
from azure.devops.v7_0.build.models import Build
build_definition_reference = {"id": 1}  # Build definition ID
build = Build(definition=build_definition_reference)
queued_build = build_client.queue_build(build=build, project="MyProject")

# Get work item client
wit_client = connection.clients.get_work_item_tracking_client()

# Query work items
wiql = """
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug' AND [System.State] = 'Active'
"""
wiql_result = wit_client.query_by_wiql({"query": wiql})

# Get repositories
git_client = connection.clients.get_git_client()
repos = git_client.get_repositories(project="MyProject")
for repo in repos:
    print(f"Repo: {repo.name}")
```

**Use Cases:**
- Automate build pipelines
- Query work items
- Create pull requests
- Release management
- Repository operations

---

## 📦 PART 2: Infrastructure as Code

### 2.1 Pulumi (Python-based IaC)
```bash
pip install pulumi pulumi-azure-native
```

```python
import pulumi
import pulumi_azure_native as azure

# Create resource group
resource_group = azure.resources.ResourceGroup("my-rg",
    location="eastus"
)

# Create storage account
storage_account = azure.storage.StorageAccount("mystorageacct",
    resource_group_name=resource_group.name,
    location=resource_group.location,
    sku=azure.storage.SkuArgs(name="Standard_LRS"),
    kind="StorageV2"
)

# Create App Service
app_service_plan = azure.web.AppServicePlan("my-plan",
    resource_group_name=resource_group.name,
    location=resource_group.location,
    sku=azure.web.SkuDescriptionArgs(
        name="B1",
        tier="Basic"
    )
)

app_service = azure.web.WebApp("my-app",
    resource_group_name=resource_group.name,
    server_farm_id=app_service_plan.id,
    location=resource_group.location
)

# Export outputs
pulumi.export("app_url", app_service.default_host_name)
pulumi.export("storage_account_name", storage_account.name)
```

**Use Cases:**
- Define infrastructure in Python
- Version control infrastructure
- Multi-cloud deployments
- Reusable components

---

### 2.2 Python Terraform (terraform-python)
```bash
pip install python-terraform
```

```python
from python_terraform import Terraform

# Initialize Terraform
tf = Terraform(working_dir='./terraform')

# Initialize
return_code, stdout, stderr = tf.init()

# Plan
return_code, stdout, stderr = tf.plan(
    var={'resource_group_name': 'my-rg', 'location': 'eastus'}
)

# Apply
return_code, stdout, stderr = tf.apply(
    skip_plan=True,
    var={'resource_group_name': 'my-rg'}
)

# Destroy
return_code, stdout, stderr = tf.destroy(
    var={'resource_group_name': 'my-rg'},
    auto_approve=True
)

# Get outputs
output = tf.output()
print(output)
```

**Use Cases:**
- Automate Terraform workflows
- CI/CD integration
- Dynamic infrastructure provisioning
- Infrastructure testing

---

## 📦 PART 3: Configuration & Orchestration

### 3.1 Ansible (ansible-core)
```bash
pip install ansible ansible-pylibssh
pip install ansible[azure]  # Azure collection
```

```python
# Python script to run Ansible playbooks
import ansible_runner

# Run playbook
r = ansible_runner.run(
    private_data_dir='/tmp/demo',
    playbook='deploy.yml',
    inventory='hosts.ini',
    extravars={'app_version': 'v1.2.3'}
)

print(f"Status: {r.status}")
print(f"Return Code: {r.rc}")

# Access results
for event in r.events:
    print(event['event'])
```

**Ansible Playbook for Azure:**
```yaml
# deploy.yml
- hosts: localhost
  tasks:
    - name: Create resource group
      azure_rm_resourcegroup:
        name: myResourceGroup
        location: eastus
    
    - name: Create virtual network
      azure_rm_virtualnetwork:
        resource_group: myResourceGroup
        name: myVNet
        address_prefixes: "10.0.0.0/16"
```

**Use Cases:**
- Configuration management
- Application deployment
- Multi-server orchestration
- Idempotent operations

---

### 3.2 Fabric (Remote Execution)
```bash
pip install fabric
```

```python
from fabric import Connection, task

# Execute commands on remote servers
def deploy_app():
    servers = ['web1.example.com', 'web2.example.com']
    
    for server in servers:
        with Connection(server, user='ubuntu') as conn:
            # Pull latest code
            conn.run('cd /app && git pull origin main')
            
            # Restart service
            conn.sudo('systemctl restart myapp')
            
            # Check status
            result = conn.run('systemctl status myapp', hide=True)
            print(f"{server}: {result.stdout}")

# Fabric tasks
@task
def deploy(ctx, environment='dev'):
    """Deploy application"""
    ctx.run(f'echo "Deploying to {environment}"')
    ctx.run('docker build -t myapp:latest .')
    ctx.run(f'docker push myregistry.azurecr.io/myapp:latest')
```

**Use Cases:**
- Remote command execution
- Deployment automation
- Server configuration
- Log collection

---

## 📦 PART 4: CI/CD & Testing

### 4.1 PyTest (Testing Framework)
```bash
pip install pytest pytest-azurepipelines pytest-cov
```

```python
# test_infrastructure.py
import pytest
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

@pytest.fixture
def compute_client():
    credential = DefaultAzureCredential()
    return ComputeManagementClient(credential, "subscription-id")

def test_vm_exists(compute_client):
    """Test that VM exists in resource group"""
    vms = list(compute_client.virtual_machines.list("my-rg"))
    assert len(vms) > 0, "No VMs found"

def test_vm_running(compute_client):
    """Test that VM is running"""
    vm = compute_client.virtual_machines.instance_view("my-rg", "my-vm")
    statuses = vm.statuses
    power_state = next((s.code for s in statuses if s.code.startswith('PowerState/')), None)
    assert power_state == 'PowerState/running', f"VM not running: {power_state}"

# Run: pytest test_infrastructure.py -v --cov
```

**Use Cases:**
- Infrastructure testing
- API testing
- Integration tests
- CI/CD pipeline validation

---

### 4.2 Requests (HTTP Client)
```bash
pip install requests
```

```python
import requests

# Call Azure REST API directly
def get_resource_groups(subscription_id, access_token):
    url = f"https://management.azure.com/subscriptions/{subscription_id}/resourcegroups"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    params = {"api-version": "2021-04-01"}
    
    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    return response.json()

# Health check endpoints
def check_app_health(url):
    try:
        response = requests.get(f"{url}/health", timeout=5)
        return response.status_code == 200
    except requests.RequestException:
        return False

# Webhook notifications
def send_teams_notification(webhook_url, message):
    payload = {
        "text": message,
        "title": "Deployment Notification"
    }
    requests.post(webhook_url, json=payload)
```

**Use Cases:**
- API testing
- Health checks
- Webhook integrations
- REST API calls

---

## 📦 PART 5: Monitoring & Logging

### 5.1 OpenCensus (Azure Monitor Integration)
```bash
pip install opencensus-ext-azure opencensus-ext-flask
```

```python
from opencensus.ext.azure import metrics_exporter
from opencensus.ext.azure.log_exporter import AzureLogHandler
import logging

# Setup logging to Application Insights
logger = logging.getLogger(__name__)
logger.addHandler(AzureLogHandler(
    connection_string='InstrumentationKey=your-key'
))

logger.info("Application started")
logger.warning("High CPU detected", extra={'cpu_percent': 95})

# Custom metrics
exporter = metrics_exporter.new_metrics_exporter(
    connection_string='InstrumentationKey=your-key'
)

# Track custom metrics
def track_deployment_time(duration_seconds):
    logger.info("Deployment completed", extra={
        'custom_dimensions': {
            'duration': duration_seconds,
            'environment': 'production'
        }
    })
```

**Use Cases:**
- Application telemetry
- Custom metrics
- Distributed tracing
- Performance monitoring

---

### 5.2 Python-JSON-Logger (Structured Logging)
```bash
pip install python-json-logger
```

```python
from pythonjsonlogger import jsonlogger
import logging

# Setup JSON logging
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
logHandler.setFormatter(formatter)

logger = logging.getLogger()
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)

# Log with context
logger.info("Server started", extra={
    'server_id': 'web-01',
    'ip': '192.168.1.10',
    'environment': 'production',
    'version': 'v1.2.3'
})
```

**Use Cases:**
- Structured logging
- Log aggregation (ELK, Splunk)
- Azure Log Analytics
- Debugging in production

---

## 📦 PART 6: Container & Kubernetes

### 6.1 Docker SDK
```bash
pip install docker
```

```python
import docker

# Connect to Docker
client = docker.from_env()

# List containers
for container in client.containers.list():
    print(f"{container.name}: {container.status}")

# Run container
container = client.containers.run(
    "nginx:latest",
    name="my-web-server",
    ports={'80/tcp': 8080},
    detach=True
)

# Get logs
logs = container.logs()
print(logs.decode())

# Stop and remove
container.stop()
container.remove()

# Build image
image, logs = client.images.build(
    path="./app",
    tag="myapp:latest"
)

# Push to ACR
client.login(
    username="myregistry",
    password="password",
    registry="myregistry.azurecr.io"
)
client.images.push("myregistry.azurecr.io/myapp:latest")
```

**Use Cases:**
- Container lifecycle management
- Image building
- Registry operations
- Local testing

---

### 6.2 Kubernetes Python Client
```bash
pip install kubernetes
```

```python
from kubernetes import client, config

# Load kubeconfig
config.load_kube_config()

# Create API client
v1 = client.CoreV1Api()
apps_v1 = client.AppsV1Api()

# List pods
pods = v1.list_namespaced_pod(namespace="default")
for pod in pods.items:
    print(f"Pod: {pod.metadata.name}, Status: {pod.status.phase}")

# Create deployment
deployment = client.V1Deployment(
    metadata=client.V1ObjectMeta(name="nginx-deployment"),
    spec=client.V1DeploymentSpec(
        replicas=3,
        selector=client.V1LabelSelector(
            match_labels={"app": "nginx"}
        ),
        template=client.V1PodTemplateSpec(
            metadata=client.V1ObjectMeta(labels={"app": "nginx"}),
            spec=client.V1PodSpec(
                containers=[
                    client.V1Container(
                        name="nginx",
                        image="nginx:latest",
                        ports=[client.V1ContainerPort(container_port=80)]
                    )
                ]
            )
        )
    )
)

apps_v1.create_namespaced_deployment(namespace="default", body=deployment)

# Scale deployment
apps_v1.patch_namespaced_deployment_scale(
    name="nginx-deployment",
    namespace="default",
    body={"spec": {"replicas": 5}}
)

# Get logs
logs = v1.read_namespaced_pod_log(
    name="nginx-deployment-xxx",
    namespace="default"
)
print(logs)
```

**Use Cases:**
- Kubernetes automation
- Deployment management
- Pod operations
- Monitoring and scaling

---

## 📦 PART 7: Security & Secrets

### 7.1 Cryptography
```bash
pip install cryptography
```

```python
from cryptography.fernet import Fernet

# Generate key
key = Fernet.generate_key()
cipher_suite = Fernet(key)

# Encrypt
plaintext = b"my-database-password"
encrypted = cipher_suite.encrypt(plaintext)

# Decrypt
decrypted = cipher_suite.decrypt(encrypted)

# Use for storing sensitive config
import json
config = {
    "db_password": encrypted.decode(),
    "api_key": cipher_suite.encrypt(b"secret-api-key").decode()
}
with open("config.encrypted.json", "w") as f:
    json.dump(config, f)
```

**Use Cases:**
- Encrypt configuration files
- Secure API keys
- Password management
- Data encryption

---

### 7.2 Python-dotenv (Environment Variables)
```bash
pip install python-dotenv
```

```python
from dotenv import load_dotenv
import os

# Load from .env file
load_dotenv()

# Access variables
subscription_id = os.getenv("AZURE_SUBSCRIPTION_ID")
tenant_id = os.getenv("AZURE_TENANT_ID")
client_id = os.getenv("AZURE_CLIENT_ID")
client_secret = os.getenv("AZURE_CLIENT_SECRET")

# .env file example:
"""
AZURE_SUBSCRIPTION_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
AZURE_TENANT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
AZURE_CLIENT_ID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
AZURE_CLIENT_SECRET=your-secret-here
ENVIRONMENT=production
```
```

**Use Cases:**
- Configuration management
- Keep secrets out of code
- Environment-specific settings
- Local development

---

## 📦 PART 8: Utilities & Helpers

### 8.1 Click (CLI Tool Creation)
```bash
pip install click
```

```python
import click
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

@click.group()
def cli():
    """Azure DevOps CLI Tool"""
    pass

@cli.command()
@click.option('--rg', required=True, help='Resource group name')
@click.option('--name', required=True, help='VM name')
def start_vm(rg, name):
    """Start an Azure VM"""
    credential = DefaultAzureCredential()
    compute_client = ComputeManagementClient(credential, subscription_id)
    
    click.echo(f"Starting VM {name}...")
    compute_client.virtual_machines.begin_start(rg, name).result()
    click.echo(click.style("VM started successfully!", fg='green'))

@cli.command()
@click.option('--rg', required=True)
def list_vms(rg):
    """List all VMs in resource group"""
    credential = DefaultAzureCredential()
    compute_client = ComputeManagementClient(credential, subscription_id)
    
    for vm in compute_client.virtual_machines.list(rg):
        click.echo(f"- {vm.name}")

if __name__ == '__main__':
    cli()

# Usage:
# python azure_cli.py start-vm --rg my-rg --name my-vm
# python azure_cli.py list-vms --rg my-rg
```

**Use Cases:**
- Create custom CLI tools
- Automate common tasks
- Team utilities
- Pipeline scripts

---

### 8.2 Rich (Beautiful Terminal Output)
```bash
pip install rich
```

```python
from rich.console import Console
from rich.table import Table
from rich.progress import track
import time

console = Console()

# Pretty print
console.print("[bold green]Deployment started![/bold green]")

# Tables
table = Table(title="Azure Resources")
table.add_column("Name", style="cyan")
table.add_column("Type", style="magenta")
table.add_column("Status", style="green")

table.add_row("web-01", "VM", "Running")
table.add_row("db-01", "Database", "Online")
table.add_row("storage", "Storage", "Available")

console.print(table)

# Progress bars
for step in track(range(10), description="Deploying..."):
    time.sleep(0.5)

# JSON pretty print
data = {"name": "web-01", "status": "running", "cpu": 75.5}
console.print_json(data=data)
```

**Use Cases:**
- Beautiful CLI output
- Progress indicators
- Formatted tables
- Better user experience

---

### 8.3 Schedule (Task Scheduling)
```bash
pip install schedule
```

```python
import schedule
import time

def backup_databases():
    print("Running database backup...")
    # Backup logic here

def check_vm_health():
    print("Checking VM health...")
    # Health check logic

# Schedule tasks
schedule.every().day.at("02:00").do(backup_databases)
schedule.every(5).minutes.do(check_vm_health)
schedule.every().monday.at("09:00").do(send_weekly_report)

# Run scheduler
while True:
    schedule.run_pending()
    time.sleep(60)
```

**Use Cases:**
- Scheduled maintenance
- Periodic health checks
- Automated backups
- Report generation

---

## 📦 PART 9: Data Processing

### 9.1 Pandas (Data Analysis)
```bash
pip install pandas
```

```python
import pandas as pd

# Load Azure cost data
cost_data = pd.read_csv("azure_costs.csv")

# Analyze by resource group
cost_by_rg = cost_data.groupby('ResourceGroup')['Cost'].sum()
print(cost_by_rg.sort_values(ascending=False))

# Find high-cost resources
high_cost = cost_data[cost_data['Cost'] > 1000]
print(high_cost[['ResourceName', 'ResourceType', 'Cost']])

# Export to Excel
with pd.ExcelWriter('azure_report.xlsx') as writer:
    cost_by_rg.to_excel(writer, sheet_name='Cost by RG')
    high_cost.to_excel(writer, sheet_name='High Cost Resources')
```

**Use Cases:**
- Cost analysis
- Usage reports
- Performance metrics analysis
- Capacity planning

---

### 9.2 PyYAML (YAML Processing)
```bash
pip install pyyaml
```

```python
import yaml

# Read Azure DevOps pipeline
with open('azure-pipelines.yml', 'r') as f:
    pipeline = yaml.safe_load(f)

# Modify pipeline
pipeline['trigger']['branches']['include'].append('feature/*')

# Write back
with open('azure-pipelines.yml', 'w') as f:
    yaml.dump(pipeline, f, default_flow_style=False)

# Create Kubernetes manifest
k8s_deployment = {
    'apiVersion': 'apps/v1',
    'kind': 'Deployment',
    'metadata': {'name': 'my-app'},
    'spec': {
        'replicas': 3,
        'selector': {'matchLabels': {'app': 'my-app'}},
        'template': {
            'metadata': {'labels': {'app': 'my-app'}},
            'spec': {
                'containers': [{
                    'name': 'my-app',
                    'image': 'myregistry.azurecr.io/my-app:latest',
                    'ports': [{'containerPort': 80}]
                }]
            }
        }
    }
}

with open('deployment.yaml', 'w') as f:
    yaml.dump(k8s_deployment, f)
```

**Use Cases:**
- Pipeline configuration
- Kubernetes manifests
- Configuration files
- Documentation generation

---

## 📋 COMPLETE MODULE LIST

### Essential for Azure DevOps:
```bash
# Authentication & Management
pip install azure-identity
pip install azure-mgmt-resource
pip install azure-mgmt-compute
pip install azure-mgmt-storage
pip install azure-mgmt-containerinstance
pip install azure-mgmt-containerservice
pip install azure-mgmt-monitor
pip install azure-keyvault-secrets

# Storage & Data
pip install azure-storage-blob
pip install azure-storage-file-share

# DevOps & CI/CD
pip install azure-devops
pip install pytest pytest-cov

# Infrastructure as Code
pip install pulumi pulumi-azure-native
pip install python-terraform

# Containers & Orchestration
pip install docker
pip install kubernetes

# Utilities
pip install requests
pip install pyyaml
pip install python-dotenv
pip install click
pip install rich
pip install pandas

# Monitoring & Logging
pip install opencensus-ext-azure
pip install python-json-logger
```

### Nice to Have:
```bash
pip install ansible
pip install fabric
pip install schedule
pip install cryptography
pip install jinja2  # Template rendering
pip install tabulate  # Pretty tables
pip install tqdm  # Progress bars
pip install colorama  # Colored output
```

---

## 🎯 COMMON DEVOPS WORKFLOWS

### 1. VM Management Script
```python
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.resource import ResourceManagementClient

credential = DefaultAzureCredential()
subscription_id = "your-subscription-id"

compute_client = ComputeManagementClient(credential, subscription_id)
resource_client = ResourceManagementClient(credential, subscription_id)

def start_all_vms_in_rg(resource_group):
    """Start all stopped VMs in a resource group"""
    for vm in compute_client.virtual_machines.list(resource_group):
        instance_view = compute_client.virtual_machines.instance_view(
            resource_group, vm.name
        )
        statuses = instance_view.statuses
        power_state = next((s.code for s in statuses if 'PowerState' in s.code), None)
        
        if power_state == 'PowerState/deallocated':
            print(f"Starting {vm.name}...")
            compute_client.virtual_machines.begin_start(
                resource_group, vm.name
            ).result()
            print(f"✓ {vm.name} started")
```

### 2. Deployment Automation
```python
import requests
from azure.storage.blob import BlobServiceClient

def deploy_application(version, environment):
    """Complete deployment workflow"""
    # 1. Download artifact from blob storage
    blob_client = BlobServiceClient.from_connection_string(conn_str)
    blob_client.get_blob_client("artifacts", f"app-{version}.zip").download_to_stream(
        open("app.zip", "wb")
    )
    
    # 2. Deploy to VMs using Fabric
    from fabric import Connection
    for server in get_servers(environment):
        with Connection(server) as conn:
            conn.put("app.zip", "/tmp/app.zip")
            conn.run("unzip -o /tmp/app.zip -d /app")
            conn.sudo("systemctl restart app")
    
    # 3. Health check
    for server in get_servers(environment):
        if not check_health(f"http://{server}/health"):
            raise Exception(f"Health check failed for {server}")
    
    # 4. Send notification
    send_teams_webhook(f"Deployment {version} to {environment} completed!")
```

### 3. Cost Monitoring
```python
from azure.mgmt.costmanagement import CostManagementClient
import pandas as pd

def generate_cost_report(subscription_id):
    """Generate monthly cost report"""
    cost_client = CostManagementClient(credential)
    
    # Query costs
    # ... cost query logic ...
    
    # Analyze with pandas
    df = pd.DataFrame(cost_data)
    
    # Generate report
    report = {
        'total_cost': df['Cost'].sum(),
        'top_resources': df.nlargest(10, 'Cost'),
        'cost_by_service': df.groupby('ServiceName')['Cost'].sum()
    }
    
    return report
```

---

## 🚀 BEST PRACTICES

1. **Use Managed Identity** when running in Azure (VM, AKS, App Service)
2. **Store secrets in Key Vault** - never in code
3. **Use requirements.txt** for dependency management
4. **Pin versions** to avoid breaking changes
5. **Use virtual environments** for isolation
6. **Implement retry logic** for Azure API calls
7. **Add logging** to all operations
8. **Handle exceptions** gracefully
9. **Use async where possible** for better performance
10. **Test infrastructure changes** in dev/staging first

---

## 📚 LEARNING RESOURCES

- **Azure SDK for Python**: https://docs.microsoft.com/python/azure/
- **Azure Architecture**: https://docs.microsoft.com/azure/architecture/
- **Python Best Practices**: https://docs.python-guide.org/
- **DevOps with Python**: https://www.python.org/dev/peps/

---

This guide covers the most common Python modules used in Azure DevOps workflows!
