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

# Deployment manager
alias deploy="python /home/diego/code/deploy.py"

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

killtb() {
    kill $(pgrep "tensorboard")
}

ruffcheck() {
    cd ~/code/fauna2
    git diff --name-only main... | grep '\.py$' | xargs -I {} ruff check {} | grep -v '|' | grep '.py'
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

connect_to_biped() {
    code --folder-uri vscode-remote://ssh-remote+biped-nano//home/fauna-it/code/fauna2/projects/biped-deploy
}

connect_to_biped_dev() {
    code --folder-uri vscode-remote://ssh-remote+biped-nano//home/fauna-it/dev/fauna2-diego/projects/biped-deploy
}

connect_to_bleecker() {
    code --folder-uri vscode-remote://ssh-remote+bleecker//ssd/code/fauna2/
}

connect_to_bleecker_dev() {
    code --folder-uri vscode-remote://ssh-remote+bleecker//ssd/dev/fauna2-diego
}

connect_to_astoria() {
    code --folder-uri vscode-remote://ssh-remote+astoria//ssd/code/fauna2/
}

connect_to_astoria_dev() {
    code --folder-uri vscode-remote://ssh-remote+astoria//ssd/dev/fauna2-diego
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

transfer_model () {
    exported_folder=$1
    bot_folder="/home/fauna-it/code/fauna2/projects/biped-deploy/saved_policy/him"
    scp $exported_folder"/policy.pt"  "biped-nano:"$bot_folder
    scp $exported_folder"/settings.json"  "biped-nano:"$bot_folder"/saved/policy/settings.json"
}

transfer_model_dev () {
    exported_folder=$1"/exported_ckpts"
    bot_folder="/home/fauna-it/dev/fauna2-diego/projects/biped-deploy/saved_policy/him"
    scp $exported_folder"/policy.pt"  "biped-nano:"$bot_folder
    scp $exported_folder"/settings.json"  "biped-nano:"$bot_folder"/saved/policy/settings.json"
}

open_tb () {
    killtb
    exp_dir="/mnt/nas_mnt/sim-experiments/diego/"
    
    # Use fzf to select multiple directories interactively
    selected_dirs=$(ls $exp_dir | fzf --multi --bind 'ctrl-a:select-all' --prompt="Select experiment directories: ")
    
    # Check if any directories were selected
    if [[ -z "$selected_dirs" ]]; then
        echo "No directories selected. Exiting."
        return 1
    fi
    
    # Construct the TensorBoard logdir_spec argument
    logdir_spec=""
    for dir in $selected_dirs; do
        logdir_name=$(basename $dir) # Use directory name as label
        logdir_spec+="${logdir_name}:${exp_dir}${dir},"
    done
    
    # Remove the trailing comma
    logdir_spec=${logdir_spec%,}

    echo "Starting TensorBoard with logdir_spec: $logdir_spec"

    # Start TensorBoard with logdir_spec
    tensorboard --logdir_spec $logdir_spec --bind_all --load_fast=false
}

exp_folder () {
    exp_dir="/mnt/nas_mnt/sim-experiments/diego/"

    # Use fzf to select multiple directories interactively
    selected_group=$(ls $exp_dir | fzf --prompt="Select group: ")

    selected_exp=$(ls $exp_dir/$selected_group | fzf --prompt="Select experiment: ")

    echo "${exp_dir}${selected_group}/${selected_exp}"
}

sync_logs_to_nas() {
    # Define source and destination directories
    local source_dir="$HOME/code/fauna2/projects/biped-skills/logs/"
    local dest_dir="/mnt/nas_mnt/sim-experiments/diego/"

    # Log file for rsync output and errors
    local log_file="/var/tmp/sync_logs_to_nas.log"

    echo "Starting rsync operation at $(date)" >> "$log_file"

    # Run rsync with appropriate options
    rsync -avh --progress --no-g --no-times --no-perms --no-xattrs --checksum \
            --exclude 'model_*.pt' "$source_dir" "$dest_dir" 2>> "$log_file"

    # Check exit status of rsync
    if [[ $? -eq 0 ]]; then
        echo "Rsync operation completed successfully at $(date)" >> "$log_file"
    else
        echo "Rsync operation failed at $(date). Check the log file for details: $log_file" >&2
    fi

    # Sync the most recent model_X.pt files only
    local file_list="/var/tmp/sync_logs_to_nas_files.txt"

    # Create or clear the file list
    > "$file_list"

    # Iterate over each experiment directory
    find "$source_dir" -mindepth 2 -maxdepth 2 -type d | while read -r experiment_dir; do
        echo "Processing experiment directory: $experiment_dir" >> "$log_file"

        # Find the largest model_X.pt file in the current experiment directory
        local largest_model=$(ls "$experiment_dir"/model_*.pt 2>/dev/null | sed -E 's/.*model_([0-9]+)\.pt/\1/' | sort -n | tail -1)

        if [[ -z "$largest_model" ]]; then
            echo "No model_X.pt files found in $experiment_dir" >> "$log_file"
        else
            # Construct the relative path of the largest model file
            local model_file="${experiment_dir#$source_dir}/model_${largest_model}.pt"
            echo "Adding largest model file to list: $model_file" >> "$log_file"

            # Add the largest model file to the file list
            echo "$model_file" >> "$file_list"
        fi
    done
    /usr/bin/cat "$file_list"
    rsync -avh --progress --no-g --no-times --no-perms --no-xattrs --checksum \
        --files-from="$file_list" "$source_dir" "$dest_dir" 2>> "$log_file"

    # Check exit status of rsync
    if [[ $? -eq 0 ]]; then
        echo "Rsync operation completed successfully at $(date)" >> "$log_file"
    else
        echo "Rsync operation failed at $(date). Check the log file for details: $log_file" >&2
    fi
}

sync_logs_to_remote_nas() {
    # Check for hostname argument
    if [[ -z "$1" ]]; then
        echo "Usage: sync_logs_to_remote_nas <hostname>"
        return 1
    fi

    local hostname="$1"
    local remote_command="$(declare -f sync_logs_to_nas); sync_logs_to_nas"

    echo "Starting remote rsync operation on $hostname"

    ssh "$hostname" "bash -s" <<< "$remote_command"

    if [[ $? -eq 0 ]]; then
        echo "Remote rsync operation on $hostname completed successfully."
    else
        echo "Remote rsync operation on $hostname failed."
    fi
}

synclogs() {
    sync_logs_to_remote_nas xps2
    sync_logs_to_remote_nas xps3
    sync_logs_to_nas
}

test_single() {
    python tests/test_configs.py --config $(find configs | fzf)
}

# PATH additions
export PATH="$PATH:$HOME/miniconda3/bin"
export PATH="$PATH:$HOME/notes"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:/home/diego/code/fauna2/projects/isaaclab-him/OpenUSD/bin"
export PYTHONPATH="/home/diego/code/fauna2/projects/isaaclab-him/OpenUSD/lib/python:$PYTHONPATH"
