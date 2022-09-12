resource "oci_core_instance" "vpn" {
  display_name        = "vpn"
  availability_domain = "zHim:AP-SEOUL-1-AD-1"
  fault_domain        = "FAULT-DOMAIN-1"
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.E2.1.Micro"
  source_details {
    source_type = "bootVolume"
    source_id   = var.vpn_boot_volume_ocid
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    nsg_ids          = [oci_core_network_security_group.vpn.id]
    assign_public_ip = false
    private_ip       = local.vpn_ip
  }
  metadata = {
    "ssh_authorized_keys" : var.ssh_public_key,
  }
  preserve_boot_volume = true
}

data "oci_core_private_ips" "vpn" {
  ip_address = oci_core_instance.vpn.private_ip
  subnet_id  = oci_core_subnet.public.id
}

resource "oci_core_public_ip" "vpn" {
  compartment_id = var.compartment_id
  display_name   = "vpn"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.vpn.private_ips[0]["id"]
}

resource "oci_core_network_security_group" "vpn" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "vpn"
}

resource "oci_core_network_security_group_security_rule" "vpn_tcp" {
  network_security_group_id = oci_core_network_security_group.vpn.id
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

resource "oci_core_network_security_group_security_rule" "vpn_udp" {
  network_security_group_id = oci_core_network_security_group.vpn.id
  direction                 = "INGRESS"
  protocol                  = "17" // UDP

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  udp_options {
    destination_port_range {
      max = 51820
      min = 51820
    }
  }
}
