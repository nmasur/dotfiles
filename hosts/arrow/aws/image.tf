# locals {
#   image_file = one(fileset(path.root, "../../../result/nixos-amazon-image-*.vhd"))
# }
#
# # Upload image to S3
# resource "aws_s3_object" "image" {
#   bucket = var.images_bucket
#   key    = basename(local.image_file)
#   source = local.image_file
#   etag   = filemd5(local.image_file)
# }

# Use existing image in S3
data "aws_s3_object" "image" {
  bucket = var.images_bucket
  key    = "arrow.vhd"
}

resource "terraform_data" "image_replacement" {
  input = data.aws_s3_object.image.etag
}

# Setup IAM access for the VM Importer
data "aws_iam_policy_document" "vmimport_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vmie.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "vmimport" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${data.aws_s3_object.image.bucket}",
      "arn:aws:s3:::${data.aws_s3_object.image.bucket}/*",
    ]
  }
  statement {
    actions = [
      "ec2:ModifySnapshotAttribute",
      "ec2:CopySnapshot",
      "ec2:RegisterImage",
      "ec2:Describe*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "vmimport" {
  name               = "vmimport"
  assume_role_policy = data.aws_iam_policy_document.vmimport_trust_policy.json
  inline_policy {
    name   = "vmimport"
    policy = data.aws_iam_policy_document.vmimport.json
  }
}

# Import to EBS
resource "aws_ebs_snapshot_import" "image" {
  disk_container {
    format = "VHD"
    user_bucket {
      s3_bucket = data.aws_s3_object.image.bucket
      s3_key    = data.aws_s3_object.image.key
    }
  }

  role_name = aws_iam_role.vmimport.name
  lifecycle {
    replace_triggered_by = [terraform_data.image_replacement]
  }
}

# Convert to AMI
resource "aws_ami" "image" {
  description         = "Created with NixOS."
  name                = replace(basename(data.aws_s3_object.image.key), "/\\.vhd$/", "")
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"
  ena_support         = true

  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = aws_ebs_snapshot_import.image.id
    volume_size = 17
  }
}
