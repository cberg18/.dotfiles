    #!/bin/bash

if [ ! -L ~/.zshrc ]
then 
    echo "=> Linking your zshrc. "
    ln -sv ~/dotfiles/.zshrc ~/.zshrc
else
    echo "=> Your zshrc has already been linked. "
fi

if [ ! -L ~/.nanorc ]
then
    echo "=> Linking your nanorc. "
    ln -sv ~/dotfiles/.nanorc ~/.nanorc
else
    echo "=> Your nanorc has already been linked. "
fi

if [ ! -L ~/.pythonrc ]
then 
    echo "=> Linking your pythonrc. "
    ln -sv ~/dotfiles/.pythonrc ~/.pythonrc
else
    echo "=> Your pythonrc has been linked. "
fi

if [ ! -L ~/.config/alacritty/alacritty.yml ]
then 
    echo "=> Linking your alacritty config. "
    ln -sv ~/.config/alacritty/alacritty.yml ~/dotfiles/alacritty.yml
else
    echo "=> Your alacritty config has already been linked. "
fi
