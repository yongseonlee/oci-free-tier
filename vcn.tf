resource "oci_core_vcn" "main" {
  display_name   = "main"
  compartment_id = var.compartment_id
  cidr_blocks    = [local.cidr_block]
}

resource "oci_core_security_list" "main" {
  display_name   = "main"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "private" {
  display_name               = "private"
  cidr_block                 = local.private_subnet_cidr_block
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main.id
  prohibit_public_ip_on_vnic = true
  security_list_ids          = [oci_core_security_list.main.id]
}

resource "oci_core_subnet" "public" {
  display_name      = "public"
  cidr_block        = local.public_subnet_cidr_block
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.main.id
  security_list_ids = [oci_core_security_list.main.id]
}

resource "oci_core_internet_gateway" "main" {
  display_name   = "main"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
}

resource "oci_core_public_ip" "main" {
  compartment_id = var.compartment_id
  display_name   = "main-nat"
  lifetime       = "RESERVED"
}

resource "oci_core_nat_gateway" "main" {
  display_name   = "main"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  public_ip_id   = oci_core_public_ip.main.id
}

resource "oci_core_route_table" "public" {
  display_name   = "public"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id

  route_rules {
    network_entity_id = oci_core_internet_gateway.main.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table" "private" {
  display_name   = "private"
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id

  route_rules {
    network_entity_id = oci_core_nat_gateway.main.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table_attachment" "public" {
  subnet_id      = oci_core_subnet.public.id
  route_table_id = oci_core_route_table.public.id
}

resource "oci_core_route_table_attachment" "private" {
  subnet_id      = oci_core_subnet.private.id
  route_table_id = oci_core_route_table.private.id
}
