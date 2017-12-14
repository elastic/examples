resource "google_compute_network" "main" {
  name                    = "${var.name}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "${var.name}"
  ip_cidr_range = "${var.cidr}"
  network       = "${google_compute_network.main.self_link}"
  region        = "${var.region}"
}

resource "google_compute_firewall" "administration" {
  name    = "${var.name}-allow-administration"
  network = "${google_compute_network.main.name}"

  allow {
    protocol = "tcp"

    ports = [
      22,
      12443,
    ]
  }

  source_ranges = [
    "${var.trusted_network}",
  ]
}

resource "google_compute_firewall" "servers" {
  name    = "${var.name}-allow-servers"
  network = "${google_compute_network.main.name}"

  allow {
    protocol = "tcp"

    ports = [
      9243,
      9343,
    ]
  }

  source_ranges = [
    "0.0.0.0/0",
  ]
}

resource "google_compute_firewall" "internal" {
  name    = "${var.name}-allow-internal"
  network = "${google_compute_network.main.name}"

  allow {
    protocol = "all"
  }

  source_ranges = [
    "${var.cidr}",
  ]
}
