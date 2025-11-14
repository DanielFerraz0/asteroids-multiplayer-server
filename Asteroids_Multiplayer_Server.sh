#!/bin/sh
printf '\033c\033]0;%s\a' Asteroids Multiplayer Server
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Asteroids Multiplayer Server.x86_64" "$@"
