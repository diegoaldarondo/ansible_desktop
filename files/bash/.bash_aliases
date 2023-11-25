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

# Miscellaneous
[ ! -L "$HOME/.local/bin/bat" ] && ln -s /usr/bin/batcat "$HOME/.local/bin/bat"
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

# User specific functions
lint() {
	if [ -f "$1" ] && [[ "$1" == *.py ]]; then
		cat "$1" <(pylint "$1") | sgpt --role=pylint --model=gpt-4 --temperature=.7 | code -d "$1" -
	else
		echo "The file does not exist or is not a python file."
		exit 1
	fi
}

improve_code() {
	if [ -f "$1" ]; then
		cat "$1" | sgpt --role=improve_code --model=gpt-4 --temperature=.7 | code -d "$1" -
	else
		echo "The file does not exist."
		exit 1
	fi
}

o() {
	local file=$(fd -H --color=always -t f --follow . ~ | fzf --ansi --preview 'bat --color=always --theme="OneHalfDark" {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a file: " --pointer="=>")
	[ -n "$file" ] && code "$file"
}

c() {
	local folder=$(fd -H --color=always -t d . ~ | fzf --ansi --preview 'exa -abghHliS {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a directory: " --pointer="=>")
	[ -n "$folder" ] && cd "$folder"
}

format_daily_diff() {
	git diff $(git rev-list -n 1 --before="5 AM" HEAD) HEAD | sgpt --role=format_diff_to_note --model=gpt-4 
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
