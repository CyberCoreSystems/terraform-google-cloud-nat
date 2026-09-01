output "router_id" {
  description = "Fully-qualified Cloud Router ID."
  value       = google_compute_router.this.id
}

output "router_name" {
  description = "Cloud Router name."
  value       = google_compute_router.this.name
}

output "router_self_link" {
  description = "Self link of the Cloud Router."
  value       = google_compute_router.this.self_link
}

output "nat_id" {
  description = "Fully-qualified Cloud NAT ID."
  value       = google_compute_router_nat.this.id
}

output "nat_name" {
  description = "Cloud NAT gateway name."
  value       = google_compute_router_nat.this.name
}

output "region" {
  description = "Region the router and NAT run in."
  value       = google_compute_router.this.region
}
