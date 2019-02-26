variable "do_token" {}
variable "ssh_fingerprint" {}

provider "digitalocean" {
  token = "${var.do_token}"
}

# create smallest droplet
resource "digitalocean_droplet" "test" {
  image    = "ubuntu-18-04-x64"
  name     = "test"
  region   = "nyc3"
  size     = "s-1vcpu-1gb"
  ssh_keys = ["${var.ssh_fingerprint}"]
}

# create an ansible inventory file
resource "null_resource" "ansible-provision" {
  depends_on = ["digitalocean_droplet.test"]

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.test.name} ansible_host=${digitalocean_droplet.test.ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3' > inventory"
  }

}

