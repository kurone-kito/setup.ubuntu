# ⚙️ Auto setup for Ubuntu

[日本語](./README.ja.md)

Dev environment preference for the Ubuntu Linux distribution.

## Setup

```sh
./setup
```

## Installation apps

|  note   | description                                                                                                                 |
| :-----: | :-------------------------------------------------------------------------------------------------------------------------- |
| **`!`** | **DEPENDENCIES**: Removing the apps may cause this setup to stop working correctly.                                         |
| **`.`** | **[dotfiles](https://github.com/kurone-kito/dotfiles) dependencies**: They're required for the dotfiles to work correctly.  |
|   (B)   | The apps install via the [Homebrew](https://brew.sh/) package manager, so you can manage them with Homebrew.                |
|   (M)   | The apps install via the [mise-en-place](https://mise.jdx.dev/) package manager, so you can manage them with Mise-en-place. |

### Archive tools

- [bzip2](https://github.com/libarchive/bzip2)
- [p7zip](https://github.com/ip7z/7zip)
- [unzip](https://manpages.ubuntu.com/manpages/man1/unzip.1.html)
- [xz-utils](https://tukaani.org/xz/)
- [zip](https://manpages.ubuntu.com/manpages/man1/zip.1.html)

### Benchmark tools

- [htop](https://htop.dev)
- [hyfetch](https://github.com/hykilpikonna/hyfetch)
- [hyperfine](https://github.com/sharkdp/hyperfine)

### Binary converters

- [AtomicParsley](http://atomicparsley.sourceforge.net/)
- [FFmpeg](https://www.ffmpeg.org/)
- [ImageMagick](https://imagemagick.org/index.php)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)

### Clipboard tools

- [xsel](http://www.kfish.org/software/xsel/)
- [yank](https://github.com/mptre/yank)

### Configuration tools

- **`.`** (M) [Bitwarden CLI](https://bitwarden.com/)
- **`.`** (B) [chezmoi](https://www.chezmoi.io/)

### Cryptography

- **`!`** [GnuPG: The GNU Privacy Guard](https://gnupg.org/)
- **`.`** [pinentry-curses](https://manpages.ubuntu.com/manpages/man1/pinentry-curses.1.html)

### Database

- [SQLite](https://www.sqlite.org/)
- (B) [Taskwarrior](https://taskwarrior.org/)

### Development tools

- (B) [ast-grep](https://ast-grep.github.io/)
- **`!`** build-essential
- **`!`** [cargo](https://doc.rust-lang.org/stable/cargo/)
- (B) **`!`** [Cargo Binary Install](https://github.com/cargo-bins/cargo-binstall)
- [CMake](https://cmake.org)
- (B) [Deno](https://deno.com/)
- (B) [direnv](https://direnv.net/)
- [GCC: the GNU Compiler Collection](https://gcc.gnu.org)
- [make](https://www.gnu.org/software/make/)
- **`.`** (M) [Node.js](https://nodejs.org/)
- (B) [python3](https://www.python.org/)
- (B) [tree-sitter](https://tree-sitter.github.io/tree-sitter/)

### Download tools

- **`!`** [ca-certificates](https://curl.se/docs/caextract.html)
- **`!`** [curl](https://curl.se)
- [GNU wget](https://www.gnu.org/software/wget/)

### Files management

- [bat](https://github.com/sharkdp/bat)
- [eza](https://github.com/eza-community/eza)
- (B) [fd](https://github.com/sharkdp/fd)
- [rename](http://plasmasturm.org/code/rename/)
- [trash-cli](https://github.com/andreafrancia/trash-cli)
- (B) [watchexec](https://github.com/watchexec/watchexec)
- (B) [yazi](https://yazi-rs.github.io/)
- **`.`** [zoxide](https://crates.io/crates/zoxide)

### Game development

- [Unity CLI](https://docs.unity.com/en-us/unity-cli)

#### Generative AI

- (B) [Ollama](https://ollama.com/)

### Hardware

- **`!`** keyboard-configuration

### Jokes

- [Nyancat CLI](http://nyancat.dakko.us/)
- [sl](https://github.com/mtoyoda/sl)

### Locales

- **`!`** language-pack-ja

### Package manager

- [apt-file](https://manpages.ubuntu.com/manpages/man1/apt-file.1.html)
- [apt-transport-https](https://manpages.ubuntu.com/manpages/man1/apt-transport-https.1.html)
- apt-utils
- **`!`** [Homebrew](https://brew.sh/)
- **`!`** (B) [mise-en-place](https://mise.jdx.dev/)
- **`!`** software-properties-common
- **`.`** (B) [vrc-get](https://github.com/vrc-get/vrc-get)

### Remote tools

- **`.`** (B) [awscli](https://aws.amazon.com/cli/)
- [httpie](https://httpie.io/)
- [LazySSH](https://github.com/Adembc/lazyssh)
- [mosh](https://mosh.org/)
- [ngrok](https://ngrok.com/)
- **`.`** [OpenSSH Server & Client](https://www.openssh.org/)
- [OpenSSL](https://www.openssl.org/)
- [OpenVPN](https://openvpn.net/)
- [rsync](https://rsync.samba.org/)

### SCM tools

- **`.`** (B) [ghq](https://github.com/x-motemen/ghq)
- **`.`** [GitHub CLI](https://cli.github.com/)
- **`.`** [Git](https://git-scm.com/)
- **`.`** [Git Large File Storage](https://git-lfs.github.com/)
- (B) [gti](https://r-wos.org/hacks/gti)
- (B) [Jujutsu](https://jj-vcs.dev/)
- (B) [lazygit](https://github.com/jesseduffield/lazygit)
- (B) [lazyjj](https://github.com/Cretezy/lazyjj)
- [Apache Subversion](https://subversion.apache.org/)
- (B) [Worktrunk](https://worktrunk.dev/)

### Shell utilities

- [bash-completion](https://github.com/scop/bash-completion)
- **`.`** (B) [Microsoft PowerShell](https://microsoft.com/PowerShell)
- [shellcheck](https://www.shellcheck.net)
- **`.`** (B) [Starship](https://starship.rs/)
- [sudo-rs](https://github.com/trifectatechfoundation/sudo-rs)
- [The Fuck](https://github.com/nvbn/thefuck)
- **`.`** [zsh](https://www.zsh.org/)

### Text browsing tools

- (B) [glow](https://github.com/charmbracelet/glow)
- [links2](https://links.twibright.com/)
- [mdp](https://github.com/visit1985/mdp)
- [w3m](https://w3m.sourceforge.net/)

### Text converters

- [cloc](https://github.com/AlDanial/cloc)
- [dprint](https://dprint.dev/)
- [groff](https://www.gnu.org/software/groff/)
- [jc](https://kellyjonbrazil.github.io/jc/)
- (B) [pkl](https://pkl-lang.org/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- **`!`** [yq](https://github.com/kislyuk/yq)

### Texts editors

- (B) [Microsoft Edit](https://github.com/microsoft/edit)
- **`.`** (B) [Neovim](https://neovim.io/)
- **`.`** [Vim](https://www.vim.org/)

### TUI

- **`.`** [tmux](https://github.com/tmux/tmux)
- **`.`** (B) [zellij](https://zellij.dev)

#### Virtualizations

- (B) [act](https://github.com/nektos/act)
- (B) [dive](https://github.com/wagoodman/dive)
- (B) [k3sup](https://github.com/alexellis/k3sup)
- [Docker community edition](https://www.docker.com/)
- (B) [lazydocker](https://github.com/jesseduffield/lazydocker)

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

## Unity (optional)

The Unity CLI installs in the default path. The Unity Editors themselves are
**opt-in** and install unlicensed — activation is a separate, operator-side
step this repository does not hold credentials for:

```sh
./setup --unity            # install the pinned Unity Editors (real Ubuntu host)
./setup --unity --dry-run  # print the plan only; install nothing
```

`--dry-run` needs the Unity CLI already on `PATH` to resolve live version
data; any prior `./setup` run on a real Ubuntu host already has it (a
VM/non-Ubuntu-only host never installs it on its own `PATH`). See
[docs/unity.md](docs/unity.md)
for the version policy, the disk budget, the licensing handoff, and the
VRChat-on-Linux caveat.

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
