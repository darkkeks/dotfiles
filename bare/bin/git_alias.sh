#
# Functions
#

# Use arc if not inside git repo
function vcs() {
    if git rev-parse >/dev/null 2>&1; then
        git "$@"
    else
        arc "$@"
    fi
}

function vcs_current_branch() {
  local ref
  ref=$(vcs symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(vcs rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

# Pretty log messages
function _vcs_log_prettily(){
  if ! [ -z $1 ]; then
    vcs log --pretty=$1
  fi
}

# Warn if the current branch is a WIP
function work_in_progress() {
  if $(vcs log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-"); then
    echo "WIP!!"
  fi
}

#
# Aliases
# (sorted alphabetically)
#

alias g='vcs'

alias ga='vcs add'
alias gaa='vcs add --all'
alias gapa='vcs add --patch'
alias gau='vcs add --update'
alias gav='vcs add --verbose'
alias gap='vcs apply'

alias gb='vcs branch'
alias gba='vcs branch -a'
alias gbd='vcs branch -d'
alias gbda='vcs branch --no-color --merged | command grep -vE "^(\+|\*|\s*(master|develop|dev)\s*$)" | command xargs -n 1 vcs branch -d'
alias gbD='vcs branch -D'
alias gbl='vcs blame -b -w'
alias gbnm='vcs branch --no-merged'
alias gbr='vcs branch --remote'
alias gbs='vcs bisect'
alias gbsb='vcs bisect bad'
alias gbsg='vcs bisect good'
alias gbsr='vcs bisect reset'
alias gbss='vcs bisect start'

alias gc='vcs commit'
alias gc!='vcs commit --amend'
alias gcn!='vcs commit --no-edit --amend'
alias gca='vcs commit -a'
alias gca!='vcs commit -a --amend'
alias gcan!='vcs commit -a --no-edit --amend'
alias gcans!='vcs commit -a -s --no-edit --amend'
alias gcam='vcs commit -a -m'
alias gcsm='vcs commit -s -m'
alias gcb='vcs checkout -b'
alias gcf='vcs config --list'
alias gcl='vcs clone --recurse-submodules'
alias gclean='vcs clean -id'
alias gpristine='vcs reset --hard && vcs clean -dfx'
alias gcm='vcs checkout master'
alias gcd='vcs checkout develop'
alias gcmsg='vcs commit -m'
alias gco='vcs checkout'
alias gcount='vcs shortlog -sn'
alias gcp='vcs cherry-pick'
alias gcpa='vcs cherry-pick --abort'
alias gcpc='vcs cherry-pick --continue'
alias gcs='vcs commit -S'

alias gd='vcs diff'
alias gdca='vcs diff --cached'
alias gdcw='vcs diff --cached --word-diff'
alias gdct='vcs describe --tags $(vcs rev-list --tags --max-count=1)'
alias gds='vcs diff --staged'
alias gdt='vcs diff-tree --no-commit-id --name-only -r'
alias gdw='vcs diff --word-diff'

function gdv() {
  vcs diff -w "$@" | view - 
}

alias gf='vcs fetch'
alias gfa='vcs fetch --all --prune'
alias gfo='vcs fetch origin'

alias gfg='vcs ls-files | grep'

alias gg='vcs gui citool'
alias gga='vcs gui citool --amend'

function ggf() {
  [[ "$#" != 1 ]] && local b="$(vcs_current_branch)"
  vcs push --force origin "${b:=$1}"
}

function ggfl() {
  [[ "$#" != 1 ]] && local b="$(vcs_current_branch)"
  vcs push --force-with-lease origin "${b:=$1}"
}

function ggl() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    vcs pull origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(vcs_current_branch)"
    vcs pull origin "${b:=$1}"
  fi
}

function ggp() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    vcs push origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(vcs_current_branch)"
    vcs push origin "${b:=$1}"
  fi
}

function ggpnp() {
  if [[ "$#" == 0 ]]; then
    ggl && ggp
  else
    ggl "${*}" && ggp "${*}"
  fi
}

function ggu() {
  [[ "$#" != 1 ]] && local b="$(vcs_current_branch)"
  vcs pull --rebase origin "${b:=$1}"
}

alias ggpur='ggu'
alias ggpull='vcs pull origin "$(vcs_current_branch)"'
alias ggpush='vcs push origin "$(vcs_current_branch)"'

alias ggsup='vcs branch --set-upstream-to=origin/$(vcs_current_branch)'
alias gpsup='vcs push --set-upstream origin $(vcs_current_branch)'

alias ghh='vcs help'

alias gignore='vcs update-index --assume-unchanged'
alias gignored='vcs ls-files -v | grep "^[[:lower:]]"'
alias vcs-svn-dcommit-push='vcs svn dcommit && vcs push vcshub master:svntrunk'

alias gk='\vcsk --all --branches'
alias gke='\vcsk --all $(vcs log -g --pretty=%h)'

alias gl='vcs pull'
alias glg='vcs log --stat'
alias glgp='vcs log --stat -p'
alias glgg='vcs log --graph'
alias glgga='vcs log --graph --decorate --all'
alias glgm='vcs log --graph --max-count=10'
alias glo='vcs log --oneline'
alias glol="vcs log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias glols="vcs log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --stat"
alias glod="vcs log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
alias glods="vcs log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"
alias glola="vcs log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all"
alias glog='vcs log --oneline --decorate --graph'
alias gloga='vcs log --oneline --decorate --graph --all'
alias glp="_vcs_log_prettily"

alias gm='vcs merge'
alias gmom='vcs merge origin/master'
alias gmt='vcs mergetool --no-prompt'
alias gmtvim='vcs mergetool --no-prompt --tool=vimdiff'
alias gmum='vcs merge upstream/master'
alias gma='vcs merge --abort'

alias gp='vcs push'
alias gpd='vcs push --dry-run'
alias gpf='vcs push --force'
alias gpf!='vcs push --force'
alias gpoat='vcs push origin --all && vcs push origin --tags'
alias gpu='vcs push upstream'
alias gpv='vcs push -v'

alias gr='vcs remote'
alias gra='vcs remote add'
alias grb='vcs rebase'
alias grba='vcs rebase --abort'
alias grbc='vcs rebase --continue'
alias grbd='vcs rebase develop'
alias grbi='vcs rebase -i'
alias grbm='vcs rebase master'
alias grbs='vcs rebase --skip'
alias grev='vcs revert'
alias grh='vcs reset'
alias grhh='vcs reset --hard'
alias groh='vcs reset origin/$(vcs_current_branch) --hard'
alias grm='vcs rm'
alias grmc='vcs rm --cached'
alias grmv='vcs remote rename'
alias grrm='vcs remote remove'
alias grs='vcs restore'
alias grset='vcs remote set-url'
alias grss='vcs restore --source'
alias grt='cd "$(vcs rev-parse --show-toplevel || echo .)"'
alias gru='vcs reset --'
alias grup='vcs remote update'
alias grv='vcs remote -v'

alias gsb='vcs status -sb'
alias gsd='vcs svn dcommit'
alias gsh='vcs show'
alias gsi='vcs submodule init'
alias gsps='vcs show --pretty=short --show-signature'
alias gsr='vcs svn rebase'
alias gss='vcs status -s'
alias gst='vcs status'

alias gsta='vcs stash push'

alias gstaa='vcs stash apply'
alias gstc='vcs stash clear'
alias gstd='vcs stash drop'
alias gstl='vcs stash list'
alias gstp='vcs stash pop'
alias gsts='vcs stash show --text'
alias gstall='vcs stash --all'
alias gsu='vcs submodule update'
alias gsw='vcs switch'
alias gswc='vcs switch -c'

alias gts='vcs tag -s'
alias gtv='vcs tag | sort -V'
alias gtl='gtl(){ vcs tag --sort=-v:refname -n -l "${1}*" }; noglob gtl'

alias gunignore='vcs update-index --no-assume-unchanged'
alias gunwip='vcs log -n 1 | grep -q -c "\-\-wip\-\-" && vcs reset HEAD~1'
alias gup='vcs pull --rebase'
alias gupv='vcs pull --rebase -v'
alias gupa='vcs pull --rebase --autostash'
alias gupav='vcs pull --rebase --autostash -v'
alias glum='vcs pull upstream master'

alias gwch='vcs whatchanged -p --abbrev-commit --pretty=medium'
alias gwip='vcs add -A; vcs rm $(vcs ls-files --deleted) 2> /dev/null; vcs commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"'

alias gs='vcs submit'
alias gsv='vcs submit --view'
