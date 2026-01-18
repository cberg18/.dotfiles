ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}[git:%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[blue]%}] %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UPSTREAM_SYMBOL="%{$fg_bold[yellow]%}⟳ "
ZSH_THEME_GIT_PROMPT_UPSTREAM_NO_TRACKING="%{$fg_bold[red]%}!"
ZSH_THEME_GIT_PROMPT_UPSTREAM_PREFIX="%{$fg[red]%}->%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_UPSTREAM_SUFFIX="%{$fg[red]%}"
ZSH_GIT_PROMPT_SHOW_UPSTREAM='full'

PROMPT='
%{$fg_bold[cyan]%}%~%{$fg_bold[blue]%}%{$fg_bold[blue]%} % %{$reset_color%} $(docker_prompt_info) $(gitprompt)
%{$fg[green]%}%(!.#.$CPS1) %{$reset_color%}'

RPROMPT=' %{${fg_bold[blue]}%} [%B$FG[148]%n%{$fg_bold[blue]%}@%B$FG[148]%m%{${fg_bold[blue]}%}]'
