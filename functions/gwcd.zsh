function gwcd() {
    local _help=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) _help=1; shift ;;
            --) shift; break ;;
            -*) echo "gwcd: unknown option: $1" >&2; return 1 ;;
            *) break ;;
        esac
    done

    if [[ $_help -eq 1 ]]; then
        echo "Usage: gwcd [branch]"
        echo ""
        echo "Search and switch git worktrees with dynamic coloring."
        echo ""
        echo "Arguments:"
        echo "  branch  Branch name to switch to directly (skips fzf)"
        echo ""
        echo "Options:"
        echo "  -h, --help  Show this help message"
        return 0
    fi

    if [[ $# -ge 1 ]]; then
        local branch="$1"
        local branch_encoded="${branch//\//%}"
        local path
        path=$(git worktree list | awk -v branch="$branch_encoded" -v raw_branch="$branch" '
            {
                path = $1
                n = split(path, parts, "/")
                dirname = parts[n]
                m = split(dirname, subparts, "+")
                if (m > 1 && subparts[2] == branch) { print path; exit }
                ref = $3; gsub(/[\[\]]/, "", ref)
                if (ref == raw_branch) { print path; exit }
            }')
        if [[ -n "$path" ]]; then
            cd "$path"
        else
            echo "gwcd: no worktree found for branch: $branch" >&2
            return 1
        fi
        return
    fi

    local selected
    selected=$(git worktree list | awk '
        BEGIN {
            CYAN   = "\033[36m";
            YELLOW = "\033[33m";
            RESET  = "\033[0m";
            ICON_MAIN = "󰊢";
            ICON_WT   = "󱂬";
        }
        {
            path = $1;
            n = split(path, parts, "/");
            dirname = parts[n];
            m = split(dirname, subparts, "+");
            if (m > 1) {
                branch = subparts[2];
                gsub("%", "/", branch);
                printf "%s%s  %-25s%s │ %s\n", YELLOW, ICON_WT, branch, RESET, path
            } else {
                branch = ($3 == "" ? "main" : $3);
                gsub(/[\[\]]/, "", branch);
                printf "%s%s  %-25s%s │ %s\n", CYAN, ICON_MAIN, branch, RESET, path
            }
        }' | sort | fzf --ansi --reverse --height 50% --delimiter ' │ ' --with-nth 1 \
            --header 'Type  Branch' \
            --preview 'echo {2} | xargs eza --icons --color=always' \
        | awk -F ' │ ' '{print $2}')

    if [[ -n "$selected" ]]; then
        cd "$selected"
    fi
}
