provider "multipass" {}

resource "multipass_instance" "build" {
  cpus = 4
  name = "setup-ubuntu"
}

terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "~> 1.4"
    }
  }
}
