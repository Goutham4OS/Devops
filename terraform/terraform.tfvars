# =============================================================================
# TERRAFORM VARIABLES - Edit these values!
# =============================================================================

# Your Azure Subscription ID (from: az account show --query id -o tsv)
subscription_id = "9c726b7d-61d4-4d41-9f52-6560adc863d9"

# Your app name (lowercase, no special chars)
app_name = "k8svalidator"

# Environment (dev, staging, prod)
environment = "dev"

# Azure region - pick one close to you
# Options: eastus, westus2, westeurope, northeurope, southeastasia, etc.
location = "eastus"

# Docker image tag
image_tag = "v1"
