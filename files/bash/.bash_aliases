#!/bin/bash
# User specific aliases
alias oauth="bash ~/Documents/daldarondo-openauth/daldarondo-openauth.sh &"
alias lg="lazygit"
alias cat="bat"
alias ls="exa"
alias la="exa -la"
alias fd="fdfind"
alias nvim="~/nvim-linux64/bin/nvim"
alias upg="sudo apt update && sudo apt upgrade -y"

# ChatGPT
alias gpt="sgpt --temperature=.7"
alias gpti="sgpt --temperature=.7 --repl ' '"

# Notes
alias n="note"
alias ns="note sync"
alias nf="note find"
alias nfc="note find_contents"
alias ni="note improve"
alias nt="note tomorrow"
alias ny="note yesterday"

# Memory
alias mems="python $HOME/notes/memory/memory.py store"
alias memr="python $HOME/notes/memory/memory.py recall"
alias memu="python $HOME/notes/memory/memory.py update"
alias memf="python $HOME/notes/memory/memory.py forget"
alias meme="python $HOME/notes/memory/memory.py edit"

# Task manager
alias task="python $HOME/notes/tasks/tasks.py"
alias tasks="python $HOME/notes/tasks/tasks.py"
alias daily="python $HOME/notes/tasks/daily.py"

# Change directory aliases
alias home='cd ~'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Cpu usage
alias cpu="grep 'cpu ' /proc/stat | awk '{usage=(\$2+\$4)*100/(\$2+\$4+\$5)} END {print usage}' | awk '{printf(\"%.1f\n\", \$1)}'"

# Miscellaneous
[ ! -L "$HOME/.local/bin/bat" ] && ln -s /usr/bin/batcat "$HOME/.local/bin/bat"
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"
[ -f "$HOME/ansible_desktop/files/scripts/autoedit.sh" ] && source "$HOME/ansible_desktop/files/scripts/autoedit.sh"
[ -f "$HOME/.xinitrc" ] && source "$HOME/.xinitrc"

# User specific functions
sync() {
    git -C ~/notes pull
    git -C ~/ansible_desktop pull
}

ff() {
    link=$(python $HOME/notes/memory/memory.py recall)
    if [ -z "$link" ]; then
        echo "No link found."
    else
        firefox "$link" &>/dev/null &
    fi
}

format_daily_log() {
    if [ -z "$1" ]; then
        git log --since-as-filter="yesterday 23:59" | sgpt --role=format_diff_to_note --temperature=.7 | code -
    else
        git log --since-as-filter="$1 days ago 23:59" | sgpt --role=format_diff_to_note --temperature=.7 | code -
    fi
}

r() {
	result=$(rg --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --color "always" -g '!{.git,node_modules,vendor}/*' "" | fzf --ansi --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Seach: " --pointer="=>")
    file=$(echo "$result" | awk -F ':' '{print $1}')
    line=$(echo "$result" | awk -F ':' '{print $2}')
    [ -n "$file" ] && code --goto "./$file:$line"
}

O() {
    fdfind -H --color=always -t f --follow . ~ | fzf --ansi --preview 'bat --color=always --theme="OneHalfDark" {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a file: " --pointer="=>"
}

o() {
    local file=$(O)
    [ -n "$file" ] && code "$file"
}

C() {
    fdfind -H --color=always -t d . ~ | fzf --ansi --preview 'exa -abghHliS {}' --preview-window=right:50%,border-rounded --layout=reverse --border=rounded --margin=0 --padding=1 --color=dark --prompt="Select a directory: " --pointer="=>"
}

c() {
    local folder=$(C)
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

act() {
    # Function to get a list of conda environments
    get_conda_envs() {
        conda env list | grep -v "#" | awk '{print $1}' 
    }

    # Select environment using fzf
    selected_env=$(get_conda_envs | fzf --height 10 --prompt "Select Conda Environment: ")

    # Check if an environment was selected
    if [ -n "$selected_env" ]; then
        # Deactivate any active environment
        conda deactivate > /dev/null 2>&1

        # Activate the selected environment
        source activate "$selected_env"
    else
        echo "No environment selected."
    fi
}

# Extracts any archive(s) (if unp isn't installed)
extract () {
	for archive in $*; do
		if [ -f $archive ] ; then
			case $archive in
				*.tar.bz2)   tar xvjf $archive    ;;
				*.tar.gz)    tar xvzf $archive    ;;
				*.bz2)       bunzip2 $archive     ;;
				*.rar)       rar x $archive       ;;
				*.gz)        gunzip $archive      ;;
				*.tar)       tar xvf $archive     ;;
				*.tbz2)      tar xvjf $archive    ;;
				*.tgz)       tar xvzf $archive    ;;
				*.zip)       unzip $archive       ;;
				*.Z)         uncompress $archive  ;;
				*.7z)        7z x $archive        ;;
				*)           echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}
# PATH additions
export PATH="$PATH:$HOME/miniconda3/bin"
export PATH="$PATH:$HOME/notes"
export PATH="$PATH:$HOME/.local/bin"
