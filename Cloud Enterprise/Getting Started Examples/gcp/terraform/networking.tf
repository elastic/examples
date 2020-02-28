resource "google_compute_network" "main" {
  name                    = var.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = var.name
  ip_cidr_range = var.cidr
  network       = google_compute_network.main.self_link
  region        = var.region
}

resource "google_compute_firewall" "administration" {
  name    = "${var.name}-allow-administration"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"

    ports = [
      22,
      12443,
      12343
    ]
  }

  source_ranges = [
    var.trusted_network
  ]
}

resource "google_compute_firewall" "servers-out" {
  name    = "${var.name}-servers-out"
  network = google_compute_network.main.name
  direction = "EGRESS"
  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "servers-in" {
  name    = "${var.name}-servers-in"
  network = google_compute_network.main.name
  allow {
    protocol = "all"
  }

  source_ranges = [
    var.cidr,

    # Opted to be more explicit about server instances here, since otherwise it fails on destroy operation
    format("%s/32",google_compute_instance.server[0].network_interface[0].access_config[0].nat_ip),
    format("%s/32",google_compute_instance.server[1].network_interface[0].access_config[0].nat_ip),
    format("%s/32",google_compute_instance.server[2].network_interface[0].access_config[0].nat_ip)
  ]
}
