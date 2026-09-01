variable "project_id" {
  description = "GCP project ID that hosts the router and NAT."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "name" {
  description = "Base name; the router becomes <name>-router and the NAT gateway <name>-nat."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([-a-z0-9]{0,55}[a-z0-9])?$", var.name))
    error_message = "name must be 1-57 chars, start with a lowercase letter, and contain only lowercase letters, digits and hyphens."
  }
}

variable "region" {
  description = "Region for the Cloud Router and Cloud NAT (e.g. us-central1)."
  type        = string

  validation {
    condition     = can(regex("^[a-z]+-[a-z0-9]+$", var.region))
    error_message = "region must be a GCP region like us-central1."
  }
}

variable "network" {
  description = "VPC network self link or name the router attaches to."
  type        = string

  validation {
    condition     = length(var.network) > 0
    error_message = "network must be a non-empty network name or self link."
  }
}

variable "nat_ip_allocate_option" {
  description = "How NAT IPs are allocated: AUTO_ONLY (Google manages addresses) or MANUAL_ONLY (you supply nat_ips)."
  type        = string
  default     = "AUTO_ONLY"

  validation {
    condition     = contains(["AUTO_ONLY", "MANUAL_ONLY"], var.nat_ip_allocate_option)
    error_message = "nat_ip_allocate_option must be AUTO_ONLY or MANUAL_ONLY."
  }
}

variable "nat_ips" {
  description = "Self links of reserved external IPs to use when nat_ip_allocate_option is MANUAL_ONLY."
  type        = list(string)
  default     = []

  validation {
    condition     = var.nat_ip_allocate_option != "MANUAL_ONLY" || length(var.nat_ips) > 0
    error_message = "nat_ips must be non-empty when nat_ip_allocate_option is MANUAL_ONLY."
  }
}

variable "source_subnetwork_ip_ranges_to_nat" {
  description = "Which subnet ranges are NATed: ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES, or LIST_OF_SUBNETWORKS (then set subnetworks)."
  type        = string
  default     = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  validation {
    condition = contains([
      "ALL_SUBNETWORKS_ALL_IP_RANGES",
      "ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES",
      "LIST_OF_SUBNETWORKS",
    ], var.source_subnetwork_ip_ranges_to_nat)
    error_message = "source_subnetwork_ip_ranges_to_nat must be ALL_SUBNETWORKS_ALL_IP_RANGES, ALL_SUBNETWORKS_ALL_PRIMARY_IP_RANGES or LIST_OF_SUBNETWORKS."
  }
}

variable "subnetworks" {
  description = "Per-subnetwork NAT config, used only when source_subnetwork_ip_ranges_to_nat is LIST_OF_SUBNETWORKS."
  type = list(object({
    name                     = string
    source_ip_ranges_to_nat  = list(string)
    secondary_ip_range_names = optional(list(string))
  }))
  default = []

  validation {
    condition     = var.source_subnetwork_ip_ranges_to_nat != "LIST_OF_SUBNETWORKS" || length(var.subnetworks) > 0
    error_message = "subnetworks must be non-empty when source_subnetwork_ip_ranges_to_nat is LIST_OF_SUBNETWORKS."
  }
}

variable "min_ports_per_vm" {
  description = "Minimum number of source NAT ports allocated per VM."
  type        = number
  default     = 64

  validation {
    condition     = var.min_ports_per_vm >= 2 && var.min_ports_per_vm <= 65536
    error_message = "min_ports_per_vm must be between 2 and 65536."
  }
}

variable "enable_endpoint_independent_mapping" {
  description = "Enable endpoint-independent mapping (EIM). Usually off for better port utilization."
  type        = bool
  default     = false
}

variable "udp_idle_timeout_sec" {
  description = "Timeout (seconds) for UDP connections."
  type        = number
  default     = 30
}

variable "icmp_idle_timeout_sec" {
  description = "Timeout (seconds) for ICMP connections."
  type        = number
  default     = 30
}

variable "tcp_established_idle_timeout_sec" {
  description = "Timeout (seconds) for established TCP connections."
  type        = number
  default     = 1200
}

variable "tcp_transitory_idle_timeout_sec" {
  description = "Timeout (seconds) for transitory TCP connections."
  type        = number
  default     = 30
}

variable "enable_logging" {
  description = "Enable Cloud NAT logging to Cloud Logging."
  type        = bool
  default     = true
}

variable "log_filter" {
  description = "NAT log filter: ERRORS_ONLY, TRANSLATIONS_ONLY or ALL."
  type        = string
  default     = "ERRORS_ONLY"

  validation {
    condition     = contains(["ERRORS_ONLY", "TRANSLATIONS_ONLY", "ALL"], var.log_filter)
    error_message = "log_filter must be ERRORS_ONLY, TRANSLATIONS_ONLY or ALL."
  }
}

variable "router_bgp_asn" {
  description = "Private ASN (64512-65534 or 4200000000-4294967294) to enable BGP on the router. Null = no BGP (Cloud NAT does not require it)."
  type        = number
  default     = null

  validation {
    condition     = var.router_bgp_asn == null ? true : ((var.router_bgp_asn >= 64512 && var.router_bgp_asn <= 65534) || (var.router_bgp_asn >= 4200000000 && var.router_bgp_asn <= 4294967294))
    error_message = "router_bgp_asn must be in a private ASN range (64512-65534 or 4200000000-4294967294)."
  }
}
