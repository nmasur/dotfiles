terraform {
  backend "s3" {
    bucket       = "noahmasur-terraform"
    key          = "flame.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
  required_version = ">= 1.0.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "7.7.0"
    }
  }
}

provider "oci" {
  auth         = "APIKey"
  tenancy_ocid = var.compartment_ocid
  user_ocid    = "ocid1.user.oc1..aaaaaaaa6lro2eoxdajjypjysepvzcavq5yn4qyozjyebxdiaoqziribuqba"
  private_key  = var.oci_private_key
  fingerprint  = "dd:d0:da:6d:83:46:8b:b3:d9:45:2b:c7:56:ae:30:94"
  region       = "us-ashburn-1"
}

# # Get the latest Ubuntu image OCID
# # We'll filter for a recent Ubuntu LTS version (e.g., 22.04 or 24.04) and pick the latest.
# # Note: Image OCIDs are region-specific. This data source helps find the correct one.
# data "oci_core_images" "ubuntu_image" {
#   compartment_id   = var.compartment_ocid
#   operating_system = "Canonical Ubuntu"
#   # Adjust this version if you prefer a different Ubuntu LTS (e.g., "24.04")
#   operating_system_version = "24.04"
#   shape_filter             = var.instance_shape # Filter by the shape to ensure compatibility
#   sort_by                  = "TIMECREATED"
#   sort_order               = "DESC"
#   limit                    = 1 # Get only the latest
# }

resource "oci_core_image" "my_custom_image" {
  compartment_id = var.compartment_ocid
  display_name   = "noah-nixos"

  image_source_details {
    source_type = "objectStorageTuple" # Use this if specifying namespace, bucket, and object name
    # source_type  = "objectStorageUri"  # Use this if you have a pre-authenticated request URL (PAR)
    namespace_name = var.object_storage_namespace
    bucket_name    = var.object_storage_bucket_name
    object_name    = var.object_storage_object_name

    source_image_type = "QCOW2" # e.g., "QCOW2", "VMDK"

    # These properties help OCI understand how to launch instances from this image
    # Adjust based on your custom image's OS and boot mode
    launch_mode              = "PARAVIRTUALIZED" # Or "NATIVE", "EMULATED", "CUSTOM"
    operating_system         = "NixOS"           # e.g., "CentOS", "Debian", "Windows"
    operating_system_version = "25.05"           # e.g., "7", "11", "2019"
  }

  # Optional: for specific launch options if your image requires them
  # launch_options {
  #   boot_volume_type = "PARAVIRTUALIZED"
  #   firmware         = "UEFI_64" # Or "BIOS"
  #   network_type     = "PARAVIRTUALIZED"
  # }

  # Time out for image import operation. Can take a while for large images.
  timeouts {
    create = "60m" # Default is 20m, often needs to be increased
  }
}

resource "oci_core_instance" "my_compute_instance" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = var.instance_shape
  display_name        = var.instance_display_name

  source_details {
    source_type = "image"
    # # Use the OCID of the latest Ubuntu image found by the data source
    # source_id = data.oci_core_images.ubuntu_image.images[0].id
    # Use the OCID of the newly imported custom image
    source_id = oci_core_image.my_custom_image.id
    # Specify the boot volume size
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.my_public_subnet.id # Use the created subnet's ID
    display_name     = "primary_vnic"
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(var.cloud_init_script)
  }

  # Optional: For flexible shapes (e.g., VM.Standard.E4.Flex), you might need to specify OCPUs and memory
  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }
}
