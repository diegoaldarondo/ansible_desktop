#!/bin/bash

# Lazydiff - a wrapper for git diff that allows you to view commit diffs 
# for use with Large Language Models to write commit messages and daily notes. 
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

show_diff_for_period() {
    local period="$1"
    git diff "HEAD@{1 $period ago}" HEAD | code -
}

select_commits_with_fzf() {
    local commits=$(git log --pretty=format:"%h - %s" | fzf --multi --no-sort --reverse --tiebreak=index --no-multi --preview "git show --color=always {1}" --preview-window=up:60%:wrap --ansi --phony --query="$q" +m --tac | awk '{print $1}')
    git diff $commits | code -
}

while :; do
    case $1 in
        -h|--help)
            show_help
            exit
            ;;
        -c|--cached)
            git diff --cached | code -
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
git diff | code -