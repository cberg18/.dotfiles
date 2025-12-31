PROMPT='
%{$fg_bold[cyan]%}%~%{$fg_bold[blue]%}%{$fg_bold[blue]%} % %{$reset_color%} $(git_prompt_info)
%{$fg[green]%}%(!.#.$CPS1) %{$reset_color%'

RPROMPT=' $(ruby_prompt_info) %{${fg_bold[blue]}%} [%B$FG[148]%n%{$fg_bold[blue]%}@%B$FG[148]%m%{${fg_bold[blue]}%}]'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}[git:"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}] %{$fg[red]%}✖%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}] %{$fg[green]%}✔%{$reset_color%}"
ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg[green]%}["
ZSH_THEME_RUBY_PROMPT_SUFFIX="]%{$reset_color%}"
