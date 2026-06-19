# ⚙️ Auto setup for Ubuntu

[日本語](./README.ja.md)

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

### Benchmark tools

- [htop](https://htop.dev)
- hyfetch
- hyperfine

### Binary converters

- [AtomicParsley](http://atomicparsley.sourceforge.net/)
- [FFmpeg](https://www.ffmpeg.org/)
- [ImageMagick](https://imagemagick.org/index.php)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)

#### Configuration tools

- [chezmoi](https://www.chezmoi.io/)

### Cryptography

- [GnuPG: The GNU Privacy Guard](https://gnupg.org/)
- pinentry-curses

### Database

- [SQLite](https://www.sqlite.org/)
- [Taskwarrior](https://taskwarrior.org/)

### Development tools

- build-essential
- cargo
- [CMake](https://cmake.org)
- [GCC: the GNU Compiler Collection](https://gcc.gnu.org)
- make
- mise
- python3

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

#### Generative AI

- [Ollama](https://ollama.com/)

### Hardware

- keyboard-configuration

### Jokes

- [Nyancat CLI](http://nyancat.dakko.us/)
- [sl](https://github.com/mtoyoda/sl)

### Locales

- language-pack-ja

### Package manager

- apt-file
- apt-transport-https
- apt-utils
- [Homebrew](https://brew.sh/)
- software-properties-common
- vrc-get

### Remote tools

- [awscli](https://aws.amazon.com/cli/)
- [mkcert](https://mkcert.dev/)
- mosh
- OpenSSH Server & Client
- OpenSSL
- [OpenVPN](https://openvpn.net/)
- [rsync](https://rsync.samba.org/)

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
- [lazyjj](https://github.com/Cretezy/lazyjj)
- [Apache Subversion](https://subversion.apache.org/)

### Shell utilities

- bash-completion
- [Microsoft PowerShell](https://microsoft.com/PowerShell)
- rebound
- [shellcheck](https://www.shellcheck.net)
- sudo-rs
- [The Fuck](https://github.com/nvbn/thefuck)
- yank
- zsh
- zsh-theme-powerlevel9k

### Text browsing tools

- links2
- [mdp](https://github.com/visit1985/mdp)
- tealdeer
- w3m

### Text converters

- [cloc](https://github.com/AlDanial/cloc)
- [groff](https://www.gnu.org/software/groff/)
- [jc](https://kellyjonbrazil.github.io/jc/)
- [jq](https://stedolan.github.io/jq/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [yq](https://mikefarah.gitbook.io/yq)

### Texts editors

- [GNU Nano](https://www.nano-editor.org)
- [Neovim](https://neovim.io/)
- [Vim](https://www.vim.org/)

### TUI

- [byobu](https://www.byobu.org/)
- [tmux](https://github.com/tmux/tmux)
- [zellij](https://zellij.dev)

#### Virtualizations

- Docker community edition

### Others

- upgrade to apt packages

## Desktop (optional)

The default `./setup` installs a CLI-only environment. An **opt-in** graphical
layer (XFCE over RDP, plus Sunshine for GPU streaming on bare-metal) can be
added for GUI workloads such as the Unity Editor over a remote desktop:

```sh
./setup --desktop            # install the desktop layer (real Ubuntu host)
./setup --desktop --dry-run  # print the plan only; install nothing
```

The default boot stays headless (no display manager); a graphical session
starts only on connect. See [docs/desktop.md](docs/desktop.md) for the client
matrix, the WSL2 path, security notes, and the chezmoi handoff.

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
