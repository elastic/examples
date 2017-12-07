resource "google_compute_instance" "server" {
  count = "${length(var.zones)}"

  name         = "${var.name}-${element(var.zones, count.index)}"
  machine_type = "${var.machine_type}"
  zone         = "${var.region}-${element(var.zones, count.index)}"

  boot_disk {
    initialize_params {
      size  = 100
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts"
    }
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.main.name}"
    access_config = {}
  }

  metadata {
    managed-by = "terraform"
    ssh-keys   = "${var.remote_user}:${file(var.public_key)}"
  }

  metadata_startup_script = "${file(var.user_data)}"
}
