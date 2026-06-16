# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
#
export DOTFILES_REMOTE="https://github.com/cberg18/.dotfiles.git"

if [[ $1 = "update" ]]; then
    echo "[] updated successfully"
elif [ $# -eq 0 ]; then
    if [ ! -d $HOME/.dotfiles/.git ]; then
        echo "[] .dotfiles repository not found, cloning..."
        git clone $DOTFILES_REMOTE ~/.dotfiles
    else
        echo "[] checking for updates..."
        git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles fetch
        UPSTREAM=${1:-'@{u}'}
        LOCAL=$(git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles rev-parse @)
        REMOTE=$(git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles rev-parse "$UPSTREAM")
        if [ $LOCAL != $REMOTE ]; then
            echo "[] Update available..."
            # Check for local uncommitted changes (staged or unstaged)
            if ! git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles diff --quiet || \
               ! git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles diff --cached --quiet; then
                echo "[] Warning: Local uncommitted changes detected in .dotfiles. Skipping auto-update to avoid discarding changes."
            else
                # Check for local commits that are not upstream
                _DOTFILES_BASE=$(git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles merge-base @ "$UPSTREAM")
                if [ "$LOCAL" != "$_DOTFILES_BASE" ]; then
                    echo "[] Warning: Local commits detected in .dotfiles. Skipping auto-update to avoid discarding changes."
                else
                    # Safe to fast-forward pull
                    git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME/.dotfiles pull --ff-only
                    source ~/.zshrc update
                    return
                fi
            fi
        else
            echo "[] .dotfiles are up to date"
        fi
    fi
else
    echo "[✖] somethings weird"
fi

export PATH="$HOME/.local/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
export RPS1C=034
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=green,bg=bold,underline"
export OP_HOST="op.byteshiftd.dev"

if [[ $TERM == "xterm-ghostty" ]]; then
    export TERM="xterm-256color"
fi

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
alias ls="ls -lah"
alias stockbot="code ~/Documents/code/StockBot && cd ~/Documents/code/StockBot"
alias labOps="code ~/Documents/code/labOps && cd ~/Documents/code/labOps"
alias configs="code /mnt/configs && cd /mnt/configs"
alias zstockbot="zed ~/Documents/code/StockBot && cd ~/Documents/code/StockBot"
alias zlabOps="zed ~/Documents/code/labOps && cd ~/Documents/code/labOps"
alias zconfigs="zed /mnt/configs && cd /mnt/configs"
alias zdotfiles="zed ~/.dotfiles && cd ~/.dotfiles"

export PYTHONSTARTUP=$HOME/.pythonrc

################################################
# custom stuff
################################################

# link to zshrc
if ! test -L ~/.zshrc ; then
  ln -sv ~/.dotfiles/.zshrc ~/.zshrc
fi

# link to agents
if ! test -L ~/.agents ; then
  ln -sv ~/.dotfiles/.agents ~/.agents
fi

# Create symlinks for Zed configuration files
if test -d ~/.config/zed ; then # extra test to only make link where needed
    if  ! test -L ~/.config/zed/settings.json; then
        echo "[] Creating symlink for ~/.config/zed/settings.json"
        ln -sf ~/.dotfiles/zed/settings.json ~/.config/zed/settings.json &> /dev/null
    fi
    if ! test -L ~/.config/zed/keymap.json; then
        echo "[] Creating symlink for ~/.config/zed/keymap.json"
        ln -sf ~/.dotfiles/zed/keymap.json ~/.config/zed/keymap.json &> /dev/null
    fi
    # Only link themes if the themes directory exists
    if test -d ~/.dotfiles/zed/themes; then
        for theme_file in ~/.dotfiles/zed/themes/*; do
            if ! test -L ~/.config/zed/themes/${theme_file:t}; then
                ln -sf "$theme_file" ~/.config/zed/themes/${theme_file:t}
            fi
        done
    fi
fi

# link in themes and plugins
echo "[] linking custom themes and plugins"
for theme_file in ~/.dotfiles/custom/themes/*; do
    if ! test -L "$ZSH_CUSTOM/themes/${theme_file:t}"; then
        ln -sf "$theme_file" "$ZSH_CUSTOM/themes/${theme_file:t}" &> /dev/null
    fi
done

for custom_file in ~/.dotfiles/custom/*.zsh; do
    if ! test -L "$ZSH_CUSTOM/${custom_file:t}"; then
        ln -sf "$custom_file" "$ZSH_CUSTOM/${custom_file:t}" &> /dev/null
    fi
done

echo "[] making any shell scripts available on path"
for script_file in ~/.dotfiles/*.sh; do
    if ! test -L "$HOME/.local/bin/${script_file:t}"; then
        ln -sfn "$script_file" "$HOME/.local/bin/${script_file:t}" &> /dev/null
    fi
done

################################################
# plugins
################################################

# output highlighting from grc
if [[ -s "/etc/grc.zsh" ]]; then
   source /etc/grc.zsh
fi

# if no nano syntax highlighting, get it
if [[ ! -d $HOME/.nano ]]; then
    echo "[] getting nano highlighting config"
    curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh
fi

if [[ ! -d $ZSH_CUSTOM/plugins/git-prompt ]]; then
    echo "[] cloning git-prompt plugin"
    mkdir -p $ZSH_CUSTOM/plugins/git-prompt
    git clone --depth=1 https://github.com/woefe/git-prompt.zsh $ZSH_CUSTOM/plugins/git-prompt
fi
source $ZSH_CUSTOM/plugins/git-prompt/git-prompt.zsh

# if no zsh-autosuggestions, get it
if [[ ! -d $ZSH_CUSTOM/plugins/zsh-autosuggestions ]]; then
    echo "[] getting auto-suggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

# if no zsh-syntax-highlighting, get it
if [[ ! -d $ZSH_CUSTOM/plugins/zsh-syntax-highlighting ]]; then
    echo "[] getting syntax highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# if no uv, get it
if [[ ! -d $ZSH_CUSTOM/plugins/uv ]]; then
    echo "[] getting uv"
    git clone https://git.safranil.fr/zsh/ohmyzsh.git $ZSH_CUSTOM/plugins/uv
fi

################################################
# completions
################################################

# source flux completions
if command -v flux >/dev/null; then
  . <(flux completion zsh)
fi

# generate uv completions
if command -v uv >/dev/null 2>&1; then
    echo "[] getting uv completions"
    eval "$(uv generate-shell-completion zsh)"
    eval "$(uvx --generate-shell-completion zsh)"
fi

# completeions for vault
if command -v vault > /dev/null 2>&1; then
    echo "[] getting vault completions"
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C "$(command -v vault)" vault
fi

# source 1password plugins
if [[ -f /home/cberg18/.config/op/plugins.sh ]]; then
    source /home/cberg18/.config/op/plugins.sh
fi

# add autocompletion for 1password
if command -v op >/dev/null 2>&1; then
    echo "[] getting op completions"
    eval "$(op completion zsh)"
    compdef _op op
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/cberg18/google-cloud-sdk/path.zsh.inc' ]; then . '/home/cberg18/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/cberg18/google-cloud-sdk/completion.zsh.inc' ]; then . '/home/cberg18/google-cloud-sdk/completion.zsh.inc'; fi

#print a cool tree
if command -v cbonsai >/dev/null 2>&1; then
    cbonsai -p -m $HOST
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
