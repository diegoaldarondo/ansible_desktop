#!/bin/bash

# Lazycommit - a wrapper for git diff that allows you to view commit diffs 
# so that Large Language Models can help write commit messages and daily notes. 
# Commit diffs are piped to vscode using the `code -` command.

show_help() {
    cat << EOF
Usage: ${0##*/} [options]
  -h, --help            show this help message and exit
  -c, --cached          Show diff for staged changes
  --day                 Show diff for all commits in the last 24 hours
  --week                Show diff for all commits in the last 7 days
  --month               Show diff for all commits in the last 30 days
  -p, --pair            Show diff for two commits (selected interactively with fzf)
EOF
}

prompt() {
    cat - <(echo ----------------) <(echo "Please write a professional, well formatted commit message for this git diff.")
}

show_diff_for_period() {
    local period="$1"
    git diff "HEAD@{1 $period ago}" HEAD | code -
}

select_commits_with_fzf() {
    local commits=$(git log --pretty=format:"%h - %s" | fzf -m --no-sort --reverse --ansi --tiebreak=index --preview "git show --color=always {1}" --preview-window=50% | awk '{print $1}')
    echo "$commits"
    if [[ -z "$commits" ]]; then
        exit
    fi
    if [[ $(echo "$commits" | wc -l) -eq 1 ]]; then
        git diff "$commits"~1 "$commits" | prompt | code -
    else
        git diff $commits | prompt | code -
    fi
}

while :; do
    case $1 in
        -h|--help)
            show_help
            exit
            ;;
        -c|--cached)
            git diff --cached | prompt | code -
            exit
            ;;
        --day)
            show_diff_for_period "day"
            exit
            ;;
        --week)
            show_diff_for_period "week"
            exit
            ;;
        --month)
            show_diff_for_period "month"
            exit
            ;;
        -p|--pair)
            select_commits_with_fzf
            exit
            ;;
        *)
            break
    esac
    shift
done

# Default action if no option is provided
git diff | prompt | code -