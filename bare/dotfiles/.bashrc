# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# increase default bash history size
HISTSIZE=100000
HISTFILESIZE=200000

# set a fancy prompt
PS1='\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# enable color support of ls and also add handy aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# general aliases
alias ll='ls -lah'
alias vim='nvim'

# git aliases
[[ -r ~/bin/git_alias.sh ]] && . ~/bin/git_alias.sh

# add cargo to PATH
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
