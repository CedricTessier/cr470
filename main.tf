terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.59.0"
    }
  }
}

variable "gcp_project_id" {
    type = string
    description = "Google Cloud project Id"
}

variable "docker_image" {
    type = string
    description = "Web server docker image"
}

provider "google" {
  project     = var.gcp_project_id
  region      = "us-central1"
}

resource "google_cloud_run_v2_service" "app" {
  name     = "web-app"
  location = "us-central1"
  template {
    containers {
      image = var.docker_image
      ports {
          container_port = 80
        }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_v2_service.app.location
  project  = google_cloud_run_v2_service.app.project
  service  = google_cloud_run_v2_service.app.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
