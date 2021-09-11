#!/bin/bash


################################################################################################################################################################################################################################################

echo "Gather credentials to mount smb share."
if [ -e ~/.smbcredentials ]
then
    echo "=> Removing existing .smbcredentials "
    rm ~/.smbcredentials
fi

echo -n Username: 
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
echo "//192.168.1.15/share /home/cberg18/share cifs credentials=/home/cberg18/.smbcredentials,iocharset=utf8 0 0" >> /etc/fstab

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

echo "Add Steam repo to apt"
sudo add-apt-repository multiverse

PACKAGE_LIST=(python3 dirmngr gnupg apt-transport-https ca-certificates software-properties-common zsh sublime-text git curl wget apt-transport-https code gh steam syncthing)

sudo apt update

echo "Install apt based programs"
sudo apt install -y "${PACKAGE_LIST[@]}"

echo "Install Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb

echo "Install snap based programs"
sudo snap install discord 

echo "Install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "=> Installing ZSH Autosuggestions"
git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM"/plugins/zsh-autosuggestions

echo "=> Installing ZSH Syntax Highlighting"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM"/plugins/zsh-syntax-highlighting


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

################################################################################################################################################################################################################################################

echo "Create SSH Keys"
ssh-keygen -t ed25519 -C "cberg18@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title "popdesktop"

echo "Download my gh repositories"
mkdir ~/Documents/git
git clone git@github.com:cberg18/stockBot.git ~/Documents/git
git clone git@github.com:cberg18/ergodox_f.git ~/Documents/git
git clone git@github.com:cberg18/stockli.git ~/Documents/git

ssh-copy-id -i ~/.ssh/id_ed25519.pub pi@pihole
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@truenas
ssh-copy-id -i ~/.ssh/id_ed25519.pub rpi0
ssh-copy-id -i ~/.ssh/id_ed25519.pub rpi1
ssh-copy-id -i ~/.ssh/id_ed25519.pub rpi2
ssh-copy-id -i ~/.ssh/id_ed25519.pub htpc
