
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

# User specific functions
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
