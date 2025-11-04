PROMPT=$'%{$fg_bold[green]%}%n@%m%{$reset_color%}\n'
PROMPT+=$'%{$fg[cyan]%}%c%{$reset_color%}'
PROMPT+=' $(git_prompt_info)'
PROMPT+=$'%(?:%{$fg_bold[green]%}%1{λ%}:%{$fg_bold[red]%}%1{λ%}) '

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
