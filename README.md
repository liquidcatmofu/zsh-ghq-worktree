[日本語](README.ja.md) | English

# zsh-ghq-worktree

A zsh plugin that integrates `ghq`, `fzf`, and `git worktree` to minimize context-switching cost in multi-repository development.

## Features

- **`gcd`** — Search and jump to any `ghq`-managed repository via fzf, with Nerd Font icons replacing domain names for compact display
- **`gwcd`** — Switch between git worktrees of the current repository with color-coded fzf UI, or jump directly by branch name
- **`gwa`** — Create a new git worktree, flattening `feature/login`-style branch names to `repo+feature%login` directories; select a branch via fzf if no argument is given
- **`gget`** — Browse and clone your GitHub repositories (own / collaborator / org) via `ghq`, with per-type color coding
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

## Installation

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
