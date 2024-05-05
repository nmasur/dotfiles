variable "ec2_size" {
  type        = string
  description = "Size of instance to launch"
  default     = "t3a.small" # 2 GB RAM ($14/mo)
}

variable "images_bucket" {
  description = "Name of the bucket in which to store the NixOS VM images."
  type        = string
}
