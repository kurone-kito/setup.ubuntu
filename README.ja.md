# ⚙️ Ubuntu 用自動セットアップ

[English](./README.md)

Ubuntu Linux ディストリビューション向けの開発環境設定です。

## セットアップ

```sh
./setup
```

## インストールされるアプリ

### アーカイブツール

- bzip2
- [p7zip](https://sourceforge.net/projects/p7zip/)
- unzip
- xz-utils
- zip

### ベンチマークツール

- [htop](https://htop.dev)
- hyfetch
- hyperfine

### バイナリ変換ツール

- [AtomicParsley](http://atomicparsley.sourceforge.net/)
- [FFmpeg](https://www.ffmpeg.org/)
- [ImageMagick](https://imagemagick.org/index.php)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)

#### 設定管理ツール

- [chezmoi](https://www.chezmoi.io/)

### 暗号化

- [GnuPG: The GNU Privacy Guard](https://gnupg.org/)
- pinentry-curses

### データベース

- [SQLite](https://www.sqlite.org/)
- [Taskwarrior](https://taskwarrior.org/)

### 開発ツール

- build-essential
- cargo
- [CMake](https://cmake.org)
- [GCC: the GNU Compiler Collection](https://gcc.gnu.org)
- make
- mise
- python3

### ダウンロードツール

- ca-certificates
- [curl](https://curl.se)
- httpie
- [GNU wget](https://www.gnu.org/software/wget/)

### ファイル管理

- [bat](https://github.com/sharkdp/bat)
- eza
- fd
- [fzf](https://github.com/junegunn/fzf)
- [rename](http://plasmasturm.org/code/rename/)
- zoxide

#### 生成 AI

- [Ollama](https://ollama.com/)

### ハードウェア

- keyboard-configuration

### ジョーク

- [Nyancat CLI](http://nyancat.dakko.us/)
- [sl](https://github.com/mtoyoda/sl)

### ロケール

- language-pack-ja

### パッケージマネージャー

- apt-file
- apt-transport-https
- apt-utils
- [Homebrew](https://brew.sh/)
- software-properties-common
- vrc-get

### リモートツール

- [awscli](https://aws.amazon.com/cli/)
- [mkcert](https://mkcert.dev/)
- mosh
- OpenSSH Server & Client
- OpenSSL
- [OpenVPN](https://openvpn.net/)
- [rsync](https://rsync.samba.org/)

### SCM ツール

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

### シェルユーティリティ

- bash-completion
- [Microsoft PowerShell](https://microsoft.com/PowerShell)
- rebound
- [shellcheck](https://www.shellcheck.net)
- sudo-rs
- [The Fuck](https://github.com/nvbn/thefuck)
- yank
- zsh
- zsh-theme-powerlevel9k

### テキストブラウジングツール

- links2
- [mdp](https://github.com/visit1985/mdp)
- tealdeer
- w3m

### テキスト変換ツール

- [cloc](https://github.com/AlDanial/cloc)
- [groff](https://www.gnu.org/software/groff/)
- [jc](https://kellyjonbrazil.github.io/jc/)
- [jq](https://stedolan.github.io/jq/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [yq](https://mikefarah.gitbook.io/yq)

### テキストエディター

- [GNU Nano](https://www.nano-editor.org)
- [Neovim](https://neovim.io/)
- [Vim](https://www.vim.org/)

### TUI

- [byobu](https://www.byobu.org/)
- [tmux](https://github.com/tmux/tmux)
- [zellij](https://zellij.dev)

#### 仮想化

- Docker community edition

### その他

- apt パッケージのアップグレード

## テスト（VM 上で実行）

いくつかのツールが必要です:

- [Multipass](https://multipass.run/)
- [Terraform](https://www.terraform.io/)

```sh
./setup -v

# ...または Ubuntu 以外の環境でセットアップを起動するだけでもかまいません。
./setup
```

Ubuntu 以外の環境でセットアップを実行した場合は、`-v` オプションが
指定されたものとして自動的に扱われ、VM 環境内でセットアップが実行されます。

### VM の破棄

```sh
./nuke
```

## 関連リンク

- [dotfiles](https://github.com/kurone-kito/dotfiles)
- [setup.macos](https://github.com/kurone-kito/setup.macos)
- [setup.windows](https://github.com/kurone-kito/setup.windows)

## ライセンス

[MIT](./LICENSE)
