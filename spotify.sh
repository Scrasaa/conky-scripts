#!/bin/bash

# scrasa
# Script to retrieve and display current song information from Spotify

# Function to get metadata using dbus-send
get_metadata() {
    dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'
}

# Get player status using playerctl
PCTL_STATUS=$(playerctl status 2>/dev/null)

# Extract metadata
metadata=$(get_metadata)

# Function to parse metadata
parse_metadata() {
    local key=$1
    echo "$metadata" | grep -E -A 1 "$key" | grep -E "^\s*variant" | cut -b 44- | sed 's/"$//'
}

# Function to parse artist (array type) metadata
parse_artist() { 
	echo "$metadata" | grep -A 2 "xesam:artist" | grep -E "string" | awk -F '"' '{print $2}' 
}

# Retrieve album, artist, and title
album=$(parse_metadata "album")
artist=$(parse_artist)
title=$(parse_metadata "title")
status=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus' | tail -1 | cut -d "\"" -f2)

# Display information
echo "Artist: $artist"
echo "Album: $album"
echo "Title: $title"
echo "Status: $status"

exit 0
