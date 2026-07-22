#!/usr/bin/env bash

# Backup destination
BACKUP_DIR="$HOME/config-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating backup in: $BACKUP_DIR"

# Backup i3 config
if [ -d "$HOME/.config/i3" ]; then
    echo "Backing up i3..."
    cp -r "$HOME/.config/i3" "$BACKUP_DIR/"
fi

# Backup rofi config
if [ -d "$HOME/.config/rofi" ]; then
    echo "Backing up rofi..."
    cp -r "$HOME/.config/rofi" "$BACKUP_DIR/"
fi

# Backup picom config
if [ -d "$HOME/.config/picom" ]; then
    echo "Backing up picom..."
    cp -r "$HOME/.config/picom" "$BACKUP_DIR/"
fi

# Backup conky config
if [ -d "$HOME/.config/conky" ]; then
    echo "Backing up conky..."
    cp -r "$HOME/.config/conky" "$BACKUP_DIR/"
fi

# Backup polybar (from /etc)
if [ -d "/etc/polybar" ]; then
    echo "Backing up polybar (requires sudo)..."
    sudo cp -r /etc/polybar "$BACKUP_DIR/"
fi

# Backup polybar (from ~/.config if exists)
if [ -d "$HOME/.config/polybar" ]; then
    echo "Backing up polybar from ~/.config..."
    cp -r "$HOME/.config/polybar" "$BACKUP_DIR/"
fi

# Backup other common configs
echo "Backing up other configs..."

# Terminal configs
[ -f "$HOME/.bashrc" ] && cp "$HOME/.bashrc" "$BACKUP_DIR/"
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$BACKUP_DIR/"
[ -f "$HOME/.tmux.conf" ] && cp "$HOME/.tmux.conf" "$BACKUP_DIR/"

# Vim/Neovim
[ -f "$HOME/.vimrc" ] && cp "$HOME/.vimrc" "$BACKUP_DIR/"
[ -d "$HOME/.config/nvim" ] && cp -r "$HOME/.config/nvim" "$BACKUP_DIR/"

# Git config
[ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$BACKUP_DIR/"

# Create a list of installed packages
echo "Creating package list..."
dpkg --get-selections > "$BACKUP_DIR/installed-packages.txt"
apt-mark showmanual > "$BACKUP_DIR/manually-installed-packages.txt"

# Create a system info file
echo "Creating system info..."
cat > "$BACKUP_DIR/system-info.txt" << EOF
Hostname: $(hostname)
Date: $(date)
Ubuntu Version: $(lsb_release -d | cut -f2)
Kernel: $(uname -r)
Desktop: i3wm
EOF

# Compress the backup
echo "Compressing backup..."
cd "$HOME"
tar -czf "${BACKUP_DIR}.tar.gz" "$(basename $BACKUP_DIR)"

echo ""
echo "Backup completed!"
echo "Location: ${BACKUP_DIR}.tar.gz"
echo "Uncompressed: $BACKUP_DIR"
echo ""
echo "To restore, extract the tar.gz file and copy files back to their locations."
