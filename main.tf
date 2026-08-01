provider "multipass" {}

resource "multipass_instance" "build" {
  cloudinit_file = "${path.module}/cloud-init.yml"
  cpus           = 4
  disk           = "12G"
  # The provider default (1GiB) is sized for an idle instance, not this
  # workload: a full apt-get upgrade, ~70 apt packages, a Homebrew
  # bootstrap of 34 formulae, a mise Node toolchain, and the Docker
  # engine. 4G matches cpus and gives the Homebrew bootstrap enough
  # headroom to avoid an OOM that would otherwise surface as an
  # unexplained mid-install failure.
  memory = "4G"
  name   = "setup-ubuntu"
}

terraform {
  required_providers {
    multipass = {
      source  = "larstobi/multipass"
      version = "~> 1.4"
    }
  }
}
