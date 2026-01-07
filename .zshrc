# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.

if [[ $1 = "update" ]]; then
    echo "[] updated successfully"
elif [ $# -eq 0 ]; then
    echo "[] checking for updates..."
    git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles fetch
    UPSTREAM=${1:-'@{u}'}
    LOCAL=$(git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles rev-parse @)
    REMOTE=$(git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles rev-parse "$UPSTREAM")
    if [ ! -d $HOME/.dotfiles/.git ]; then
        git clone https://github.com/cberg18/.dotfiles.git ~/.dotfiles
    elif [ $LOCAL != $REMOTE ]; then
        echo "[] Update available..."
        git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles reset -q --hard
        git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles pull
        source ~/.zshrc update
        return
    else [ $LOCAL = $REMOTE ]
        echo "[].dotfiles are up to date"
    fi
else
    echo "[✖] somethings weird"
fi

export PATH="$HOME/.local/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export RPS1C=034
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=green,bg=bold,underline"
#export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#008080,bg=#808000,bold,underline"

# key bindings for terminal navigation
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

#set right prompt color and prompt symbol based on the host
case $HOST in

desktop)
  export RPS1C=083
  export CPS1='--φ'
  ;;

laptop)
  export RPS1C=083
  export CPS1='--ε'
  ;;

htpc)
  export RPS1C=083
  export CPS1='--Ξ'
  ;;

truenas)
  export RPS1C=034
  export CPS1='--†'
  ;;

cluster1)
  export RPS1C=034
  export CPS1='--¤¹'
  ;;

cluster2)
  export RPS1C=034
  export CPS1='--¤²'
  ;;

cluster3)
  export RPS1C=034
  export CPS1='--¤³'
  ;;

cluster4)
  export RPS1C=034
  export CPS1='--¤⁴'
  ;;

steamdeck)
  export RPS1C=083
  export CPS1='-->'
  ;;

gcp1)
  export RPS1C=034
  export CPS1='--🌩'
  ;;

esac

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="af-magic"
if [[ $isVSCode ]]; then
  echo "[] setting vscode theme"
  ZSH_THEME="af-magic"
else
  ZSH_THEME="frontcube" # this theme is broken in vscode terminal
fi

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(kubectl terraform ansible colorize zsh-uv-env git git-prompt python pip alias-finder zsh-autosuggestions zsh-syntax-highlighting docker docker-compose 1password)
# Helpful github gist for installing zsh_autosuggestions and zsy-syntax-highlighting
# git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
# https://gist.github.com/dogrocker/1efb8fd9427779c827058f873b94df95
# git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
# git clone git@github.com:scopatz/nanorc.git ~/.dotfiles/.nano/nanorc

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='nano'
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias cp="cp -v"
alias clabops="cd ~/Documents/code/labOps"
alias cstockbot="cd ~/Documents/code/StockBot"
alias cdotfiles="cd ~/.dotfiles"
alias cconfigs="cd /mnt/configs"
alias ls="ls -la"
alias stockbot="code ~/Documents/code/StockBot && cd ~/Documents/code/StockBot"
alias labOps="code ~/Documents/code/labOps && cd ~/Documents/code/labOps"
alias configs="code /mnt/configs && cd /mnt/configs"
alias zstockbot="zed ~/Documents/code/StockBot && cd ~/Documents/code/StockBot"
alias zlabOps="zed ~/Documents/code/labOps && cd ~/Documents/code/labOps"
alias zconfigs="zed /mnt/configs && cd /mnt/configs"
alias zdotfiles="zed ~/.dotfiles && cd ~/.dotfiles"

export PYTHONSTARTUP=$HOME/.pythonrc

# source grc colorful commands
[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh

# source flux completions
command -v flux >/dev/null && . <(flux completion zsh)

# source 1password plugins
[ -f /home/cberg18/.config/op/plugins.sh ] && source /home/cberg18/.config/op/plugins.sh

# add autocompletion for 1password
if command -v op >/dev/null 2>&1; then
    echo "[] getting op completions"
    eval "$(op completion zsh)"
    compdef _op op
fi

# generate uv completions
if command -v uv >/dev/null 2>&1; then
    echo "[] getting uv completions"
    eval "$(uv generate-shell-completion zsh)"
    eval "$(uvx --generate-shell-completion zsh)"
fi

# link to zshrc
if ! test -L ~/.zshrc ; then
  ln -sv ~/.dotfiles/.zshrc ~/.zshrc
fi

# link to zshrc
if ! test -L ~/.pythonrc ; then
  ln -sv ~/.dotfiles/.pythonrc ~/.pythonrc
fi

# Create symlinks for Zed configuration files
if test -d ~/.config/zed ; then # extra test to only make link where needed
    if  ! test -L ~/.config/zed/settings.json; then
        echo "[] Creating symlink for ~/.config/zed/settings.json"
        ln -sv ~/.dotfiles/zed/settings.json ~/.config/zed/settings.json &> /dev/null
    fi
    if ! test -L ~/.config/zed/keybindings.json; then
        echo "[] Creating symlink for ~/.config/zed/keybindings.json"
        ln -sv ~/.dotfiles/zed/keybindings.json ~/.config/zed/keybindings.json &> /dev/null
    fi
fi

# link in custom themes and plugins
ln -sf ~/.dotfiles/custom/themes/* $ZSH_CUSTOM/themes
#ln -sf ~/.dotfiles/custom/plugins/* $ZSH_CUSTOM/plugins

# if no nano syntax highlighting, get it
if [[ ! -d $HOME/.nano ]]; then
    rm -rf $HOME/.nano
    echo "[] getting nano highlighting config"
    curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh
fi

# if no zsh-autosuggestions, get it
if [[ ! -d $ZSH_CUSTOM/plugins/zsh-autosuggestions ]]; then
    echo "[] getting zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

# if no zsh-syntax-highlighting, get it
if [[ ! -d $ZSH_CUSTOM/plugins/zsh-syntax-highlighting ]]; then
    echo "[] getting zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

#print a cool tree
if command -v cbonsai >/dev/null 2>&1; then
    cbonsai -p -m $HOST
fi
