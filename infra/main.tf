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
  name     = "www.winsnes.io"
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

################################################################################
# Outputs
################################################################################
output "bucket_link" {
  value = "${google_storage_bucket.static-store.self_link}"
}

################################################################################
# Backend Config
################################################################################
terraform {
  backend "local" {}
}
