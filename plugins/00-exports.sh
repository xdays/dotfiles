# environment var
if uname -a | grep -q "Darwin"; then
  BREW_PREFIX=$(brew --prefix)
    export PATH=$BREW_PREFIX/sbin:$PATH
    export PATH=$BREW_PREFIX/opt/curl/bin:$PATH
    export PATH=$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH
    export PATH=$BREW_PREFIX/opt/python@3.8/bin:$PATH
    export PATH=$BREW_PREFIX/opt/python@3.8/libexec/bin:$PATH
    export PATH=$BREW_PREFIX/opt/node@14/bin:$PATH
    export PATH=$BREW_PREFIX/opt/ruby/bin:$PATH
elif uname -a | grep -q Microsoft; then
    export DOCKER_HOST=tcp://localhost:2375
else
    export PATH=/usr/local/openresty/luajit/bin:$PATH
fi

export CLICOLOR=1
export TERM=xterm-256color
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR=vim
export HOMEBREW_EDITOR=vim
export HTTPSTAT_SAVE_BODY=false

