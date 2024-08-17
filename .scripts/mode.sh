#!/bin/bash
# Script Name: mode.sh
# Description:
# This script manages the startup and shutdown of services related to 
# development and normal modes for the Yabai window manager and the SKHD 
# hotkey daemon.
# 
# Usage:
#   mode dev    - Switches to development mode. Starts the Yabai and SKHD
#                 services if they are not already running.
#   mode normal - Switches to normal mode. Stops the Yabai and SKHD services
#                 if they are running.
# 
# Dependencies:
#   - yabai: A tiling window manager for macOS.
#   - skhd: A simple hotkey daemon for macOS.
# 
# Notes:
#   - Ensure that both yabai and skhd are installed and accessible from
#     your PATH.
#   - This script assumes that `yabai` and `skhd` commands are available 
#     and properly configured.
# 
# Author: [Nopnapat Norasri]

mode() {
    case "$1" in
        dev)
            echo "Running mode dev..."

            # Check if yabai is already running using ps
            if pgrep -x "yabai" > /dev/null; then
                echo "Yabai service is already running."
            else
                echo "Starting yabai service..."
                yabai --start-service
            fi

            # Check if skhd is already running
            if pgrep -x "skhd" > /dev/null; then
                echo "skhd service is already running."
            else
                echo "Starting skhd service..."
                skhd --start-service
            fi

            echo "Mode dev and services started successfully."
            ;;
        normal)
            echo "Running mode normal..."

            # Check if yabai is running before attempting to stop it
            if pgrep -x "yabai" > /dev/null; then
                echo "Stopping yabai service..."
                yabai --stop-service
            else
                echo "Yabai service is not running."
            fi

            # Check if skhd is running before attempting to stop it
            if pgrep -x "skhd" > /dev/null; then
                echo "Stopping skhd service..."
                skhd --stop-service
            else
                echo "skhd service is not running."
            fi

            echo "Mode normal and services stopped successfully."
            ;;
        *)
            echo "Usage: mode {dev|normal}"
            ;;
    esac
}
