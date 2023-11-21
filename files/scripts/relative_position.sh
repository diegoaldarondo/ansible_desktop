#!/bin/bash

echo "======= Getting Absolute Mouse Position ======="
MOUSE_POSITION=$(xdotool getmouselocation --shell)
MOUSE_X=$(echo "$MOUSE_POSITION" | grep X= | cut -d= -f2)
MOUSE_Y=$(echo "$MOUSE_POSITION" | grep Y= | cut -d= -f2)

echo "Absolute Mouse X: $MOUSE_X"
echo "Absolute Mouse Y: $MOUSE_Y"

echo "======= Identifying Window under Mouse ======="
WINDOW_ID=$(xdotool getmouselocation --shell | grep WINDOW | cut -d= -f2)
echo "Window ID: $WINDOW_ID"

echo "======= Getting Window's Absolute Position using xwininfo ======="
WINDOW_INFO=$(xwininfo -id $WINDOW_ID)
WINDOW_X=$(echo "$WINDOW_INFO" | grep "Absolute upper-left X:" | awk '{print $4}')
WINDOW_Y=$(echo "$WINDOW_INFO" | grep "Absolute upper-left Y:" | awk '{print $4}')

echo "Window's Absolute X: $WINDOW_X"
echo "Window's Absolute Y: $WINDOW_Y"

echo "======= Calculating Relative Mouse Position ======="
RELATIVE_X=$((MOUSE_X - WINDOW_X))
RELATIVE_Y=$((MOUSE_Y - WINDOW_Y))

echo "Relative X: $RELATIVE_X"
echo "Relative Y: $RELATIVE_Y"
