#!/bin/bash

#Required packages:
#zsh
#oh-my-zsh
#

#remove the default .zshrc
if [ ~/.zshrc ]
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

if [ ! -L ~/.config/alacritty/alacritty.yml ]
then 
    echo "=> Linking your alacritty config. "
    ln -sv ~/.dotfiles/alacritty.yml ~/.config/alacritty/alacritty.yml 
else
    echo "=> Your alacritty config has already been linked. "
fi

echo "=> Installing ZSH Autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions

echo "=> Installing ZSH Syntax Highlighting"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
