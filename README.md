# ⚙️ Auto setup for Ubuntu

Dev environment preference for the Ubuntu Linux distribution.

## Setup

```sh
./setup
```

## Installation apps

### Archive tools

- bzip2
- [p7zip](https://sourceforge.net/projects/p7zip/)
- unzip
- xz-utils
- zip

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

### Files management

- [bat](https://github.com/sharkdp/bat)
- eza
- fd
- [fzf](https://github.com/junegunn/fzf)
- [rename](http://plasmasturm.org/code/rename/)
- zoxide

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

- [ghq](https://github.com/x-motemen/ghq)
- [GitHub CLI](https://cli.github.com/)
- [Gist](http://defunkt.io/gist/)
- [Git](https://git-scm.com/)
- [git-delta: A viewer for git and diff output](https://github.com/dandavison/delta)
- [Git Large File Storage](https://git-lfs.github.com/)
- [gti](https://r-wos.org/hacks/gti)
- [Jujutsu](https://jj-vcs.dev/)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [Apache Subversion](https://subversion.apache.org/)

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
