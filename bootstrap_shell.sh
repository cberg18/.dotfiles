#!/bin/bash

#lite version to setup just the shell

################################################################################################################################################################################################################################################

set -e

echo "Add GitHub CLI Tool GPG Key"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

PACKAGE_LIST=(python3 python3-pip dirmngr gnupg apt-transport-https ca-certificates software-properties-common zsh git curl wget apt-transport-https gh cifs-utils)

sudo apt update

echo "Install apt based programs"
sudo apt install -y "${PACKAGE_LIST[@]}"

echo "Install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

mkdir -p $HOME/.oh-my-zsh/custom/plugins/{zsh-syntax-highlighting,zsh-autosuggestions}

echo "=> Installing ZSH Autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM"/plugins/zsh-autosuggestions

echo "=> Installing ZSH Syntax Highlighting"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting

echo "=> Installing additional nano syntax highlighting"
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh


################################################################################################################################################################################################################################################

mkdir ~/.dotfiles
git clone https://github.com/cberg18/.dotfiles.git ~/.dotfiles

#remove the default .zshrc
if [ -e ~/.zshrc ]
then
    echo "=> Removing default .zshrc. "
    rm ~/.zshrc
fi

#link your .zshrc
if [ ! -L ~/.zshrc ]
then
    rm ~/.zshrc
    echo "=> Linking your zshrc. "
    ln -sv ~/.dotfiles/.zshrc ~/.zshrc
else
    echo "=> Your zshrc has already been linked. "
fi

#link custom theme
if [ ! -L ~/.oh-my-zsh/custom/themes/af-magic.zsh-theme ]
then
    rm ~/.oh-my-zsh/custom/themes/af-magic.zsh-theme
    echo "=> Linking your theme. "
    ln -sv ~/.dotfiles/custom/af-magic.zsh-theme ~/.oh-my-zsh/custom/themes/af-magic.zsh-theme
else
    echo "=> Your theme has already been linked. "
fi

if [ ! -L ~/.gitconfig ]
then
    echo "=> Linking your gitfconfig. "
    ln -sv ~/.dotfiles/.gitconfig ~/.gitconfig
else
    echo "=> Your gitconfig has already been linked. "
fi

if [ ! -L ~/.nanorc ]
then
    echo "=> Linking your nanorc. "
    ln -sv ~/.dotfiles/.nanorc ~/.nanorc
    ln -sv ~/.dotfiles/.nano ~/.nano
else
    echo "=> Your nanorc has already been linked. "
fi

if [ ! -L ~/.pythonrc ]
then 
    echo "=> Linking your pythonrc. "
    ln -sv ~/.dotfiles/.pythonrc ~/.pythonrc
else
    echo "=> Your pythonrc has been linked. "
fi


chsh -s $(which zsh)
