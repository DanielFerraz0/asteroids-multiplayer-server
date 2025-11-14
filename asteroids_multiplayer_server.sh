#!/bin/sh
printf '\033c\033]0;%s\a' Asteroids Multiplayer Server
base_path="$(dirname "$(realpath "$0")")"
"$base_path/asteroids_multiplayer_server.x86_64" "$@"
