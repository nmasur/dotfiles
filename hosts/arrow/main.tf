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

# locals {
#   image_file = one(fileset(path.root, "result/iso/nixos.iso"))
# }

# variable "cloudflare_r2_endpoint" {
#   type        = string
#   description = "Domain for the Cloudflare R2 endpoint"
# }

variable "vultr_api_key" {
  type        = string
  description = "API key for Vultr management"
  sensitive   = true
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

# data "aws_s3_bucket" "images" {
#   bucket = "noahmasur-arrow-images"
# }
#
# resource "aws_s3_object" "image" {
#   bucket = data.aws_s3_bucket.images.id
#   key    = "arrow.iso"
#   source = local.image_file
#   etag   = filemd5(local.image_file)
#   acl    = "public-read"
# }

resource "vultr_iso_private" "image" {
  # url = "https://${var.cloudflare_account_id}.r2.cloudflarestorage.com/${data.aws_s3_bucket.images.id}/${aws_s3_object.image.key}"
  url = "https://arrow.images.masu.rs/arrow.iso"
}

resource "vultr_instance" "arrow" {
  plan                = "vc2-1c-2gb"
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
