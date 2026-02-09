# environment var
if uname -a | grep -q "Darwin"; then
    export BREW_PREFIX=/opt/homebrew/
    export PATH=$BREW_PREFIX/opt/curl/bin:$PATH
    export PATH=$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH
    export PATH=$BREW_PREFIX/opt/python@3.14/bin:$PATH
    export PATH=$BREW_PREFIX/opt/python@3.14/libexec/bin:$PATH
    export PATH=$BREW_PREFIX/opt/node@24/bin:$PATH
    export PATH=$BREW_PREFIX/opt/ruby/bin:$PATH
elif uname -a | g-q Microsoft; then
    export DOCKER_HOST=tcp://localhost:2375
else
    export PATH=/usr/local/openresty/luajit/bin:$PATH
fi

export WPATH=$HOME/Workspace
export WROOT=$WPATH/xdays/web
export CLICOLOR=1
export TERM=xterm-256color
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR=nvim
export HTTPSTAT_SAVE_BODY=false
export TG_TF_PATH=terraform

