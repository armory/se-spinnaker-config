# Specify the GCP Provider
provider "google-beta" {
	project = var.project_id
	region  = var.region
	version = "~> 3.10"
	alias   = "gb3"
}

resource "google_compute_network" "vpc-agent-demo" {
  count= 5
  name = "agent-demo-vpc-network-${count.index}"
  project = var.project_id
}

# Create a GKE cluster
resource "google_container_cluster" "cluster-agent-demo" {
  depends_on = [
    google_compute_network.vpc-agent-demo,
  ]
  provider           = google-beta.gb3
  name               = "agent-demo-${count.index}"
  count              = 50
  location           = count.index < 25 ? "us-west2" : "us-east1"
  initial_node_count = 1
  network            = "agent-demo-vpc-network-${floor(count.index / 20)}"

  master_auth {
    username = ""
    password = ""
  }

  # Enable Workload Identity
  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }

  node_locations = count.index < 25 ? [ "us-west2-a" ] : [ "us-east1-b"]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "node-pool-${count.index}"
  count      = 50
  cluster    = google_container_cluster.cluster-agent-demo[count.index].name
  location    = google_container_cluster.cluster-agent-demo[count.index].location
  node_count = 1
  node_config {
    preemptible  = true
    machine_type = var.machine_type
    metadata = {
      disable-legacy-endpoints = "true"
    }
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}


resource "null_resource" "get-credentials" {
  count = 50
  provisioner "local-exec" {
    command = <<-EOT
      gcloud container clusters get-credentials agent-demo-${count.index} --project cloud-armory --region ${google_container_cluster.cluster-agent-demo[count.index].location}
    EOT
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG="../kubecfgs/kubecfg-demo-${count.index}.yaml"
    }
  }
  depends_on = [
    google_container_cluster.cluster-agent-demo,
  ]
}