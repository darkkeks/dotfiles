shopt -s histappend

HISTSIZE=10000
HISTFILESIZE=20000

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

EDITOR=vim

PS1='\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

JAVA_PATH=/Library/Java/JavaVirtualMachines/jdk-11.yandex

# BREW_PREFIX=$(brew --prefix)  (50ms)
BREW_PREFIX="/usr/local"

PATH="/opt/local/bin:/opt/local/sbin:/usr/local/bin:/usr/local/sbin:$PATH"
PATH="~/.bin:$PATH"
PATH="~/.bin/arcadia:$PATH"
PATH="$JAVA_PATH/bin:$PATH"
PATH="/Library/TeX/texbin/:$PATH"
PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
PATH="$BREW_PREFIX/opt/grep/libexec/gnubin:$PATH"
PATH="$HOME/.cargo/bin:$PATH"
PATH="/usr/local/opt/openal-soft/bin:$PATH"

# The next line updates PATH for Yandex Cloud CLI.
if [ -f '/Users/darkkeks/yandex-cloud/path.bash.inc' ]; then source '/Users/darkkeks/yandex-cloud/path.bash.inc'; fi

# The next line enables shell command completion for yc.
if [ -f '/Users/darkkeks/yandex-cloud/completion.bash.inc' ]; then source '/Users/darkkeks/yandex-cloud/completion.bash.inc'; fi

EXECUTER_CONF=~/.executer.conf
export PERL_LWP_SSL_VERIFY_HOSTNAME=0

# Some shortcuts
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias ll='ls -lah'
alias vim='nvim'

alias hh='cd ~/Documents/hse-homework'
alias ht='cd ~/Documents/hse-tex'

# arc
[[ -r ~/.bin/arc_alias.sh ]] && . ~/.bin/arc_alias.sh

ARC_OS=/Users/darkkeks/repo/object-store
ARC_1=/Users/darkkeks/repo/a1
ARC_2=/Users/darkkeks/repo/a2
ARC_3=/Users/darkkeks/repo/a3
ARC_4=/Users/darkkeks/repo/a4
ARC_T=/Users/darkkeks/repo/at
ARC_STORE_1=/Users/darkkeks/repo/s1
ARC_STORE_2=/Users/darkkeks/repo/s2
ARC_STORE_3=/Users/darkkeks/repo/s3
ARC_STORE_4=/Users/darkkeks/repo/s4
ARC_STORE_T=/Users/darkkeks/repo/st

ARC_COLORS=(
    ffbe0b
    fb5607
    ff006e
    8338ec
    3a86ff
)

alias r1="cd $ARC_1/direct; iterm-tab-colors ${ARC_COLORS[0]}"
alias r2="cd $ARC_2/direct; iterm-tab-colors ${ARC_COLORS[1]}"
alias r3="cd $ARC_3/direct; iterm-tab-colors ${ARC_COLORS[2]}"
alias r4="cd $ARC_4/direct; iterm-tab-colors ${ARC_COLORS[3]}"
alias rt="cd $ARC_T/direct; iterm-tab-colors ${ARC_COLORS[4]}"

function mount-all {
    arc mount -m $ARC_1 -S $ARC_STORE_1 --object-store $ARC_OS
    arc mount -m $ARC_2 -S $ARC_STORE_2 --object-store $ARC_OS
    arc mount -m $ARC_3 -S $ARC_STORE_3 --object-store $ARC_OS
    arc mount -m $ARC_4 -S $ARC_STORE_4 --object-store $ARC_OS
    arc mount -m $ARC_T -S $ARC_STORE_T --object-store $ARC_OS
}

# ppcdev
PPCDEV_COLORS=(
    f94144
    f3722c
    f8961e
    f9c74f
    90be6d
    43aa8b
    577590
)

function colored-ppcdev {
    index=$1; shift
    color=${PPCDEV_COLORS[$(($index - 1))]}
    [[ -z $color ]] || iterm-tab-colors $color
    ssh ppcdev$index.yandex.ru "$@"
    [[ -z $color ]] || iterm-tab-colors
}

for i in {1..7}; do
    alias "ppc$i"="colored-ppcdev $i"
done

# completion
mkdir -p $BREW_PREFIX/etc/bash_completion.d

# llvm
PATH="/usr/local/opt/llvm/bin:$PATH"
LDFLAGS="-L/usr/local/opt/llvm/lib"
CPPFLAGS="-I/usr/local/opt/llvm/include"

# connect to unit-test database
function dbs {
    container=$(docker ps | grep dbschema | awk '{print $1}')
    if [ -z "$container" ]; then
        echo 'No container was found (check docker ps)'
        return
    fi
    docker exec -it $container mysql -u root $@
}

# >= 100ms
function init-nvm {
    [ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
    [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
}

# fixes "signed certificate in chain" node error
export NODE_EXTRA_CA_CERTS="/etc/ssl/certs/YandexInternalRootCA.pem"

# https://paste.darkkeks.me
function cpaste {
    if [[ -z "$1" ]]; then
        curl -s -F 'source=<-' -F name=Untitled -F lang=auto https://paste.darkkeks.me/ajax/createPost/ \
            | jq '"https://paste.darkkeks.me/" + .id' -r
    else
        cpaste < "$1"
    fi
}

function unused-code {
    create-issue.py -p DIRECT-164934 -s "$1" -c --do
}
