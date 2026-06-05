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
alias k='kubectl'
alias e='goenv'
alias n='ksn'
alias tg='terragrunt'
alias tf='terraform'
alias notch="for img in ~/Pictures/Wallpaper/*; do mint run igorkulman/ChangeMenuBarColor SolidColor '#000000' $img;done"
alias yt='yt-dlp -S ext:mp4:m4a --cookies-from-browser chrome:Default'
alias watch='watch '
alias genpass='openssl rand -base64 32 | tr -d "
" | head -c 32'
alias codeburn='npx codeburn'
alias ccstatusline='bunx -y ccstatusline@latest'
alias redis-dump='docker run -it --rm ghcr.io/yannh/redis-dump-go:latest'
alias asl='aws sso login'
alias digx='dog -H @https://dns.xdays.me/dns-query'

alias cdi='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs'
alias cdx='cd $WORKSPACE/xdays/'
alias cdl='cd $WORKSPACE/loopapps/'
alias cdo='cd $WORKSPACE/loopapps/ops'
