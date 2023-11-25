
# User specific aliases 
alias oauth="bash ~/Documents/daldarondo-openauth/daldarondo-openauth.sh &"
alias lg="lazygit"
if [ ! -L $HOME/.local/bin/bat ]; then
	ln -s /usr/bin/batcat $HOME/.local/bin/bat
fi
alias cat="bat"
alias ls="exa"
alias la="exa -la"
alias fd="fdfind"
alias lc="lazycommit"
# Alias for running sgpt with gpt-4 model and temperature .7
alias sg="sgpt --model=gpt-4 --temperature=.7"

# Alias for running interactive sgpt with gpt-4 model, temperature .7 
alias sgc="sgpt --model=gpt-4 --temperature=.7 --repl ' '"

if [ -f $HOME/.secrets ]; then
	source $HOME/.secrets
fi

# User specific functions
function lint {
# Lint a given python file.
#
# Parameters:
# - file: The file or directory to be linted.
#
# Returns:
# - None
#
# Raises:
# - FileNotFoundError: If the specified file or directory does not exist.
# - ValueError: If the specified file or directory is not valid for linting.
#
# Usage:
# - lint <file>
    
	# Check that the file exists and that it is a python file
	if [ -f "$1" ]; then
		# Check if the file extension is .py
		if [[ ! "$1" == *.py ]]; then
			echo "The file exists but is not a python file."
			exit 1
		fi
	else
		echo "The file does not exist."
		exit 1
	fi
	cat $1 <(pylint $1) | sgpt --role=pylint --model=gpt-4 --temperature=.7 | code -d $1 -
}

function o {
	# file=$( (fd -H -t f . ~ ; fd -H -t l . ~) | uniq | fzf --preview 'bat --color=always --theme="OneHalfDark" {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a file: " --pointer="=>")
	file=$( (fd -H --color=always -t f --follow . ~) | fzf --ansi --preview 'bat --color=always --theme="OneHalfDark" {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a file: " --pointer="=>")
	if [ -n "$file" ]; then
		echo "$file"
		code "$file"
	fi
}
function c {
	folder=$(fd -H --color=always -t d . ~ | fzf --ansi --preview 'exa -abghHliS {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a directory: " --pointer="=>")
	if [ -n "$folder" ]; then
		cd "$folder"
	fi
}
function format_daily_diff {
	git diff $(git rev-list -n 1 --before="5 AM" HEAD) HEAD | sgpt --role=format_diff_to_note --model=gpt-4 
}
function rc {
	rm ~/.ssh/daldarondo@login.rc.fas.harvard.edu\:22
	ssh -fN login.rc.fas.harvard.edu
	ssh login.rc.fas.harvard.edu
}
function interactive_cpu {
	ssh login.rc.fas.harvard.edu "tmux new-session -d -s interact 'salloc -p olveczky,shared,test,cox,unrestricted,remoteviz --mem=60000 -t 0-08:00'"
}
function get_compute_hostname {
	node_hostname=$(ssh login.rc.fas.harvard.edu "squeue -au daldarondo | grep interact | awk '{print \$NF}'")
	echo $node_hostname
}
function remote_code {
	hostname=$(get_compute_hostname)
	folder=$(cat ~/.targets | fzf)
	code --folder-uri vscode-remote://ssh-remote+$hostname/$folder
}
function rcode {
	# If get_compute_hostname is empty, then interactive_cpu still needs to be run
	if [ -z "$(get_compute_hostname)" ]; then
		interactive_cpu
		sleep 3s
	fi
	remote_code
}

# PATH additions
export PATH="$PATH:$HOME/miniconda3/bin"
export PATH="$PATH:$HOME/notes"
export PATH="$PATH:$HOME/.local/bin"
