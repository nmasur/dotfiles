terraform {
  backend "s3" {
    bucket                      = "noahmasur-terraform"
    key                         = "arrow.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    /*
      ENVIRONMENT VARIABLES
      ---------------------
      AWS_ACCESS_KEY_ID     - R2 token
      AWS_SECRET_ACCESS_KEY - R2 secret
      AWS_ENDPOINT_URL_S3   - R2 location: https://ACCOUNT_ID.r2.cloudflarestorage.com
    */
  }
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0"
    }
    vultr = {
      source  = "vultr/vultr"
      version = "2.19.0"
    }
  }
}

variable "vultr_api_key" {
  type        = string
  description = "API key for Vultr management"
  sensitive   = true
}

# https://api.vultr.com/v2/plans
variable "vultr_plan" {
  type        = string
  description = "Size of instance to launch"
  default     = "vc2-1c-2gb" # 55 GB SSD ($10/mo)
}

provider "aws" {
  region                      = "auto"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
}

provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_iso_private" "image" {
  # url = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com/${data.aws_s3_bucket.images.id}/${aws_s3_object.image.key}"
  url = "https://arrow-images.masu.rs/arrow.iso"
}

resource "vultr_instance" "arrow" {
  plan                = var.vultr_plan
  region              = "ewr"
  iso_id              = vultr_iso_private.image.id
  label               = "arrow"
  tags                = ["arrow"]
  enable_ipv6         = false
  disable_public_ipv4 = false
  backups             = "disabled"
  ddos_protection     = false
  activation_email    = false
}

output "host_ip" {
  value = vultr_instance.arrow.main_ip
}
