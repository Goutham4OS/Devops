# =============================================================================
# VARIABLES - Input parameters for deployment
# =============================================================================

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "app_name" {
  description = "Name of the application (used in resource names)"
  type        = string
  default     = "k8svalidator"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region to deploy to"
  type        = string
  default     = "eastus"  # Change to your preferred region
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "v1"
}
