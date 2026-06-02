function gwrm() {
    local -a _help=() _force=()
    zparseopts -D -E \
        h=_help -help=_help \
        f=_force -force=_force \
        || { echo "gwrm: invalid option" >&2; return 1 }

    if (( ${#_help} )); then
        echo "Usage: gwrm [-f]"
        echo ""
        echo "Interactively select and remove git worktrees or repositories."
        echo "Checks for unpushed commits and uncommitted changes before removing."
        echo ""
        echo "Options:"
        echo "  -f, --force  Skip safety checks and force removal"
        echo "  -h, --help   Show this help message"
        return 0
    fi

    # Resolve trash command ($GHQ_WORKTREE_TRASH_CMD overrides auto-detection)
    local -a trash_cmd=()
    if [[ -n "$GHQ_WORKTREE_TRASH_CMD" ]]; then
        trash_cmd=(${=GHQ_WORKTREE_TRASH_CMD})
    elif command -v trash >/dev/null 2>&1; then
        trash_cmd=(trash)
    elif command -v gio >/dev/null 2>&1; then
        trash_cmd=(gio trash)
    elif command -v trash-put >/dev/null 2>&1; then
        trash_cmd=(trash-put)
    else
        echo "gwrm: no trash command found." >&2
        echo "  macOS: brew install trash" >&2
        echo "  Linux: apt install trash-cli  (provides trash-put)" >&2
        echo "  or: export GHQ_WORKTREE_TRASH_CMD='your-command'" >&2
        return 1
    fi

    local -a items=()

    if git rev-parse --git-dir >/dev/null 2>&1; then
        while IFS= read -r line; do
            local path dirname branch
            path=$(awk '{print $1}' <<< "$line")
            dirname=$(basename "$path")
            if [[ "$dirname" == *+* ]]; then
                branch="${dirname#*+}"
                branch="${branch//%//}"
                items+=("$(printf "\033[33m󱂬  %-30s\033[0m │ worktree │ %s" "$branch" "$path")")
            fi
        done <<< "$(git worktree list | tail -n +2)"
    fi

    local ghq_root
    ghq_root=$(ghq root)
    while IFS= read -r path; do
        local name="${path#${ghq_root}/}"
        items+=("$(printf "\033[32m  %-45s\033[0m │ repo │ %s" "$name" "$path")")
    done <<< "$(ghq list -p)"

    if [[ ${#items[@]} -eq 0 ]]; then
        echo "No worktrees or repositories found."
        return 0
    fi

    local selected
    selected=$(printf '%s\n' "${items[@]}" \
        | fzf --ansi --multi --reverse --height 60% \
            --delimiter ' │ ' --with-nth 1 \
            --header 'Select items to remove (TAB: multi-select)')
    [[ -z "$selected" ]] && return 0

    local had_warnings=0
    while IFS= read -r item; do
        local item_type path
        item_type=$(awk -F ' │ ' '{print $2}' <<< "$item" | xargs)
        path=$(awk -F ' │ ' '{print $3}' <<< "$item" | xargs)

        if (( !${#_force} )); then
            local dirty unpushed upstream_ok
            dirty=$(git -C "$path" status --porcelain 2>/dev/null)
            unpushed=$(git -C "$path" log "@{u}..HEAD" --oneline 2>/dev/null)
            upstream_ok=$?

            local -a warnings=()
            [[ -n "$dirty" ]] && warnings+=("uncommitted changes")
            if [[ $upstream_ok -ne 0 ]]; then
                warnings+=("no upstream tracking branch (push status unknown)")
            elif [[ -n "$unpushed" ]]; then
                warnings+=("unpushed commits")
            fi

            if [[ ${#warnings[@]} -gt 0 ]]; then
                echo "Skipping $path:"
                for w in "${warnings[@]}"; do
                    echo "  - $w"
                done
                echo "  Use -f/--force to remove anyway"
                had_warnings=1
                continue
            fi
        fi

        if "${trash_cmd[@]}" "$path"; then
            echo "Removed: $path"
        else
            echo "gwrm: failed to remove $path" >&2
            had_warnings=1
        fi
    done <<< "$selected"

    git worktree prune 2>/dev/null
    return $had_warnings
}
