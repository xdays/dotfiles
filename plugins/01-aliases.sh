# aliases
if ls --color > /dev/null 2>&1; then # GNU `ls`
        colorflag="--color"
else # macOS `ls`
        colorflag="-G"
        export LSCOLORS='BxBxhxDxfxhxhxhxhxcxcx'
fi
alias l="ls -lF ${colorflag}"
alias ls="ls ${colorflag}"
alias ll='ls -alF'
alias typora='open -a typora'
alias tmat='tmux -CC attach'
alias pl='pulumi'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias etcher='sudo /Applications/balenaEtcher.app/Contents/MacOS/balenaEtcher'
alias rm='rm -f'
alias sudo='sudo -H'
alias dpaste="curl -F 'content=<-' https://dpaste.de/api/ && echo"
alias shared='python -m http.server'
