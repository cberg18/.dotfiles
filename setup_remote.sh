#!/bin/bash

if [ -z "$1" ]; then
    echo "! Usage: $0 <remote_host>"
    exit 1
fi

REMOTE_HOST=$1

# Copy public key to the remote host for access
echo "=> Copying public key to $REMOTE_HOST..."
ssh-copy-id -i ~/.ssh/id_ed25519 "$REMOTE_HOST"

# Test SSH connectivity to the git server on the remote host
echo "=> Testing git access on $REMOTE_HOST..."
if ssh "$REMOTE_HOST" "ssh -T -o StrictHostKeyChecking=no git@git.hcmsgroup.com"; then
    echo "=> Git SSH access confirmed."
else
    echo "! Git SSH access failed. Configuring private key..."

    # Copy local private key to remote
    scp ~/.ssh/id_rsa "$REMOTE_HOST:~/.ssh/id_rsa"

    # Set permissions
    ssh "$REMOTE_HOST" "chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_rsa"

    # Configure SSH config
    ssh "$REMOTE_HOST" "echo 'Host git.hcmsgroup.com
  IdentityFile ~/.ssh/id_rsa
  User git' >> ~/.ssh/config && chmod 600 ~/.ssh/config"

    # Configure git to use SSH instead of HTTPS for this domain
    ssh "$REMOTE_HOST" "git config --global url.\"git@git.hcmsgroup.com:\".insteadOf \"https://git.hcmsgroup.com/\""
fi

# Check if .dotfiles is a git repo, clone if not
echo "# Checking .dotfiles repository..."
ssh "$REMOTE_HOST" "if [ ! -d ~/.dotfiles/.git ]; then
    echo '=> Cloning .dotfiles...'
    rm -rf ~/.dotfiles
    git clone https://git.hcmsgroup.com/bergc/.dotfiles ~/.dotfiles
else
    echo '# .dotfiles repository already exists.'
fi"

# Link configuration files
echo "# Linking configuration files..."
ssh "$REMOTE_HOST" "ln -sf ~/.dotfiles/.zshrc ~/.zshrc"
ssh "$REMOTE_HOST" "ln -sf ~/.dotfiles/.pythonrc ~/.pythonrc"

echo "# Setup complete."
