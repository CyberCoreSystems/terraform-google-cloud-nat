terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.0, < 8.0"
    }
  }
}

provider "google" {
  project = "iacbazaar-example-project"
  region  = "us-central1"
}

module "nat" {
  source = "../../"

  project_id = "iacbazaar-example-project"
  name       = "example"
  region     = "us-central1"
  network    = "projects/iacbazaar-example-project/global/networks/default"

  # Auto-allocated NAT IPs, NAT every subnet range, error-only logging.
}

output "nat_id" {
  value = module.nat.nat_id
}

output "router_self_link" {
  value = module.nat.router_self_link
}
