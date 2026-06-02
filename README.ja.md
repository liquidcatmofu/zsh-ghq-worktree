日本語 | [English](README.md)

# zsh-ghq-worktree

`ghq`・`fzf`・`git worktree` を統合し、マルチリポジトリ開発におけるコンテキストスイッチのコストを最小化する zsh プラグインです。

## 機能

- **`gcd`** — `ghq` が管理する全リポジトリを fzf で検索してジャンプ。ドメイン名を Nerd Font アイコンに置換し、コンパクトに表示
- **`gwcd`** — 現在のリポジトリのワークツリーをカラー表示の fzf で切り替え。ブランチ名を直接指定して fzf をスキップすることも可能
- **`gwa`** — 新しいワークツリーを作成。`feature/login` のようなブランチ名を `repo+feature%login` にフラット化して管理しやすく。引数なしで fzf からブランチを選択
- **`gwapr`** — オープンな PR を選択し、そのブランチを worktree として追加。フォークからの PR も自動でリモート登録して対応
- **`gwrm`** — ワークツリー・リポジトリをインタラクティブに削除。未プッシュコミット・未コミット変更を確認し、`trash` で安全に（復元可能に）削除
- **`gget`** — GitHub リポジトリ（自分・コラボレーター・org）を種別ごとに色分けして一覧表示し、`ghq` でクローン
- **`gcreate`** — 新しい GitHub リポジトリをインタラクティブに作成（公開設定・ライセンス・.gitignore など）し、`ghq` でクローン
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
| trash *（任意）* | `gwrm` での安全な削除 — macOS は [`trash`](https://github.com/ali-rantakari/trash)、Linux は `gio` または [`trash-cli`](https://github.com/andreafrancia/trash-cli) |

## 関連

- [fish-ghq-worktree](https://github.com/liquidcatmofu/fish-ghq-worktree) — fish 版

## インストール

**antidote:**

`.zsh_plugins.txt` に追加:
```
liquidcatmofu/zsh-ghq-worktree
```

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

### `gwapr` — PR から worktree を作成

`gh pr list` でオープンな PR を一覧表示し、fzf で選択したブランチの worktree を作成します。ローカルに存在しないリモートブランチも自動でフェッチしてトラッキング設定を行います。フォークからの PR（クロスリポジトリ）にも対応しており、フォーク元を自動でリモートとして登録します。

```
gwapr [-h]
```

### `gwrm` — worktree・リポジトリを削除

カレントリポジトリの worktree と `ghq` 管理下のリポジトリを fzf で一覧表示し、削除対象を選択します（TAB で複数選択可）。削除前に未コミット変更・未プッシュコミットを確認し、問題があればスキップして警告を表示します。`trash` コマンドでゴミ箱に移動するため、誤って削除しても復元できます。

```
gwrm [-h] [-f]
```

| オプション | 説明 |
|-----------|------|
| `-f`, `--force` | 安全確認をスキップして強制削除 |

trash コマンドは自動検出されます（`trash` → `gio trash` → `trash-put` の優先順）。`$GHQ_WORKTREE_TRASH_CMD` で上書き可能です：

```zsh
export GHQ_WORKTREE_TRASH_CMD='gio trash'
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

### `gcreate` — GitHub リポジトリを作成

リポジトリ名（省略時はプロンプトで入力）で新しい GitHub リポジトリを作成し、`ghq` でクローンします。公開設定・説明・README・ライセンス・.gitignore などのオプションに対応しています。

```
gcreate [-h] [-p] [-P] [-d <text>] [-r] [-l [id]] [-g [tmpl]]
        [--disable-issues] [--disable-wiki] [-H <url>] [name]
```

| オプション | 説明 |
|-----------|------|
| `-p`, `--public` | パブリックリポジトリとして作成 |
| `-P`, `--private` | プライベートリポジトリとして作成（デフォルト） |
| `-d`, `--description <text>` | リポジトリの説明 |
| `-r`, `--readme` | README ファイルを追加 |
| `-l`, `--license [id]` | ライセンスを追加（id省略時はfzfで選択）。値は隣接指定が必要: `-lMIT` または `--license=MIT` |
| `-g`, `--gitignore [tmpl]` | .gitignore を追加（テンプレート省略時はfzfで選択）。値は隣接指定が必要: `-gRust` または `--gitignore=Rust` |
| `--disable-issues` | Issue を無効化 |
| `--disable-wiki` | Wiki を無効化 |
| `-H`, `--homepage <url>` | リポジトリのホームページ URL |

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
