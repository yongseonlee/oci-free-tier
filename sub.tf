resource "oci_core_instance" "sub" {
  display_name        = "sub"
  availability_domain = "zHim:AP-SEOUL-1-AD-1"
  fault_domain        = "FAULT-DOMAIN-1"
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E2.1.Micro"
  source_details {
    source_type = "bootVolume"
    source_id   = var.sub_boot_volume_ocid
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.private.id
    nsg_ids          = [oci_core_network_security_group.sub.id]
    assign_public_ip = false
    private_ip       = local.sub_ip
  }
  metadata = {
    "ssh_authorized_keys" : var.ssh_public_key,
  }
  preserve_boot_volume = true
}

resource "oci_core_network_security_group" "sub" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "sub"
}

resource "oci_core_network_security_group_security_rule" "sub_ssh" {
  network_security_group_id = oci_core_network_security_group.sub.id
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

resource "oci_core_network_security_group_security_rule" "sub_80" {
  network_security_group_id = oci_core_network_security_group.sub.id
  direction                 = "INGRESS"
  protocol                  = "6" // TCP

  source      = local.cidr_block
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "sub_4000" {
  network_security_group_id = oci_core_network_security_group.sub.id
  direction                 = "INGRESS"
  protocol                  = "6" // TCP

  source      = local.cidr_block
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 4000
      min = 4000
    }
  }
}

resource "oci_core_network_security_group_security_rule" "sub_5432" {
  network_security_group_id = oci_core_network_security_group.sub.id
  direction                 = "INGRESS"
  protocol                  = "6" // TCP

  source      = local.cidr_block
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 5432
      min = 5432
    }
  }
}
