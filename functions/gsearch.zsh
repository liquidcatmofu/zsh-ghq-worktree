function gsearch() {
    local _help=0

    # Only consume -h/--help; pass all other args through to gh search repos
    if [[ "$1" = -h || "$1" = --help ]]; then
        _help=1
    fi

    if [[ $_help -eq 1 ]]; then
        echo "Usage: gsearch <query>"
        echo ""
        echo "Search GitHub repositories by keyword and clone via ghq."
        echo ""
        echo "Arguments:"
        echo "  query  Search keyword(s) to pass to 'gh search repos'"
        echo ""
        echo "Options:"
        echo "  -h, --help  Show this help message"
        return 0
    fi

    if [[ $# -lt 1 ]]; then
        echo "Usage: gsearch <query>" >&2
        return 1
    fi

    local repo
    repo=$(gh search repos "$@" --limit 100 | fzf --reverse --height 60% \
        --preview 'gh repo view {1} | bat -l md --color=always --style=plain')

    if [[ -n "$repo" ]]; then
        local repo_name="${repo%% *}"
        ghq get "$repo_name"
        local answer
        echo -n "cd into $repo_name? [Y/n] "
        read -r answer
        if [[ -z "$answer" || "$answer" = Y || "$answer" = y ]]; then
            cd "$(ghq list -p --exact "$repo_name")"
        fi
    fi
}
