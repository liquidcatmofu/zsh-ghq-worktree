function gcd() {
    local _help=0

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) _help=1; shift ;;
            --) shift; break ;;
            -*) echo "gcd: unknown option: $1" >&2; return 1 ;;
            *) break ;;
        esac
    done

    if [[ $_help -eq 1 ]]; then
        echo "Usage: gcd"
        echo ""
        echo "Search and move to a ghq-managed repository using fzf."
        echo "Domains are replaced with Nerd Font icons for compact display."
        echo ""
        echo "Options:"
        echo "  -h, --help  Show this help message"
        return 0
    fi

    local selected
    selected=$(ghq list | awk -F/ '
        BEGIN {
            CYAN = "\033[36m";
            GRAY = "\033[90m";
            RESET = "\033[0m";
        }
        {
            icon = ($1 == "github.com" ? " " : "󰊤 ");

            path = "";
            for (i=2; i<=NF; i++) {
                path = (path == "" ? $i : path "/" $i);
            }

            printf "%s%s %s%s%-30s%s │ %s\n", GRAY, icon, RESET, CYAN, path, RESET, $0
        }' | fzf --ansi --reverse --height 50% --delimiter ' │ ' --with-nth 1 \
            --preview 'ghq list -p --exact {2} | xargs eza --tree --level 2 --icons --color=always' \
        | awk -F ' │ ' '{print $2}')

    if [[ -n "$selected" ]]; then
        cd "$(ghq list -p --exact "$selected")"
    fi
}
