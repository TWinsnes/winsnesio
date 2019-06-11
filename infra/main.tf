################################################################################
# Locals
################################################################################

locals {
  region = "us-central1"
}

################################################################################
# Variables
################################################################################

variable "service_account" {
  type = "string"
}

variable "google_project" {
  type = "string"
}

variable "root_domain" {
  type = "string"
}

variable "sub_domain" {
  type = "string"
}

################################################################################
# Providers
################################################################################
provider "google" {
  credentials = "${file(".creds/gcp-sa-key.json")}"
  project     = "${var.google_project}"
  region      = "${local.region}"
}

################################################################################
# Resources
################################################################################
resource "google_storage_bucket" "static-store" {
  name     = "${length(var.sub_domain) == 0 ? var.root_domain : join(".",list(var.sub_domain, var.root_domain))}"
  location = "US"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

data "google_project" "project" {}

resource "google_storage_bucket_acl" "static-store-default" {
  bucket = "${google_storage_bucket.static-store.name}"

  role_entity = [
    "OWNER:project-owners-${data.google_project.project.number}",
    "OWNER:user-${var.service_account}",
    "READER:allUsers",
  ]
}

resource "google_compute_global_forwarding_rule" "ipv4-http" {
  name       = "winsnesio-http-global-forwarding-rule-ipv4"
  target     = "${google_compute_target_http_proxy.default.self_link}"
  port_range = "80"
}

resource "google_compute_global_forwarding_rule" "ipv6-http" {
  name = "winsnesio-http-global-forwarding-rule-ipv6"
  target = "${google_compute_target_http_proxy.default.self_link}"
  port_range = "80"
  ip_version = "IPV6"
}

resource "google_compute_target_http_proxy" "default" {
  name        = "winsnesio-http-proxy"
  description = "Http proxy for winsnes.io"
  url_map     = "${google_compute_url_map.default.self_link}"
}

resource "google_compute_url_map" "default" {
  name            = "winsnesio-url-map"
  description     = "Url map for winsnes.io blog"
  default_service = "${google_compute_backend_bucket.static_storage.self_link}"

  host_rule {
    hosts        = ["${var.root_domain}"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_bucket.static_storage.self_link}"

    path_rule {
      paths   = ["/*"]
      service = "${google_compute_backend_bucket.static_storage.self_link}"
    }
  }
}

resource "google_compute_backend_bucket" "static_storage" {
  name = "storage-backend-bucket"
  bucket_name = "${google_storage_bucket.static-store.name}"
}

################################################################################
# Outputs
################################################################################
output "bucket_link" {
  value = "${google_storage_bucket.static-store.self_link}"
}

output "lb_link" {
  value = "${google_compute_global_forwarding_rule.ipv4-http.ip_address}"
}

output "lb_link_ipv6" {
  value = "${google_compute_global_forwarding_rule.ipv6-http.ip_address}"
}

################################################################################
# Backend Config
################################################################################
terraform {
  backend "local" {}
}
