function gget() {
    local -a _help=() _collaborator=() _org=() _all=() _exclude_owner=()
    zparseopts -D -E \
        h=_help    -help=_help \
        c=_collaborator  -collaborator=_collaborator \
        o=_org     -org=_org \
        a=_all     -all=_all \
        e=_exclude_owner -exclude-owner=_exclude_owner \
        || { echo "gget: invalid option" >&2; return 1 }

    if (( ${#_help} )); then
        echo "Usage: gget [options]"
        echo ""
        echo "Search GitHub repositories and clone via ghq."
        echo ""
        echo "Options:"
        echo "  -c, --collaborator    Include repositories you are a collaborator on"
        echo "  -o, --org             Include repositories from your organizations"
        echo "  -a, --all             Include all of the above"
        echo "  -e, --exclude-owner   Exclude your own repositories"
        echo "  -h, --help            Show this help message"
        return 0
    fi

    local -a affiliations=()
    (( !${#_exclude_owner} )) && affiliations+=(owner)
    if (( ${#_all} )); then
        affiliations+=(collaborator organization_member)
    else
        (( ${#_collaborator} )) && affiliations+=(collaborator)
        (( ${#_org} ))          && affiliations+=(organization_member)
    fi

    if [[ ${#affiliations[@]} -eq 0 ]]; then
        echo "gget: --exclude-owner requires -c, -o, or -a" >&2
        return 1
    fi

    local affiliation
    affiliation=$(IFS=','; echo "${affiliations[*]}")
    local current_user
    current_user=$(gh api /user --jq '.login')
    local header
    printf -v header "[%s]  \033[36mown\033[0m  \033[33morg\033[0m  \033[32mcollaborator\033[0m" "$affiliation"

    local repo
    repo=$(gh api --paginate "/user/repos?affiliation=${affiliation}&per_page=100" \
        | jq -r --arg user "$current_user" \
            '.[] | if .owner.type == "Organization"
                   then "[33m" + .full_name + "[0m"
                   elif .owner.login == $user
                   then "[36m" + .full_name + "[0m"
                   else "[32m" + .full_name + "[0m"
                   end + " │ " + .full_name' \
        | fzf --ansi --reverse --height 60% \
            --delimiter ' │ ' --with-nth 1 \
            --header "$header" \
            --preview 'gh repo view {2} | bat -l md --color=always --style=plain' \
        | awk -F ' │ ' '{print $2}')

    if [[ -n "$repo" ]]; then
        echo "Cloning $repo via ghq..."
        ghq get "$repo"
        local answer
        echo -n "cd into $repo? [Y/n] "
        read -r answer
        if [[ -z "$answer" || "$answer" = Y || "$answer" = y ]]; then
            cd "$(ghq list -p --exact "$repo")"
        fi
    fi
}
