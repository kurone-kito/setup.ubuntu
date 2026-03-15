provider "multipass" {}

resource "multipass_instance" "build" {
  cloudinit_file = "${path.module}/cloud-init.yml"
  cpus           = 4
  disk           = "12G"
  name           = "setup-ubuntu"
}

terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "~> 1.4"
    }
  }
}
