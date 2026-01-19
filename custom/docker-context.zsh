docker_prompt_info(){
    if command -v docker >/dev/null 2>&1; then
        export DOCKER_CONTEXT=$(docker context ls | grep \* | awk '{print $1}')
        docker_icon='''
        ZSH_THEME_DOCKER_CONTEXT_PREFIX="$docker_icon  context: "
        ZSH_THEME_DOCKER_CONTEXT="%{$fg[green]%}$DOCKER_CONTEXT%{$reset_color%}"
        ZSH_THEME_DOCKER_CONTEXT_SUFFIX="%{$reset_color%}"

        echo "$ZSH_THEME_DOCKER_CONTEXT_PREFIX$ZSH_THEME_DOCKER_CONTEXT$ZSH_THEME_DOCKER_CONTEXT_SUFFIX"
    fi
}
