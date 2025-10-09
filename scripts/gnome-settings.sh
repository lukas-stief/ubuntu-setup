#!/bin/bash

# use four fixed workspaces
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4
gsettings set org.gnome.mutter dynamic-workspaces false
gsettings set org.gnome.mutter workspaces-only-on-primary false

# access workspaces via F-keys
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-1 "['F1']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-2 "['F2']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-3 "['F3']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-4 "['F4']"

# move applications to workspaces via Super+F-keys
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-1 "['<Super>F1']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-2 "['<Super>F2']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-3 "['<Super>F3']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-4 "['<Super>F4']"