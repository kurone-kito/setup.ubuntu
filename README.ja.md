# ⚙️ Ubuntu 用自動セットアップ

[English](./README.md)

Ubuntu Linux ディストリビューション向けの開発環境設定です。

## セットアップ

```sh
./setup
```

## インストールされるアプリ

|  記号   | 説明                                                                                                                         |
| :-----: | :--------------------------------------------------------------------------------------------------------------------------- |
| **`!`** | **依存関係**: これらのアプリを削除すると、このセットアップが正しく動作しなくなる場合があります。                             |
| **`.`** | **[dotfiles](https://github.com/kurone-kito/dotfiles) の依存関係**: dotfiles を正しく動作させるために必要です。              |
|   (B)   | [Homebrew](https://brew.sh/) パッケージマネージャー経由でインストールされるため、Homebrew で管理できます。                   |
|   (M)   | [mise-en-place](https://mise.jdx.dev/) パッケージマネージャー経由でインストールされるため、mise-en-place で管理できます。    |

### アーカイブツール

- bzip2
- [p7zip](https://github.com/ip7z/7zip)
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

### クリップボードツール

- [xsel](http://www.kfish.org/software/xsel/)
- [yank](https://github.com/mptre/yank)

### 設定管理ツール

- **`.`** (M) [Bitwarden CLI](https://bitwarden.com/)
- **`.`** (B) [chezmoi](https://www.chezmoi.io/)

### 暗号化

- **`!`** [GnuPG: The GNU Privacy Guard](https://gnupg.org/)
- **`.`** [pinentry-curses](https://manpages.ubuntu.com/manpages/man1/pinentry-curses.1.html)

### データベース

- [SQLite](https://www.sqlite.org/)
- (B) [Taskwarrior](https://taskwarrior.org/)

### 開発ツール

- (B) [ast-grep](https://ast-grep.github.io/)
- **`!`** build-essential
- **`!`** [cargo](https://doc.rust-lang.org/stable/cargo/)
- (B) **`!`** [Cargo Binary Install](https://github.com/cargo-bins/cargo-binstall)
- [CMake](https://cmake.org)
- (B) [Deno](https://deno.com/)
- (B) [direnv](https://direnv.net/)
- [GCC: the GNU Compiler Collection](https://gcc.gnu.org)
- make
- **`.`** (M) [Node.js](https://nodejs.org/)
- (B) [python3](https://www.python.org/)
- (B) [tree-sitter](https://tree-sitter.github.io/tree-sitter/)

### ダウンロードツール

- **`!`** [ca-certificates](https://curl.se/docs/caextract.html)
- **`!`** [curl](https://curl.se)
- [GNU wget](https://www.gnu.org/software/wget/)

### ファイル管理

- [bat](https://github.com/sharkdp/bat)
- eza
- (B) [fd](https://github.com/sharkdp/fd)
- [fzf](https://github.com/junegunn/fzf)
- [rename](http://plasmasturm.org/code/rename/)
- [trash-cli](https://github.com/andreafrancia/trash-cli)
- (B) [watchexec](https://github.com/watchexec/watchexec)
- (B) [yazi](https://yazi-rs.github.io/)
- **`.`** [zoxide](https://crates.io/crates/zoxide)

### ゲーム開発

- [Unity CLI](https://docs.unity.com/en-us/unity-cli)

#### 生成 AI

- (B) [Ollama](https://ollama.com/)

### ハードウェア

- **`!`** keyboard-configuration

### ジョーク

- [Nyancat CLI](http://nyancat.dakko.us/)
- [sl](https://github.com/mtoyoda/sl)

### ロケール

- **`!`** language-pack-ja

### パッケージマネージャー

- apt-file
- apt-transport-https
- apt-utils
- **`!`** [Homebrew](https://brew.sh/)
- **`!`** (B) [mise-en-place](https://mise.jdx.dev/)
- **`!`** software-properties-common
- **`.`** (B) [vrc-get](https://github.com/vrc-get/vrc-get)

### リモートツール

- **`.`** (B) [awscli](https://aws.amazon.com/cli/)
- [httpie](https://httpie.io/)
- [LazySSH](https://github.com/Adembc/lazyssh)
- [mkcert](https://mkcert.dev/)
- mosh
- [ngrok](https://ngrok.com/)
- **`.`** [OpenSSH Server & Client](https://www.openssh.org/)
- OpenSSL
- [OpenVPN](https://openvpn.net/)
- [rsync](https://rsync.samba.org/)

### SCM ツール

- **`.`** (B) [ghq](https://github.com/x-motemen/ghq)
- **`.`** [GitHub CLI](https://cli.github.com/)
- **`.`** [Git](https://git-scm.com/)
- **`.`** [git-delta: A viewer for git and diff output](https://github.com/dandavison/delta)
- **`.`** [Git Large File Storage](https://git-lfs.github.com/)
- (B) [gti](https://r-wos.org/hacks/gti)
- (B) [Jujutsu](https://jj-vcs.dev/)
- (B) [lazygit](https://github.com/jesseduffield/lazygit)
- (B) [lazyjj](https://github.com/Cretezy/lazyjj)
- [Apache Subversion](https://subversion.apache.org/)
- (B) [Worktrunk](https://worktrunk.dev/)

### シェルユーティリティ

- bash-completion
- **`.`** (B) [Microsoft PowerShell](https://microsoft.com/PowerShell)
- [shellcheck](https://www.shellcheck.net)
- **`.`** (B) [Starship](https://starship.rs/)
- sudo-rs
- [The Fuck](https://github.com/nvbn/thefuck)
- **`.`** [zsh](https://www.zsh.org/)

### テキストブラウジングツール

- (B) [glow](https://github.com/charmbracelet/glow)
- links2
- [mdp](https://github.com/visit1985/mdp)
- tealdeer
- w3m

### テキスト変換ツール

- [cloc](https://github.com/AlDanial/cloc)
- [dprint](https://dprint.dev/)
- [groff](https://www.gnu.org/software/groff/)
- [jc](https://kellyjonbrazil.github.io/jc/)
- [jq](https://stedolan.github.io/jq/)
- (B) [pkl](https://pkl-lang.org/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- **`!`** [yq](https://github.com/kislyuk/yq)

### テキストエディター

- (B) [Microsoft Edit](https://github.com/microsoft/edit)
- **`.`** (B) [Neovim](https://neovim.io/)
- **`.`** [Vim](https://www.vim.org/)

### TUI

- **`.`** [tmux](https://github.com/tmux/tmux)
- **`.`** (B) [zellij](https://zellij.dev)

#### 仮想化

- (B) [act](https://github.com/nektos/act)
- (B) [dive](https://github.com/wagoodman/dive)
- (B) [k3sup](https://github.com/alexellis/k3sup)
- [Docker community edition](https://www.docker.com/)
- (B) [lazydocker](https://github.com/jesseduffield/lazydocker)

### その他

- apt パッケージのアップグレード

## デスクトップ（任意）

既定の `./setup` は CLI のみの環境を構築します。Unity Editor をリモートデスクトップ
で使うなどの GUI 用途向けに、**オプトイン**のグラフィカル層（RDP 経由の XFCE と、
bare-metal 向けの GPU ストリーミング用 Sunshine）を追加できます。WSL では Sunshine は
既定でスキップされ（WSLg を利用）、実験的な opt-in がある場合のみ導入します。

```sh
./setup --desktop            # デスクトップ層を導入（実機 Ubuntu）
./setup --desktop --dry-run  # プランのみ表示し、何も導入しない
```

既定の起動は CLI のまま（ディスプレイマネージャーは導入しません）で、グラフィカル
セッションは接続時のみ開始します。クライアント一覧・WSL2 経路・セキュリティ・
chezmoi への受け渡しは [docs/desktop.md](docs/desktop.md) を参照してください。

## Unity（任意）

Unity CLI は既定のパスでインストールされます。Unity Editor 本体は
**オプトイン**であり、ライセンス未認証の状態でインストールされます —
ライセンスの有効化はこのリポジトリが認証情報を保持しない、運用者側の
別ステップです:

```sh
./setup --unity            # 固定バージョンの Unity Editor を導入（実機 Ubuntu）
./setup --unity --dry-run  # プランのみ表示し、何も導入しない
```

`--dry-run` は最新バージョン情報を取得するため、Unity CLI が既に `PATH`
上にあることを前提とします。過去に一度でも `./setup` を実行済みであれば
既にインストールされています。バージョンポリシー・ディスク使用量・
ライセンスの受け渡し・VRChat の Linux 対応状況については
[docs/unity.md](docs/unity.md) を参照してください。

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
