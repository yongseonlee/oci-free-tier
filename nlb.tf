resource "oci_core_public_ip" "nlb" {
  compartment_id = var.compartment_id
  display_name   = "nlb-reserved-ip"
  lifetime       = "RESERVED"

  // required to keep it assigned
  lifecycle {
    ignore_changes = [private_ip_id]
  }
}

resource "oci_network_load_balancer_network_load_balancer" "main" {
  compartment_id = var.compartment_id
  display_name   = "main-nlb"
  subnet_id      = oci_core_subnet.public.id

  is_private                     = false
  is_preserve_source_destination = false

  network_security_group_ids = [oci_core_network_security_group.nlb.id]

  reserved_ips {
    id = oci_core_public_ip.nlb.id
  }
}

resource "oci_core_network_security_group" "nlb" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main.id
  display_name   = "nlb"
}

resource "oci_core_network_security_group_security_rule" "nlb_ingress_80" {
  network_security_group_id = oci_core_network_security_group.nlb.id
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nlb_ingress_443" {
  network_security_group_id = oci_core_network_security_group.nlb.id
  direction                 = "INGRESS"
  protocol                  = "6"

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "nlb_egress" {
  network_security_group_id = oci_core_network_security_group.nlb.id
  direction                 = "EGRESS"
  protocol                  = "all"

  destination      = "0.0.0.0/0"
  destination_type = "CIDR_BLOCK"
}

resource "oci_network_load_balancer_backend_set" "main_30080" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  name                     = "main_30080_backend_set"
  policy                   = "FIVE_TUPLE"

  health_checker {
    protocol = "TCP"
    port     = 30080
  }
}

resource "oci_network_load_balancer_backend_set" "main_30443" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  name                     = "main_30443_backend_set"
  policy                   = "FIVE_TUPLE"

  health_checker {
    protocol = "TCP"
    port     = 30443
  }
}

resource "oci_network_load_balancer_backend" "main_30080" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  backend_set_name         = oci_network_load_balancer_backend_set.main_30080.name
  port                     = 30080
  target_id                = oci_core_instance.main.id
}

resource "oci_network_load_balancer_backend" "main_30443" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  backend_set_name         = oci_network_load_balancer_backend_set.main_30443.name
  port                     = 30443
  target_id                = oci_core_instance.main.id
}

resource "oci_network_load_balancer_listener" "http" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  name                     = "http_listener"
  protocol                 = "TCP"
  port                     = 80
  default_backend_set_name = oci_network_load_balancer_backend_set.main_30080.name
}

resource "oci_network_load_balancer_listener" "https" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.main.id
  name                     = "https_listener"
  protocol                 = "TCP"
  port                     = 443
  default_backend_set_name = oci_network_load_balancer_backend_set.main_30443.name
}
