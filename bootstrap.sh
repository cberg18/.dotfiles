#!/bin/bash

#main bootstrap for new systems

################################################################################################################################################################################################################################################

echo "Gather credentials to mount smb share."
if [ -e ~/.smbcredentials ]
then
    echo "=> Removing existing .smbcredentials "
    rm ~/.smbcredentials
fi

echo Username: 
read -s -r username
echo ""
echo -n Password: 
read -s -r password
echo ""

touch ~/.smbcredentials
echo user="$username" >> .smbcredentials
echo password="$password" >> .smbcredentials

chmod 600 ~/.smbcredentials

echo "Mount NAS share"
sudo mkdir /home/cberg18/share
echo "//truenas/share /home/cberg18/share cifs credentials=/home/cberg18/.smbcredentials,iocharset=utf8 0 0" | sudo tee -a /etc/fstab > /dev/null
sudo mount -av

################################################################################################################################################################################################################################################


echo "Adding Sublime Text GPG Key"
curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/"

echo "Add VS Code GPG Key"
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

echo "Add GitHub CLI Tool GPG Key"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

echo "Add Syncthing PGP Key"
sudo curl -s -o /usr/share/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

echo "Add piper repository"
sudo add-apt-repository ppa:libratbag-piper/piper-libratbag-git


echo "Add Steam repo to apt"
sudo add-apt-repository multiverse

PACKAGE_LIST=(snapd python3 python3-pip dirmngr gnupg apt-transport-https ca-certificates software-properties-common zsh sublime-text git curl wget apt-transport-https code gh steam syncthing gnome-tweaks piper vlc cifs-utils libncursesw5-dev)

sudo apt update

echo "Install apt based programs"
sudo apt install -y "${PACKAGE_LIST[@]}"

echo "Install Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
rm ./google-chrome-stable_current_amd64.deb

echo "Install snap based programs"
sudo snap install discord 

echo "Install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "=> Installing ZSH Autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM"/plugins/zsh-autosuggestions

echo "=> Installing ZSH Syntax Highlighting"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting

echo "=> Installing additional nano syntax highlighting"
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh

echo "=> Adding a bonsai tree"
git clone https://gitlab.com/jallbrit/cbonsai
cd cbonsai

# install for this user
make install PREFIX=~/.local

# install for all users
sudo make install

cd ~/

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

################################################################################################################################################################################################################################################

#echo "Create SSH Key"
#ssh-keygen -t ed25519 -C "cberg18@gmail.com"
#eval "$(ssh-agent -s)"
#ssh-add ~/.ssh/id_ed25519

#gh auth login
#gh ssh-key add ~/.ssh/id_ed25519.pub --title "popdesktop"

#echo "Download my gh repositories"
#mkdir ~/Documents/git
#cd ~/Documents/git
#git clone git@github.com:cberg18/stockBot.git 
#git clone git@github.com:cberg18/ergodox_f.git
#git clone git@github.com:cberg18/stockli.git 

#ssh-copy-id -i ~/.ssh/id_ed25519.pub pi@pihole
#ssh-copy-id -i ~/.ssh/id_ed25519.pub root@truenas
#ssh-copy-id -i ~/.ssh/id_ed25519.pub rpi0
#ssh-copy-id -i ~/.ssh/id_ed25519.pub rpi1
#ssh-copy-id -i ~/.ssh/id_ed25519.pub rpi2
#ssh-copy-id -i ~/.ssh/id_ed25519.pub htpc

chsh -s $(which zsh)
