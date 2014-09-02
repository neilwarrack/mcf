#!/bin/bash

# Install solarized palette using the script from the
# 'gnome-terminal-colors-solarized' submodule
bash $HOME/.mcf/misc/gnome-terminal-colors-solarized/install.sh -s dark -p Default

# Set custom font
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_system_font" --type boolean "false"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/font" --type string "FantasqueSansMono 11"

# Set 1024 lines (just in case) and unlimited scrolling
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/scrollback_lines" --type integer "1024"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/scrollback_unlimited" --type bool "true"
