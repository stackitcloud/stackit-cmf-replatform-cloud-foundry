terraform {
  required_version = ">= 1.5.0"
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">= 0.94.0"
    }
  }
}

provider "stackit" {
  # Configuration via environment variables
}
