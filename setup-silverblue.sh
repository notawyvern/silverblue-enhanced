#!/usr/bin/env bash

set -euo pipefail

# Exits if you are root
if [ "$EUID" -eq 0 ]; then
    echo "WARNING: Do not run this script as root!"
    exit 1
fi

###############################################################################
# GENERAL
###############################################################################

# Disables GNOME donation popup
gsettings set org.gnome.settings-daemon.plugins.housekeeping donation-reminder-enabled false

# Make the windows Windows-like
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'

# Hides Firefox not requiring overlays
mkdir -p ~/.local/share/applications
echo "Hidden=true" > ~/.local/share/applications/org.mozilla.firefox.desktop

cat >> ~/.bashrc <<'EOF'

# vi mode
set -o vi
bind -m vi-insert 'set completion-ignore-case on'
bind -m vi-insert 'Control-l: clear-screen'
bind -m vi-command 'Control-l: clear-screen'

# aliases
alias vim=vi
EOF

###############################################################################
# ELEMENTARY WALLPAPER
###############################################################################

# Odin wallpapers were created by Ryan Gorley featuring the work of Brendon Porter <brendonporter.com>, licensed CC BY-SA 4.0 <creativecommons.org/licenses/by-sa/4.0/>:
# odin <github.com/elementary/wallpapers>
# odin-dark <github.com/elementary/wallpapers>

IMAGES_DIR=$(xdg-user-dir PICTURES)

wget -O $IMAGES_DIR/odin.jpg \
        https://raw.githubusercontent.com/elementary/wallpapers/refs/heads/main/backgrounds/odin.jpg
wget -O $IMAGES_DIR/odin-dark.jpg \
        https://raw.githubusercontent.com/elementary/wallpapers/refs/heads/main/backgrounds/odin-dark.jpg

gsettings set org.gnome.desktop.background picture-uri "file://$IMAGES_DIR/odin.jpg"
gsettings set org.gnome.desktop.background picture-uri-dark "file://$IMAGES_DIR/odin-dark.jpg"

###############################################################################
# FLATPAK
###############################################################################

flatpak remote-add --if-not-exists \
    flathub \
    https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
    app.zen_browser.zen \
    io.freetubeapp.FreeTube \
    org.videolan.VLC \
    rs.ruffle.Ruffle \
    com.protonvpn.www \
    com.vscodium.codium \
    com.spotify.Client \
    com.gopeed.Gopeed

###############################################################################
# DOCK
###############################################################################
gsettings set org.gnome.shell favorite-apps \
"[
'org.gnome.SystemMonitor.desktop',
'org.gnome.Ptyxis.desktop',
'org.gnome.Nautilus.desktop',
'app.zen_browser.zen.desktop',
'org.gnome.Software.desktop'
]"

###############################################################################
# KEYBINDINGS
###############################################################################

# Super+F for Nautilus
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>f']"

# Super+B for Zen Browser
xdg-settings set default-web-browser app.zen_browser.zen.desktop
gsettings set org.gnome.settings-daemon.plugins.media-keys www "['<Super>b']"

# SUPER+T for Ptyxis
TERMINAL_BINDING_PATH=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/

gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
"['$TERMINAL_BINDING_PATH']"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$TERMINAL_BINDING_PATH \
    name 'Terminal'

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$TERMINAL_BINDING_PATH \
    command 'ptyxis --new-window'

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$TERMINAL_BINDING_PATH \
    binding '<Super>t'

###############################################################################
# EXTENSIONS
###############################################################################

GNOME_VERSION=$(gnome-shell --version | grep -oE '[0-9]+' | head -1)

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Downloads and installs the latest extension release
# with extracted metadata and default system tools.
install_extension() {
    local id="$1"

    local json
    json=$(curl -fsSL \
        "https://extensions.gnome.org/extension-info/?pk=$id&shell_version=$GNOME_VERSION")

    local uuid
    uuid=$(jq -r '.uuid' <<<"$json")

    local download
    download=$(jq -r '.download_url' <<<"$json")

    local zip="$TMPDIR/$uuid.zip"

    curl -fsSL \
        "https://extensions.gnome.org$download" \
        -o "$zip"

    gnome-extensions install --force "$zip"

    ENABLED_EXTENSIONS+=("$uuid")
}

install_extension 517 # Caffeine
install_extension 615 # AppIndicator Support
install_extension 3193 # Blur My Shell
install_extension 307 # Dash to Dock

# Parses the variable to enable extensions, one by one
gsettings set org.gnome.shell enabled-extensions \
    "$(printf '%s\n' "${ENABLED_EXTENSIONS[@]}" | jq -R . | jq -sc .)"

# A small pet peeve of mine
gnome-extensions disable background-logo@fedorahosted.org || true

# reboots when it is done
reboot
