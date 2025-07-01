variable "boot_volume_size_in_gbs" {
  description = "The size of the boot volume in GBs."
  type        = number
  default     = 150
}

variable "cloud_init_script" {
  description = "A cloud-init script to run on instance launch."
  type        = string
  default     = <<-EOF
              #!/bin/bash
              echo "Hello from cloud-init!" > /home/ubuntu/cloud-init-output.txt
              EOF
}

variable "compartment_ocid" {
  description = "The OCID of the compartment where the instance will be created."
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaaudwr2ozedhjnrn76ofjgglgug6gexknjisd7gb7tkj3mjdp763da"
}

variable "instance_display_name" {
  description = "A user-friendly name for the instance."
  type        = string
  default     = "noah-nixos"
}

variable "instance_shape" {
  description = "The shape of the OCI compute instance."
  type        = string
  default     = "VM.Standard.A1.Flex" # Example shape. Choose one available in your region/AD.
}

variable "object_storage_namespace" {
  description = "Your OCI Object Storage namespace (usually your tenancy name)."
  type        = string
  default     = "idptr5akf9pf"
}

variable "object_storage_bucket_name" {
  description = "The name of the Object Storage bucket where your custom image is located."
  type        = string
  default     = "noahmasur-images"
}

variable "object_storage_object_name" {
  description = "The object name (file name) of your custom image in Object Storage."
  type        = string
  default     = "nixos.qcow2"
}

variable "oci_private_key" {
  type        = string
  description = "API private key for Oracle Cloud management"
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Your public SSH key content."
  type        = string
  # default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+AbmjGEwITk5CK9y7+Rg27Fokgj9QEjgc9wST6MA3s personal"
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKpPU2G9rSF8Q6waH62IJexDCQ6lY+8ZyVufGE3xMDGw actions-deploy"
}
