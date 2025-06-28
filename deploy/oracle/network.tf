resource "oci_core_vcn" "my_vpc" {
  compartment_id = var.compartment_ocid
  display_name   = "main"
  cidr_block     = "10.0.0.0/16"
  is_ipv6enabled = false
  dns_label      = "mainvcn" # Must be unique within your tenancy
}

resource "oci_core_internet_gateway" "my_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vpc.id
  display_name   = "main-igw"
  is_enabled     = true
}

resource "oci_core_route_table" "my_public_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vpc.id
  display_name   = "main-public-rt"

  # Default route to the Internet Gateway
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.my_igw.id
  }
}

resource "oci_core_security_list" "my_public_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.my_vpc.id
  display_name   = "main-public-sl"

  # Egress Rules (Allow all outbound traffic)
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  # Ingress Rules
  ingress_security_rules {
    # SSH (TCP 22)
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    # HTTP (TCP 80)
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    # HTTPS (TCP 443)
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    # Custom Minecraft
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    tcp_options {
      min = 49732
      max = 49732
    }
  }

  ingress_security_rules {
    # HTTPS (UDP 443) - For QUIC or specific UDP services
    protocol    = "17" # UDP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    udp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    # ICMP (Ping)
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    icmp_options {
      type = 3 # Destination Unreachable (common for connectivity checks)
      code = 4 # Fragmentation needed
    }
  }
  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    icmp_options {
      type = 8 # Echo Request (ping)
    }
  }
}

resource "oci_core_subnet" "my_public_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.my_vpc.id
  display_name               = "main-public-subnet"
  cidr_block                 = "10.0.0.0/24"
  prohibit_public_ip_on_vnic = false # Allows instances in this subnet to get public IPs
  route_table_id             = oci_core_route_table.my_public_route_table.id
  security_list_ids          = [oci_core_security_list.my_public_security_list.id]
  dns_label                  = "mainsub" # Must be unique within the VCN
}
