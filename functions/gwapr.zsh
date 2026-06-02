function gwapr() {
    local _help=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) _help=1; shift ;;
            --) shift; break ;;
            -*) echo "gwapr: unknown option: $1" >&2; return 1 ;;
            *) break ;;
        esac
    done

    if [[ $_help -eq 1 ]]; then
        echo "Usage: gwapr"
        echo ""
        echo "Select an open pull request and create a git worktree for its branch."
        echo "Fork PRs are handled automatically by adding the fork as a remote."
        echo ""
        echo "Options:"
        echo "  -h, --help  Show this help message"
        return 0
    fi

    local selection
    selection=$(gh pr list --json number,title,headRefName,author \
        | jq -r '.[] | "[36m#\(.number)[0m  \(.title) [90m(@\(.author.login))[0m │ \(.headRefName) │ \(.number)"' \
        | fzf --ansi --reverse --height 60% \
            --delimiter ' │ ' --with-nth 1 \
            --header 'Select a pull request' \
            --preview 'gh pr view {3}')
    [[ -z "$selection" ]] && return 0

    local branch pr_number
    branch=$(awk -F ' │ ' '{print $2}' <<< "$selection")
    pr_number=$(awk -F ' │ ' '{print $3}' <<< "$selection")

    local base_dir="${$(basename "$(pwd)")%%+*}"
    local branch_dirname="${branch//\//%}"
    local target_path="../${base_dir}+${branch_dirname}"

    local pr_json is_cross
    pr_json=$(gh pr view "$pr_number" --json isCrossRepository,headRepositoryOwner,headRepository)
    is_cross=$(jq -r '.isCrossRepository' <<< "$pr_json")

    if [[ "$is_cross" == "true" ]]; then
        local fork_owner fork_repo
        fork_owner=$(jq -r '.headRepositoryOwner.login' <<< "$pr_json")
        fork_repo=$(jq -r '.headRepository.name' <<< "$pr_json")
        if ! git remote get-url "$fork_owner" >/dev/null 2>&1; then
            git remote add "$fork_owner" "https://github.com/${fork_owner}/${fork_repo}"
        fi
        git fetch "$fork_owner" "$branch"
        if git rev-parse --verify "$branch" >/dev/null 2>&1; then
            git worktree add "$target_path" "$branch"
        else
            git worktree add --track -b "$branch" "$target_path" "${fork_owner}/${branch}"
        fi
    else
        git fetch origin "$branch" 2>/dev/null
        if git rev-parse --verify "$branch" >/dev/null 2>&1; then
            git worktree add "$target_path" "$branch"
        elif git rev-parse --verify "origin/$branch" >/dev/null 2>&1; then
            git worktree add --track -b "$branch" "$target_path" "origin/$branch"
        else
            echo "gwapr: branch '$branch' not found locally or in origin" >&2
            return 1
        fi
    fi

    cd "$target_path"
}
