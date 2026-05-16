function gwa() {
    local _help=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) _help=1; shift ;;
            --) shift; break ;;
            -*) echo "gwa: unknown option: $1" >&2; return 1 ;;
            *) break ;;
        esac
    done

    if [[ $_help -eq 1 ]]; then
        echo "Usage: gwa [branch]"
        echo ""
        echo "Create a git worktree, replacing '/' with '%' in directory names."
        echo "If no branch is given, opens fzf to select from existing branches."
        echo ""
        echo "Arguments:"
        echo "  branch  Branch name to create or checkout as a worktree"
        echo ""
        echo "Options:"
        echo "  -h, --help  Show this help message"
        return 0
    fi

    local branch
    if [[ $# -ge 1 ]]; then
        branch="$1"
    else
        branch=$(git branch --all --format='%(refname:short)' \
            | sed 's|^origin/||' | sort -u \
            | fzf --reverse --height 50% --header 'Select a branch' \
                --preview 'git log --oneline --color=always -15 {}')
        [[ -z "$branch" ]] && return 0
    fi

    # Strip any existing worktree suffix (everything from the first '+')
    local base_dir="${$(basename "$(pwd)")%%+*}"
    local branch_dirname="${branch//\//%}"
    local target_path="../${base_dir}+${branch_dirname}"

    if git rev-parse --verify "$branch" >/dev/null 2>&1; then
        git worktree add "$target_path" "$branch"
    else
        git worktree add "$target_path" -b "$branch"
    fi

    cd "$target_path"
}
