#!/bin/bash
# autoedit - A CLI tool for modifying code with LLMs.

declare _MODEL=gpt-4-1106-preview
declare _TEMPERATURE=.7
declare _GPT_PARAMS="--model=$_MODEL --temperature=$_TEMPERATURE"

# Performs an automatic code review on a given file using the sgpt CLI tool.
# Globals:
#   _GPT_PARAMS - Parameters to be passed to the sgpt tool.
# Arguments:
#   file - The file to be reviewed.
# Outputs:
#   The output of the code review process or an error if the file does not exist.
auto_code_review() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "Error: File does not exist."
        return
    fi

    sgpt --role=code_review $_GPT_PARAMS <"$file" | code -
}

# Formats a given file based on its filetype using appropriate formatting tools.
# Globals:
#   None
# Arguments:
#   $1 - The file to be formatted.
# Outputs:
#   The formatted file.
auto_format() {
    local filetype
    filetype=$(file --mime-type -b "$1")

    case $filetype in
        "text/x-python")
            black "$1"
            isort "$1"
            autoflake --remove-all-unused-imports --in-place "$1"
            ;;
        "text/x-shellscript")
            shfmt -i 4 -ci -s -w "$1"
            ;;
    esac
}

# Automatically adds docstrings to a given file based on its filetype using the sgpt CLI tool.
# Globals:
#   _GPT_PARAMS - Parameters to be passed to the sgpt tool.
# Arguments:
#   $1 - The file to which docstrings will be added.
# Outputs:
#   The file with added docstrings.
auto_docstring() {
    local filetype
    filetype=$(file --mime-type -b "$1")

    case $filetype in
        "text/x-python")
            sgpt --role=docstring $_GPT_PARAMS <"$1" | code -d "$1" -
            ;;
        "text/x-shellscript")
            sgpt --role=shellcomment $_GPT_PARAMS <"$1" | code -d "$1" -
            ;;
    esac
}

# Automatically adds type hints to a given Python file using the sgpt CLI tool.
# Globals:
#   _GPT_PARAMS - Parameters to be passed to the sgpt tool.
# Arguments:
#   $1 - The Python file to which type hints will be added.
# Outputs:
#   The Python file with added type hints.
auto_type_hints() {
    sgpt --role=typehint $_GPT_PARAMS <"$1" | code -d "$1" -
}

# Automatically lints a given file based on its filetype using sgpt and appropriate linting tools.
# Globals:
#   _GPT_PARAMS - Parameters to be passed to the sgpt tool.
# Arguments:
#   $1 - The file to be linted.
# Outputs:
#   The output of the linting process.
auto_lint() {
    local filetype
    filetype=$(file --mime-type -b "$1")

    case $filetype in
        "text/x-python")
            pylint "$1" | sgpt --role=pylint $_GPT_PARAMS | code -d "$1" -
            ;;
        "text/x-shellscript")
            shellcheck -f gcc "$1" | sgpt --role=shellcheck $_GPT_PARAMS | code -d "$1" -
            ;;
    esac
}

# Automatically improves code quality of a given file using the sgpt CLI tool.
# Globals:
#   _GPT_PARAMS - Parameters to be passed to the sgpt tool.
# Arguments:
#   $1 - The file whose code will be improved.
# Outputs:
#   The file with improved code.
auto_improve_code() {
    sgpt --role=improve_code $_GPT_PARAMS <"$1" | code -d "$1" -
}

# Automatically writes unit tests for a given file using the sgpt CLI tool.
# Globals:
#   _GPT_PARAMS - Parameters to be passed to the sgpt tool.
# Arguments:
#   $1 - The file for which unit tests will be written.
# Outputs:
#   The unit tests for the file.
auto_write_unit_tests() {
    {
        echo "Filename: $1"
        cat "$1"
    } | sgpt --role=UnitTestWriter $_GPT_PARAMS | code -
}

# Assists in the development process of a file by applying changes as described in a given description using the sgpt CLI tool.
# Globals:
#   _GPT_PARAMS - Parameters to be passed to the sgpt tool.
# Arguments:
#   $1 - The file to be developed.
#   $2 - The description of the change to be made.
# Outputs:
#   The developed file.
auto_develop() {
    local description
    description="$2"

    if [[ -z "$description" ]]; then
        read -r -p "Enter a description of the change: " description
        [[ -z "$description" ]] && echo "No description provided." && return
    fi

    sgpt --role=developer $_GPT_PARAMS "$description" <"$1" | code -d - "$1"
}

# Interactively prompts the user for a custom prompt to be processed by the sgpt CLI tool for a given file.
# Globals:
#   _GPT_PARAMS - Parameters to be passed to the sgpt tool.
# Arguments:
#   $1 - The file to be processed.
#   $2 - The custom prompt to be processed.
# Outputs:
#   The output of the sgpt tool for the given prompt.
auto_gpt() {
    local prompt
    prompt="$2"

    if [[ -z "$prompt" ]]; then
        read -r -p "Enter prompt: " prompt
        [[ -z "$prompt" ]] && echo "No prompt provided." && return
    fi
    sgpt $_GPT_PARAMS "$prompt" <"$1" | code -
}

# Checks if all required command line tools are installed before proceeding with the autoedit function.
# Globals:
#   None
# Arguments:
#   None
# Outputs:
#   Error messages if a required tool is not installed, otherwise nothing.
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

# The main function of the edit CLI tool that orchestrates all the auto_* functions and provides a user interface for selecting files and actions.
# Globals:
#   None
# Arguments:
#   $1 - The file to be edited. If not specified, the user is prompted to select a file.
# Outputs:
#   Various outputs based on the selected action for the given file.
autoedit() {
    check_installation
    local file="$1"

    if [[ ! -f "$file" ]]; then
        file=$(fdfind -H --color=always -t f --follow . ~ | fzf --ansi --preview 'bat --color=always --theme="OneHalfDark" {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a file: " --pointer="=>")
    fi

    [[ -z "$file" ]] && echo "No file selected." && return

    local options=("Format" "Docstrings" "Develop" "Type Hints" "Lint" "Improve Code" "Write Unit Tests" "General" "Code Review" "Quit")
    while true; do
        local opt
        opt=$(printf '%s\n' "${options[@]}" | fzf --prompt="Select an action: " --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --pointer="=>")

        case "$opt" in
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
