_ghq_wt_dir="${0:A:h}"

# Dependency check
for _dep in ghq fzf git gh eza bat jq; do
    if ! command -v "$_dep" >/dev/null 2>&1; then
        echo "Warning: zsh-ghq-worktree requires '$_dep' to be installed." >&2
    fi
done
unset _dep

# Add completions to fpath (must be before compinit)
fpath=("${_ghq_wt_dir}/completions" $fpath)

# Source functions
for _func in gget gcd gwa gwcd gsearch; do
    source "${_ghq_wt_dir}/functions/${_func}.zsh"
done
unset _ghq_wt_dir _func

# Aliases (equivalent to fish abbreviations)
alias gwl='git worktree list'
alias gwr='git worktree remove'
alias gwp='git worktree prune'
