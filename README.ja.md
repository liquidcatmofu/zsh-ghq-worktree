日本語 | [English](README.md)

# zsh-ghq-worktree

`ghq`・`fzf`・`git worktree` を統合し、マルチリポジトリ開発におけるコンテキストスイッチのコストを最小化する zsh プラグインです。

## 機能

- **`gcd`** — `ghq` が管理する全リポジトリを fzf で検索してジャンプ。ドメイン名を Nerd Font アイコンに置換し、コンパクトに表示
- **`gwcd`** — 現在のリポジトリのワークツリーをカラー表示の fzf で切り替え。ブランチ名を直接指定して fzf をスキップすることも可能
- **`gwa`** — 新しいワークツリーを作成。`feature/login` のようなブランチ名を `repo+feature%login` にフラット化して管理しやすく。引数なしで fzf からブランチを選択
- **`gget`** — GitHub リポジトリ（自分・コラボレーター・org）を種別ごとに色分けして一覧表示し、`ghq` でクローン
- **`gsearch`** — キーワードで GitHub 全体を検索し、結果を `ghq` でクローン

## 必要なツール

| ツール | 用途 |
|--------|------|
| [zsh](https://www.zsh.org) | シェル本体 |
| [ghq](https://github.com/x-motemen/ghq) | リポジトリの集約管理 |
| [fzf](https://github.com/junegunn/fzf) | インタラクティブフィルター |
| [git](https://git-scm.com) | バージョン管理・worktree 操作 |
| [gh](https://cli.github.com) | GitHub CLI |
| [eza](https://github.com/eza-community/eza) | fzf プレビュー内のツリー表示 |
| [bat](https://github.com/sharkdp/bat) | fzf プレビュー内の README 表示 |
| [jq](https://jqlang.github.io/jq/) | GitHub API のレスポンス解析 |
| [Nerd Fonts](https://www.nerdfonts.com) | ターミナル上のアイコン表示 |

## インストール

**zinit:**
```zsh
zinit light liquidcatmofu/zsh-ghq-worktree
```

**oh-my-zsh:**
```zsh
git clone https://github.com/liquidcatmofu/zsh-ghq-worktree \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-ghq-worktree
# ~/.zshrc の plugins=() に zsh-ghq-worktree を追加
```

**手動:**
```zsh
source /path/to/zsh-ghq-worktree.plugin.zsh
```

## コマンド

### `gcd` — リポジトリへジャンプ

`ghq` が管理する全リポジトリを fzf で表示します。ドメイン名は Nerd Font アイコン（GitHub は ）に置換され、ユーザー名/リポジトリ名が左端に表示されます。

```
gcd [-h]
```

### `gwcd` — ワークツリーを切り替え

現在のリポジトリのワークツリーを一覧表示します。メインワークツリーはシアン、追加ワークツリーはイエローで色分けされます。ブランチ名を引数に渡すと fzf をスキップして直接移動します。

```
gwcd [-h] [ブランチ名]
```

| 色 | ワークツリーの種別 |
|----|-----------------|
| シアン | メインワークツリー |
| イエロー | 追加ワークツリー |

### `gwa` — ワークツリーを作成

現在のリポジトリと同じ階層に新しいワークツリーを作成します。ブランチ名に `/` が含まれる場合（例: `feature/login`）は `%` に置換し、ディレクトリ構造をフラットに保ちます。引数なしで実行すると fzf でブランチを選択できます。

```
gwa [-h] [ブランチ名]
```

### `gget` — GitHub リポジトリをクローン

アクセス可能な GitHub リポジトリを一覧表示し、選択したものを `ghq` でクローンします。クローン後に `cd` するか確認プロンプトを表示します。リポジトリは種別ごとに色分けされます。

```
gget [-h] [-c] [-o] [-a] [-e]
```

| オプション | 説明 |
|-----------|------|
| `-c`, `--collaborator` | コラボレーターとして参加しているリポジトリを含める |
| `-o`, `--org` | 所属 org のリポジトリを含める |
| `-a`, `--all` | 上記すべてを含める |
| `-e`, `--exclude-owner` | 自分が owner のリポジトリを除外する（`-c`・`-o`・`-a` と併用） |

| 色 | リポジトリの種別 |
|----|----------------|
| シアン | 自分が owner のリポジトリ |
| イエロー | org のリポジトリ |
| グリーン | コラボレーターのリポジトリ |

### `gsearch` — GitHub を検索してクローン

`gh search repos` でキーワード検索し、fzf で選択したリポジトリを `ghq` でクローンします。クローン後に `cd` するか確認プロンプトを表示します。

```
gsearch [-h] <キーワード>
```

## エイリアス

| エイリアス | コマンド |
|-----------|---------|
| `gwl` | `git worktree list` |
| `gwr` | `git worktree remove` |
| `gwp` | `git worktree prune` |

## ワークツリーのディレクトリ構造

ワークツリーはメインリポジトリの隣に作成されます。

```
~/ghq/github.com/user/
├── myrepo/               # メインワークツリー
├── myrepo+main/          # ブランチ: main
├── myrepo+feature%login/ # ブランチ: feature/login
└── myrepo+fix%issue-42/  # ブランチ: fix/issue-42
```

リポジトリ名とブランチ名の区切りには `+` を使用し、ブランチ名中の `/` は `%` に置換することでディレクトリ階層をフラットに保ちます。
