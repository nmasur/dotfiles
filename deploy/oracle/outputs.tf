output "host_ip" {
  description = "The public IP address of the launched instance."
  value       = oci_core_instance.ubuntu_compute_instance.public_ip
}

output "instance_id" {
  description = "The OCID of the launched instance."
  value       = oci_core_instance.ubuntu_compute_instance.id
}

output "vpc_ocid" {
  description = "The OCID of the created VCN."
  value       = oci_core_vcn.my_vpc.id
}

output "subnet_ocid" {
  description = "The OCID of the created public subnet."
  value       = oci_core_subnet.my_public_subnet.id
}
