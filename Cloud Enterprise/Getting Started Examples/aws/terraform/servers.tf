data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "server" {
  key_name   = "${var.name}"
  public_key = "${file(var.public_key)}"
}

resource "aws_instance" "server" {
  count = "${length(var.zones)}"

  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  vpc_security_group_ids = [
    "${aws_security_group.administration.id}",
    "${aws_security_group.servers.id}",
    "${aws_security_group.internal.id}",
  ]

  key_name = "${aws_key_pair.server.key_name}"

  root_block_device {
    volume_size = "${var.root_device_size}"
  }

  tags {
    Name       = "${var.name}-${element(var.zones, count.index)}"
    managed-by = "terraform"
  }

  ebs_block_device {
    delete_on_termination = true
    device_name = "${var.secondary_device_name}"
    volume_type = "gp2"
    volume_size = "${var.secondary_device_size}"
  }
}

data "template_file" "ansible-install" {
  template = "${file("ansible-install.sh")}"
  depends_on = ["aws_instance.server"]
  vars = {
    # Created servers and appropriate AZs
    ece-server0 = "${aws_instance.server.0.public_dns}"
    ece-server0-zone = "${aws_instance.server.0.availability_zone}"
    ece-server1 = "${aws_instance.server.1.public_dns}"
    ece-server1-zone = "${aws_instance.server.1.availability_zone}"
    ece-server2 = "${aws_instance.server.2.public_dns}"
    ece-server2-zone = "${aws_instance.server.2.availability_zone}"

    # Keys to server
    key = "${var.private_key}"

    # Server Device Name
    device = "${var.secondary_device_name}"

    # User to login
    user = "${var.remote_user}"

    # Ece version to install
    ece-version = "${var.ece-version}"
  }
}