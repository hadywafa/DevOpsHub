terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.116"
    }
  }

  # Remote state + locking: an Azure Storage Account with blob versioning
  # gives you both in one resource - locking is a native blob lease, no
  # separate DynamoDB-style table needed like on AWS.
  #
  # Bootstrap the storage account/container once, out of band (chicken-and-egg:
  # you can't store state for the thing that stores state), then either fill
  # these in or pass them via `terraform init -backend-config=...`:
  backend "azurerm" {
    # resource_group_name  = "rg-tfstate"
    # storage_account_name = "sttfstateai71demo"
    # container_name       = "tfstate"
    # key                  = "azure-aks-platform.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}
