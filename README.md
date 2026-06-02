[日本語](README.ja.md) | English

# zsh-ghq-worktree

A zsh plugin that integrates `ghq`, `fzf`, and `git worktree` to minimize context-switching cost in multi-repository development.

## Features

- **`gcd`** — Search and jump to any `ghq`-managed repository via fzf, with Nerd Font icons replacing domain names for compact display
- **`gwcd`** — Switch between git worktrees of the current repository with color-coded fzf UI, or jump directly by branch name
- **`gwa`** — Create a new git worktree, flattening `feature/login`-style branch names to `repo+feature%login` directories; select a branch via fzf if no argument is given
- **`gwapr`** — Select an open pull request and create a worktree for its branch; fork PRs are handled automatically by adding the fork as a remote
- **`gwrm`** — Interactively remove worktrees or repositories with safety checks for unpushed commits and uncommitted changes; uses `trash` for recoverable deletion
- **`gget`** — Browse and clone your GitHub repositories (own / collaborator / org) via `ghq`, with per-type color coding
- **`gcreate`** — Create a new GitHub repository with interactive options (visibility, license, .gitignore, etc.) and clone via `ghq`
- **`gsearch`** — Search all of GitHub by keyword and clone the result via `ghq`

## Requirements

| Tool | Purpose |
|------|---------|
| [zsh](https://www.zsh.org) | Shell |
| [ghq](https://github.com/x-motemen/ghq) | Repository management |
| [fzf](https://github.com/junegunn/fzf) | Interactive filter |
| [git](https://git-scm.com) | Version control / worktree |
| [gh](https://cli.github.com) | GitHub CLI |
| [eza](https://github.com/eza-community/eza) | Tree preview in fzf |
| [bat](https://github.com/sharkdp/bat) | README preview in fzf |
| [jq](https://jqlang.github.io/jq/) | JSON parsing for GitHub API |
| [Nerd Fonts](https://www.nerdfonts.com) | Icons in terminal |
| trash *(optional)* | Safe deletion for `gwrm` — [`trash`](https://github.com/ali-rantakari/trash) on macOS, `gio` or [`trash-cli`](https://github.com/andreafrancia/trash-cli) on Linux |

## Related

- [fish-ghq-worktree](https://github.com/liquidcatmofu/fish-ghq-worktree) — fish version

## Installation

**antidote:**

Add to your `.zsh_plugins.txt`:
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
# Add zsh-ghq-worktree to plugins=() in ~/.zshrc
```

**Manual:**
```zsh
source /path/to/zsh-ghq-worktree.plugin.zsh
```

## Commands

### `gcd` — Jump to a repository

Opens fzf with all `ghq`-managed repositories. Domain names are replaced with Nerd Font icons ( for GitHub) and paths are color-coded for readability.

```
gcd [-h]
```

### `gwcd` — Switch git worktree

Opens fzf listing all worktrees of the current repository. Main worktree is shown in cyan, additional worktrees in yellow. Pass a branch name to skip fzf and switch directly.

```
gwcd [-h] [branch]
```

| Color | Worktree type |
|-------|--------------|
| Cyan | Main worktree |
| Yellow | Additional worktree |

### `gwa` — Add a git worktree

Creates a new worktree for the given branch next to the current repository directory. Branch names containing `/` (e.g. `feature/login`) are flattened to `%` (`repo+feature%login`) to keep the directory structure flat. If no branch is given, opens fzf to select from existing branches.

```
gwa [-h] [branch]
```

### `gwapr` — Create a worktree from a pull request

Lists open pull requests via `gh pr list`, opens fzf to select one, then creates a worktree for its branch. Remote-only branches are fetched and set up with tracking automatically. Fork PRs (cross-repository) are handled by adding the fork as a named remote.

```
gwapr [-h]
```

### `gwrm` — Remove a worktree or repository

Opens fzf with all worktrees of the current repository and all `ghq`-managed repositories. Supports multi-select (TAB). Before removing, checks each item for uncommitted changes and unpushed commits. Uses `trash` for recoverable deletion instead of permanent removal.

```
gwrm [-h] [-f]
```

| Option | Description |
|--------|-------------|
| `-f`, `--force` | Skip safety checks and force removal |

The trash command is resolved automatically (`trash` → `gio trash` → `trash-put`). Override by setting `$GHQ_WORKTREE_TRASH_CMD`:

```zsh
export GHQ_WORKTREE_TRASH_CMD='gio trash'
```

### `gget` — Clone a GitHub repository

Lists GitHub repositories accessible to you and clones the selected one via `ghq`. After cloning, prompts whether to `cd` into the new directory. Repositories are color-coded by type.

```
gget [-h] [-c] [-o] [-a] [-e]
```

| Option | Description |
|--------|-------------|
| `-c`, `--collaborator` | Include repositories you are a collaborator on |
| `-o`, `--org` | Include repositories from your organizations |
| `-a`, `--all` | Include all of the above |
| `-e`, `--exclude-owner` | Exclude your own repositories (requires `-c`, `-o`, or `-a`) |

| Color | Repository type |
|-------|----------------|
| Cyan | Your own repositories |
| Yellow | Organization repositories |
| Green | Collaborator repositories |

### `gcreate` — Create a GitHub repository

Creates a new GitHub repository with the given name (prompted if omitted), then clones it via `ghq`. Supports visibility, description, README, license, .gitignore, and more.

```
gcreate [-h] [-p] [-P] [-d <text>] [-r] [-l [id]] [-g [tmpl]]
        [--disable-issues] [--disable-wiki] [-H <url>] [name]
```

| Option | Description |
|--------|-------------|
| `-p`, `--public` | Create a public repository |
| `-P`, `--private` | Create a private repository (default) |
| `-d`, `--description <text>` | Repository description |
| `-r`, `--readme` | Add a README file |
| `-l`, `--license [id]` | Add a license (opens fzf if id omitted); value must be adjacent: `-lMIT` or `--license=MIT` |
| `-g`, `--gitignore [tmpl]` | Add a .gitignore (opens fzf if template omitted); value must be adjacent: `-gRust` or `--gitignore=Rust` |
| `--disable-issues` | Disable issues |
| `--disable-wiki` | Disable wiki |
| `-H`, `--homepage <url>` | Repository homepage URL |

### `gsearch` — Search GitHub and clone

Searches all of GitHub by keyword using `gh search repos`, opens fzf to select a result, and clones it via `ghq`. After cloning, prompts whether to `cd` into the new directory.

```
gsearch [-h] <query>
```

## Aliases

| Alias | Command |
|---|---|
| `gwl` | `git worktree list` |
| `gwr` | `git worktree remove` |
| `gwp` | `git worktree prune` |

## Worktree directory convention

Worktrees are created as siblings of the main repository directory:

```
~/ghq/github.com/user/
├── myrepo/               # main worktree
├── myrepo+main/          # worktree for branch: main
├── myrepo+feature%login/ # worktree for branch: feature/login
└── myrepo+fix%issue-42/  # worktree for branch: fix/issue-42
```

The separator `+` distinguishes the repository name from the branch name, and `/` in branch names is replaced with `%` to keep directories flat.
