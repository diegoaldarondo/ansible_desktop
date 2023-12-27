# User specific aliases 
alias oauth="bash ~/Documents/daldarondo-openauth/daldarondo-openauth.sh &"
alias lg="lazygit"
alias cat="bat"
alias ls="exa"
alias la="exa -la"
alias fd="fdfind"
alias lc="lazycommit"
alias gpt="sgpt --model=gpt-4 --temperature=.7"
alias gpti="sgpt --model=gpt-4 --temperature=.7 --repl ' '"
alias task="python $HOME/notes/tasks/tasks.py"
alias tasks="python $HOME/notes/tasks/tasks.py"
alias random_task='grep "\[ \]" ~/notes/tasks/tasks.md | shuf -n 1 '
alias n="note"
alias ns="note sync"
alias nf="note find"
alias nfc="note find_contents"
alias ni="note improve"
alias nt="note tomorrow"
alias ny="note yesterday"
alias d="bash ~/notes/dash"
alias mems="python $HOME/notes/memory/memory.py store"
alias memr="python $HOME/notes/memory/memory.py recall"
alias memu="python $HOME/notes/memory/memory.py update"
alias memf="python $HOME/notes/memory/memory.py forget"
alias meme="python $HOME/notes/memory/memory.py edit"
alias daily="python $HOME/notes/tasks/daily.py"
alias gc="gcalcli agenda"
alias gcw="gcalcli calw"
alias gcm="gcalcli calm"

# Miscellaneous
[ ! -L "$HOME/.local/bin/bat" ] && ln -s /usr/bin/batcat "$HOME/.local/bin/bat"
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

# User specific functions
format() {
    black "$1"
    isort "$1"
    autoflake --remove-all-unused-imports --in-place "$1"
}

add_docstring() {
    cat "$1" | sgpt --role=docstring --model=gpt-4 --temperature=.7 | code -d "$1" -
}

add_type_hints() {
    cat "$1" | sgpt --role=typehint --model=gpt-4 --temperature=.7 | code -d "$1" -
}

lint() {
    cat "$1" <(pylint "$1") | sgpt --role=pylint --model=gpt-4 --temperature=.7 | code -d "$1" -
}

improve_code() {
    cat "$1" | sgpt --role=improve_code --model=gpt-4 --temperature=.7 | code -d "$1" -
}

write_unit_tests() {
    cat <(echo "Filename: $1"\n) "$1" | sgpt --role=UnitTestWriter --model=gpt-4 --temperature=.7 | code -
}

develop() {
    if [ -z "$2" ]; then
        read -p "Enter a description of the change: " description
        [ -z "$description" ] && echo "No description provided." && return
    else
        description="$2"
    fi

    cat "$1" | sgpt --role=developer --model=gpt-4 --temperature=.7 "$description" | code -d - "$1"
}

check_install() {
    # Check if all of the required command line tools are installed
    required_tools=("black" "isort" "autoflake" "sgpt" "code" "fdfind" "fzf" "bat" "pylint")

    for tool in "${required_tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            echo "Error: $tool is not installed." >&2
            exit 1
        fi
    done
}

general_gpt() {
	if [ -z "$2" ]; then
        read -p "Enter prompt: " description
        [ -z "$prompt" ] && echo "No prompt provided." && return
    else
        prompt="$2"
    fi	
	
	cat "$1" | sgpt --model=gpt-4 --temperature=.7 "$prompt" | code -
}

pyedit() {
    check_install
    local file

    if [ ! -f "$1" ]; then
        file=$(fdfind -H --color=always -t f --follow . ~ | fzf --ansi --preview 'bat --color=always --theme="OneHalfDark" {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a file: " --pointer="=>")
    else
        file="$1"
    fi

    [ -z "$file" ] && echo "No file selected." && return

    options=("Format" "Docstrings" "Develop" "Type Hints" "Lint" "Improve Code" "Write Unit Tests" "General" "Quit")
    while true; do
        opt=$(printf '%s\n' "${options[@]}" | fzf --prompt="Select an action: " --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --pointer="=>")

        case $opt in
            "Format") format "$file" ;;
            "Docstrings") add_docstring "$file" ;;
            "Type Hints") add_type_hints "$file" ;;
            "Lint") lint "$file" ;;
            "Improve Code") improve_code "$file" ;;
            "Write Unit Tests") write_unit_tests "$file" ;;
            "Develop") develop "$file" ;;
			"General") general_gpt "$file" ;;
            "Quit") break ;;
            *) break ;;
        esac
    done
}

sync () {
	git -C ~/notes pull
	git -C ~/ansible_desktop pull
}

ff () {
	link=$(python $HOME/notes/memory/memory.py recall)
	if [ -z "$link" ]; then
		echo "No link found."
	else
		firefox "$link" &> /dev/null &
	fi
}

format_daily_log() {
	if [ -z "$1" ]; then
		git log --since-as-filter="yesterday 23:59" | sgpt --role=format_diff_to_note --model=gpt-4 --temperature=.7 | code -
	else
		git log --since-as-filter="$1 days ago 23:59" | sgpt --role=format_diff_to_note --model=gpt-4 --temperature=.7 | code -
	fi
}

o() {
	local file=$(fdfind -H --color=always -t f --follow . ~ | fzf --ansi --preview 'bat --color=always --theme="OneHalfDark" {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a file: " --pointer="=>")
	[ -n "$file" ] && code "$file"
}

c() {
	local folder=$(fdfind -H --color=always -t d . ~ | fzf --ansi --preview 'exa -abghHliS {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a directory: " --pointer="=>")
	[ -n "$folder" ] && cd "$folder"
}

rc() {
	rm ~/.ssh/daldarondo@login.rc.fas.harvard.edu\:22
	ssh -fN login.rc.fas.harvard.edu
	ssh login.rc.fas.harvard.edu
}

interactive_cpu() {
	ssh login.rc.fas.harvard.edu "tmux new-session -d -s interact 'salloc -p olveczky,shared,test,cox,unrestricted,remoteviz --mem=60000 -t 0-08:00'"
}

get_compute_hostname() {
	local node_hostname=$(ssh login.rc.fas.harvard.edu "squeue -au daldarondo | grep interact | awk '{print \$NF}'")
	echo $node_hostname
}

remote_code() {
	local hostname=$(get_compute_hostname)
	local folder=$(cat ~/.targets | fzf)
	code --folder-uri vscode-remote://ssh-remote+$hostname/$folder
}

rcode() {
	[ -z "$(get_compute_hostname)" ] && interactive_cpu && sleep 3s
	remote_code
}

# PATH additions
export PATH="$PATH:$HOME/miniconda3/bin"
export PATH="$PATH:$HOME/notes"
export PATH="$PATH:$HOME/.local/bin"
