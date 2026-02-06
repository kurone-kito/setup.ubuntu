# ⚙️ Auto setup for Ubuntu

Dev environment preference for the Ubuntu Linux distribution.

## Setup

```sh
./setup
```

## Installation apps

### Cryptography

- [GnuPG: The GNU Privacy Guard](https://gnupg.org/)
- pinentry-curses

### Development tools

- build-essential
- cargo
- [CMake](https://cmake.org)
- [GCC: the GNU Compiler Collection](https://gcc.gnu.org)
- make

### Download tools

- ca-certificates
- [curl](https://curl.se)
- httpie
- [GNU wget](https://www.gnu.org/software/wget/)

### Hardware

- keyboard-configuration

### Locales

- language-pack-ja

### Package manager

- apt-file
- apt-transport-https
- apt-utils
- [Homebrew](https://brew.sh/)
- software-properties-common

### SCM tools

- [Git](https://git-scm.com/)

### Text converters

- [yq](https://mikefarah.gitbook.io/yq)

### Others

- upgrade to apt packages

## Test (Run on VM)

Required some tools:

- [Multipass](https://multipass.run/)
- [Terraform](https://www.terraform.io/)

```sh
./setup -v

# ...or just launch the setup in non-Ubuntu environment.
./setup
```

Alternatively, if you run the setup outside an Ubuntu environment, it'll
automatically treat the `-v` option as specified and run the setup within a
VM environment.

### Destroy the VM

```sh
./nuke
```

## See also

- [dotfiles](https://github.com/kurone-kito/dotfiles)
- [setup.macos](https://github.com/kurone-kito/setup.macos)
- [setup.windows](https://github.com/kurone-kito/setup.windows)

## License

[MIT](./LICENSE)
