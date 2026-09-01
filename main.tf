# Cloud NAT for a region: a Cloud Router plus a Cloud NAT gateway so private
# instances (no external IPs) get outbound internet access. Auto-allocated NAT
# IPs and NATs all subnet ranges by default, with logging on. Works with
# Terraform and OpenTofu.

resource "google_compute_router" "this" {
  project = var.project_id
  name    = "${var.name}-router"
  region  = var.region
  network = var.network

  # Optional BGP — only emitted when an ASN is supplied (Cloud NAT itself does
  # not require BGP, but a shared router used for Cloud VPN/Interconnect does).
  dynamic "bgp" {
    for_each = var.router_bgp_asn == null ? [] : [1]
    content {
      asn = var.router_bgp_asn
    }
  }
}

resource "google_compute_router_nat" "this" {
  project = var.project_id
  name    = "${var.name}-nat"
  router  = google_compute_router.this.name
  region  = var.region

  nat_ip_allocate_option = var.nat_ip_allocate_option
  nat_ips                = var.nat_ip_allocate_option == "MANUAL_ONLY" ? var.nat_ips : null

  source_subnetwork_ip_ranges_to_nat = var.source_subnetwork_ip_ranges_to_nat

  min_ports_per_vm                    = var.min_ports_per_vm
  enable_endpoint_independent_mapping = var.enable_endpoint_independent_mapping

  udp_idle_timeout_sec             = var.udp_idle_timeout_sec
  icmp_idle_timeout_sec            = var.icmp_idle_timeout_sec
  tcp_established_idle_timeout_sec = var.tcp_established_idle_timeout_sec
  tcp_transitory_idle_timeout_sec  = var.tcp_transitory_idle_timeout_sec

  # Per-subnetwork NAT (only when source ranges are explicitly listed).
  dynamic "subnetwork" {
    for_each = var.source_subnetwork_ip_ranges_to_nat == "LIST_OF_SUBNETWORKS" ? var.subnetworks : []
    content {
      name                     = subnetwork.value.name
      source_ip_ranges_to_nat  = subnetwork.value.source_ip_ranges_to_nat
      secondary_ip_range_names = subnetwork.value.secondary_ip_range_names
    }
  }

  log_config {
    enable = var.enable_logging
    filter = var.log_filter
  }
}
