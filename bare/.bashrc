# .bashrc can be sourced in login non-interactive session
# dont do anything if that is the case
[[ $- != *i* ]] && return

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# increase default bash history size
HISTSIZE=100000
HISTFILESIZE=200000

# use vim as default editor
EDITOR=vim

# set a fancy prompt (without hostname)
PS1='\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# enable color support for ls and grep
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# general aliases
alias ll='ls -lah'
alias vim='nvim'

# add local bin directory to PATH
PATH="$PATH:$HOME/bin"

# add python local bin directory to PATH
[[ -d ~/.local/bin ]] && PATH="$PATH:$HOME/.local/bin"

# git aliases
[[ -r ~/bin/git_alias.sh ]] && . ~/bin/git_alias.sh

# add cargo to PATH
[[ -f ~/.cargo/env ]] && . ~/.cargo/env

# source host-specific bashrc
[[ -f ~/.bashrc_local ]] && . ~/.bashrc_local
