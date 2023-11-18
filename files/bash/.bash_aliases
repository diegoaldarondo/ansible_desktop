
# User specific aliases 
alias oauth="bash ~/Documents/daldarondo-openauth/daldarondo-openauth.sh &"
alias lg="lazygit"
if [ ! -L $HOME/.local/bin/bat ]; then
	ln -s /usr/bin/batcat $HOME/.local/bin/bat
fi

# User specific functions
function sync {
	note sync
	git -C ~/dotfiles pull
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
