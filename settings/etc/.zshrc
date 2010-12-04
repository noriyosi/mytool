# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt appendhistory extendedglob notify
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/cygdrive/c/Users/noriyosi/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
setopt auto_remove_slash
setopt correct

#ls color
eval $(dircolors -b)

setopt share_history
setopt hist_ignore_all_dups
setopt hist_save_nodups

setopt auto_menu
setopt extended_glob
#expand argument after = to filename
setopt magic_equal_subst
setopt print_eight_bit

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

#not include / in word characters
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

PROMPT='%B%F{blue}[%*]%# %f%b'
RPROMPT='%~'

alias start='cmd /c start '
alias ls='ls -F '

export LANG=ja_JP.UTF-8
