resource "google_compute_instance" "server" {
  count = length(var.zones)

  name         = "${var.name}-${element(var.zones, count.index)}"
  machine_type = var.machine_type
  zone         = "${var.region}-${element(var.zones, count.index)}"

  boot_disk {
    initialize_params {
      size  = 30
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts"
    }
  }
  attached_disk {
    source = google_compute_disk.disk[count.index].self_link
  }
  network_interface {
    subnetwork    = google_compute_subnetwork.main.name
    access_config {

    }
  }

  metadata = {
    managed-by = "terraform"
    ssh-keys   = "${var.remote_user}:${file(var.public_key)}"
  }
}

resource google_compute_disk "disk" {
  name = "${var.name}-disk-${count.index}"
  count = length(var.zones)
  zone = "${var.region}-${element(var.zones, count.index)}"

  size = 100
}

data "template_file" "ansible-install" {
  template = file("ansible-install.sh")
  depends_on = [google_compute_instance.server]
  vars = {
    # Created servers external IPs and appropriate AZs
    ece-server0 = google_compute_instance.server[0].network_interface[0].access_config[0].nat_ip
    ece-server0-zone = google_compute_instance.server[0].zone
    ece-server1 = google_compute_instance.server[1].network_interface[0].access_config[0].nat_ip
    ece-server1-zone = google_compute_instance.server[1].zone
    ece-server2 = google_compute_instance.server[2].network_interface[0].access_config[0].nat_ip
    ece-server2-zone = google_compute_instance.server[2].zone

    # Keys to server
    key = var.private_key

    # Server Device Name
    device = "sdb"

    # User to login
    user = var.remote_user

    # Ece version to install
    ece-version = var.ece_version
  }
}