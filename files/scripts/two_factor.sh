#!/bin/bash

VERBOSE=0

if [[ "$1" == "-v" ]] || [[ "$1" == "--verbose" ]]; then
    VERBOSE=1
    shift
fi

log() {
    if [[ $VERBOSE -eq 1 ]]; then
        echo "$@"
    fi
}

# Check if JAuth.jar is running using jps
if ! jps -l | grep '/home/diego/daldarondo-openauth/JAuth.jar' > /dev/null; then
    log "JAuth.jar is not running. Launching it..."
    sh /home/diego/daldarondo-openauth/daldarondo-openauth.sh &
    sleep 3.5 # wait for 3.5 seconds, assume the application takes some time to launch
else
    log "JAuth.jar is already running."
fi

# Get the currently focused window's id
ORIGINAL_WINDOW=$(xdotool getwindowfocus)
log "Original window in focus: $ORIGINAL_WINDOW"

# Record the current mouse position
ORIG_MOUSE_POS=$(xdotool getmouselocation --shell)
ORIG_MOUSE_X=$(echo "$ORIG_MOUSE_POS" | grep X= | cut -d= -f2)
ORIG_MOUSE_Y=$(echo "$ORIG_MOUSE_POS" | grep Y= | cut -d= -f2)
log "Original mouse position - X: $ORIG_MOUSE_X, Y: $ORIG_MOUSE_Y"

# Get the PID of JAuth.jar
PID=$(jps -l | grep '/home/diego/daldarondo-openauth/JAuth.jar' | awk '{print $1}')
log "JAuth.jar PID: $PID"

# Find the window ID associated with the PID
WINDOW_ID=$(xdotool search --pid "$PID" | head -1)
log "JAuth.jar window ID: $WINDOW_ID"

# Bring JAuth.jar window to focus
xdotool windowactivate $WINDOW_ID

# Set coordinates for the click to the provided values
X=152
Y=20
log "X: $X, Y: $Y"

# Perform the click
xdotool mousemove --window $WINDOW_ID $X $Y click 1
log "Clicked at coordinates X: $X, Y: $Y"

# Bring the original window back into focus
xdotool windowactivate $ORIGINAL_WINDOW
log "Restored focus to original window"

# Return the mouse to its original position
xdotool mousemove $ORIG_MOUSE_X $ORIG_MOUSE_Y
log "Mouse returned to original position - X: $ORIG_MOUSE_X, Y: $ORIG_MOUSE_Y"
