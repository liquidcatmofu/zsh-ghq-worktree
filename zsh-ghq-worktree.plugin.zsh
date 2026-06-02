_ghq_wt_dir="${0:A:h}"

# Dependency check
for _dep in ghq fzf git gh eza bat jq; do
    if ! command -v "$_dep" >/dev/null 2>&1; then
        echo "Warning: zsh-ghq-worktree requires '$_dep' to be installed." >&2
    fi
done
unset _dep

# trash コマンドは gwrm でのみ必要。$GHQ_WORKTREE_TRASH_CMD で上書き可能
if [[ -z "$GHQ_WORKTREE_TRASH_CMD" ]]; then
    if ! command -v trash >/dev/null 2>&1 && \
       ! command -v gio >/dev/null 2>&1 && \
       ! command -v trash-put >/dev/null 2>&1; then
        echo "Warning: zsh-ghq-worktree: no trash command found (needed for gwrm)." >&2
        echo "  macOS: brew install trash" >&2
        echo "  Linux: apt install trash-cli  (provides trash-put)" >&2
        echo "  or: export GHQ_WORKTREE_TRASH_CMD='your-command'" >&2
    fi
fi

# Add completions to fpath (must be before compinit)
fpath=("${_ghq_wt_dir}/completions" $fpath)

# Source functions
for _func in gget gcd gwa gwcd gsearch gwapr gwrm gcreate; do
    source "${_ghq_wt_dir}/functions/${_func}.zsh"
done
unset _ghq_wt_dir _func

# Aliases (equivalent to fish abbreviations)
alias gwl='git worktree list'
alias gwr='git worktree remove'
alias gwp='git worktree prune'
