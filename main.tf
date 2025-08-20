resource "oci_core_instance" "main" {
  display_name        = "main"
  availability_domain = "zHim:AP-SEOUL-1-AD-1"
  fault_domain        = "FAULT-DOMAIN-1"
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }
  source_details {
    source_type = "bootVolume"
    source_id   = var.main_boot_volume_ocid
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    private_ip       = local.main_ip
    assign_public_ip = false
    nsg_ids          = [oci_core_network_security_group.main.id]
  }
  metadata = {
    "ssh_authorized_keys" : var.ssh_public_key,
  }
  preserve_boot_volume = true
}

resource "oci_core_network_security_group" "main" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "main"
}

resource "oci_core_network_security_group_security_rule" "main_ssh" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "INGRESS"
  protocol                  = "6" // TCP

  source      = local.cidr_block
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 22
      min = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "main_80" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "INGRESS"
  protocol                  = "6" // TCP

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "main_443" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "INGRESS"
  protocol                  = "6" // TCP

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "main_3000" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "INGRESS"
  protocol                  = "6" // TCP

  source      = local.cidr_block
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 3000
      min = 3000
    }
  }
}

resource "oci_core_network_security_group_security_rule" "main_6443" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "INGRESS"
  protocol                  = "6" // TCP

  source      = local.cidr_block
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 6443
      min = 6443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "main_10250" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "INGRESS"
  protocol                  = "6" // TCP

  source      = local.cidr_block
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 10250
      min = 10250
    }
  }
}
