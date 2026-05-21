terraform {
  required_version = ">= 1.5.0"
  required_providers {
    stackit = {
      source  = "stackitcloud/stackit"
      version = ">= 0.94.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = ">= 1.15.0"
    }
    zipper = {
      source  = "ArthurHlt/zipper"
      version = ">= 0.3.0"
    }
  }
}

provider "stackit" {
  default_region           = var.region
  enable_beta_resources    = var.enable_beta_resources
  service_account_key_path = var.service_account_key_path
}

provider "cloudfoundry" {
  api_url  = var.cf_api_url
  user     = var.cf_username
  password = var.cf_password
}

provider "zipper" {}
