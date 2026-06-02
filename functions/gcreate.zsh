function gcreate() {
    local -a _help=() _public=() _private=() _readme=()
    local -a _disable_issues=() _disable_wiki=()
    local -a _description=() _license=() _gitignore=() _homepage=()
    zparseopts -D -E \
        h=_help         -help=_help \
        p=_public       -public=_public \
        P=_private      -private=_private \
        r=_readme       -readme=_readme \
        d:=_description -description:=_description \
        l::=_license    -license::=_license \
        g::=_gitignore  -gitignore::=_gitignore \
        H:=_homepage    -homepage:=_homepage \
        -disable-issues=_disable_issues \
        -disable-wiki=_disable_wiki \
        || { echo "gcreate: invalid option" >&2; return 1 }

    if (( ${#_help} )); then
        echo "Usage: gcreate [options] [name]"
        echo ""
        echo "Create a new GitHub repository and clone via ghq."
        echo ""
        echo "Arguments:"
        echo "  name                     Repository name (prompted if omitted)"
        echo ""
        echo "Options:"
        echo "  -p, --public             Create a public repository"
        echo "  -P, --private            Create a private repository (default)"
        echo "  -d, --description <text> Repository description"
        echo "  -r, --readme             Add a README file"
        echo "  -l, --license [id]       Add a license (opens fzf if id omitted)"
        echo "  -g, --gitignore [tmpl]   Add a .gitignore (opens fzf if template omitted)"
        echo "      --disable-issues     Disable issues"
        echo "      --disable-wiki       Disable wiki"
        echo "  -H, --homepage <url>     Repository homepage URL"
        echo "  -h, --help               Show this help message"
        return 0
    fi

    local name="${1:-}"
    if [[ -z "$name" ]]; then
        echo -n "Repository name: "
        read -r name
        if [[ -z "$name" ]]; then
            echo "gcreate: repository name is required" >&2
            return 1
        fi
    fi

    local -a gh_args=()

    # -p and -P: last one on the command line wins
    local _is_public=0
    (( ${#_public} ))  && _is_public=1
    (( ${#_private} )) && _is_public=0
    [[ $_is_public -eq 1 ]] && gh_args+=(--public) || gh_args+=(--private)

    # _description[2] holds the value (index 1 is the flag itself)
    [[ -n "${_description[2]:-}" ]] && gh_args+=(--description "${_description[2]}")
    (( ${#_readme} )) && gh_args+=(--add-readme)

    if (( ${#_license} )); then
        local _license_val="${_license[2]:-}"
        if [[ -n "$_license_val" ]]; then
            gh_args+=(--license "$_license_val")
        else
            local license
            license=$(gh api /licenses --jq '.[].spdx_id' \
                | fzf --reverse --height 40% --header 'Select a license')
            [[ -n "$license" ]] && gh_args+=(--license "$license")
        fi
    fi

    if (( ${#_gitignore} )); then
        local _gitignore_val="${_gitignore[2]:-}"
        if [[ -n "$_gitignore_val" ]]; then
            gh_args+=(--gitignore "$_gitignore_val")
        else
            local tmpl
            tmpl=$(gh api /gitignore/templates --jq '.[]' \
                | fzf --reverse --height 40% --header 'Select a .gitignore template')
            [[ -n "$tmpl" ]] && gh_args+=(--gitignore "$tmpl")
        fi
    fi

    (( ${#_disable_issues} )) && gh_args+=(--disable-issues)
    (( ${#_disable_wiki} ))   && gh_args+=(--disable-wiki)
    [[ -n "${_homepage[2]:-}" ]] && gh_args+=(--homepage "${_homepage[2]}")

    gh repo create "$name" "${gh_args[@]}" || return 1

    local current_user full_name
    current_user=$(gh api /user --jq '.login')
    full_name="${current_user}/${name}"

    echo "Cloning $full_name via ghq..."
    ghq get "$full_name" || return 1

    local answer
    echo -n "cd into $full_name? [Y/n] "
    read -r answer
    if [[ -z "$answer" || "$answer" == Y || "$answer" == y ]]; then
        cd "$(ghq list -p --exact "$full_name")"
    fi
}
