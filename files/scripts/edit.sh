#!/bin/bash
# edit - A CLI tool for modifying code with LLMs.

declare _MODEL=gpt-4-1106-preview
declare _TEMPERATURE=.7
declare _GPT_PARAMS="--model=$_MODEL --temperature=$_TEMPERATURE"

auto_code_review() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "Error: File does not exist."
        return
    fi

    sgpt --role=code_review $_GPT_PARAMS <"$file" | code -
}

auto_format() {
    local filetype
    filetype=$(file --mime-type -b "$1")

    if [[ $filetype == "text/x-python" ]]; then
        black "$1"
        isort "$1"
        autoflake --remove-all-unused-imports --in-place "$1"
    elif [[ $filetype == "text/x-shellscript" ]]; then
        shfmt -i 4 -ci -s -w "$1"
    fi
}

auto_docstring() {
    sgpt --role=docstring $_GPT_PARAMS <"$1" | code -d "$1" -
}

auto_type_hints() {
    sgpt --role=typehint $_GPT_PARAMS <"$1" | code -d "$1" -
}

auto_lint() {
    local filetype
    filetype=$(file --mime-type -b "$1")

    if [[ $filetype == "text/x-python" ]]; then
        cat "$1" <(pylint "$1") | sgpt --role=pylint $_GPT_PARAMS | code -d "$1" -
    elif [[ $filetype == "text/x-shellscript" ]]; then
        cat "$1" <(shellcheck -f gcc "$1") | sgpt --role=shellcheck $_GPT_PARAMS | code -d "$1" -
    fi
}

auto_improve_code() {
    sgpt --role=improve_code $_GPT_PARAMS <"$1" | code -d "$1" -
}

auto_write_unit_tests() {
    {
        echo "Filename: $1"
        cat "$1"
    } | sgpt --role=UnitTestWriter $_GPT_PARAMS | code -
}

auto_develop() {
    local description
    description="$2"

    if [ -z "$description" ]; then
        read -r -p "Enter a description of the change: " description
        [ -z "$description" ] && echo "No description provided." && return
    fi

    sgpt --role=developer $_GPT_PARAMS "$description" <"$1" | code -d - "$1"
}

auto_gpt() {
    local prompt
    prompt="$2"

    if [ -z "$prompt" ]; then
        read -r -p "Enter prompt: " prompt
        [ -z "$prompt" ] && echo "No prompt provided." && return
    fi

    sgpt $_GPT_PARAMS "$prompt" <"$1" | code -
}

check_installation() {
    # Check if all of the required command line tools are installed
    local required_tools=("black" "isort" "autoflake" "sgpt" "code" "fdfind" "fzf" "bat" "pylint")

    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            echo "Error: $tool is not installed." >&2
            exit 1
        fi
    done
}

autoedit() {
    check_installation
    local file="$1"

    if [ ! -f "$file" ]; then
        file=$(fdfind -H --color=always -t f --follow . ~ | fzf --ansi --preview 'bat --color=always --theme="OneHalfDark" {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a file: " --pointer="=>")
    fi

    [ -z "$file" ] && echo "No file selected." && return

    local options=("Format" "Docstrings" "Develop" "Type Hints" "Lint" "Improve Code" "Write Unit Tests" "General" "Code Review" "Quit")
    while true; do
        local opt
        opt=$(printf '%s\n' "${options[@]}" | fzf --prompt="Select an action: " --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --pointer="=>")

        case $opt in
            "Format") auto_format "$file" ;;
            "Docstrings") auto_docstring "$file" ;;
            "Type Hints") auto_type_hints "$file" ;;
            "Lint") auto_lint "$file" ;;
            "Improve Code") auto_improve_code "$file" ;;
            "Write Unit Tests") auto_write_unit_tests "$file" ;;
            "Develop") auto_develop "$file" ;;
            "General") auto_gpt "$file" ;;
            "Code Review") auto_code_review "$file" ;;
            "Quit") break ;;
            *) break ;;
        esac
    done
}
