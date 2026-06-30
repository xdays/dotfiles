# environment var
if uname -a | grep -q "Darwin"; then
    export BREW_PREFIX=/opt/homebrew/
    # lock tools version
    export PATH=$BREW_PREFIX/opt/curl/bin:$PATH
    export PATH=$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH
    export PATH=$BREW_PREFIX/opt/python@3.14/bin:$PATH
    export PATH=$BREW_PREFIX/opt/python@3.14/libexec/bin:$PATH
    export PATH=$BREW_PREFIX/opt/node@24/bin:$PATH
    export PATH=$BREW_PREFIX/opt/ruby/bin:$PATH
    export PATH=$HOMEBREW_PREFIX/lib/ruby/gems/3.1.0/bin:$PATH
    export PATH=$HOMEBREW_PREFIX/opt/openresty/nginx/sbin:$PATH
    export PATH=$HOMEBREW_PREFIX/opt/openresty/luajit/bin:$PATH
    export PATH=$BREW_PREFIX/opt/postgresql@17/bin:$PATH
    export PATH=$HOME/.cargo/bin:$PATH
    export PATH=$HOME/.mix/escripts:$PATH
    export WORKSPACE=~/Workspace
elif uname -a | grep -q Microsoft; then
    export DOCKER_HOST=tcp://localhost:2375
else
    export PATH=/usr/local/openresty/luajit/bin:$PATH
    export WORKSPACE=~/workspace
fi

export PATH="$HOME/.local/bin:$PATH"
export PATH=$GOPATH/bin:$PATH

export WROOT=$WORKSPACE/web
export CLICOLOR=1
export TERM=xterm-256color
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export EDITOR=nvim
export HTTPSTAT_SAVE_BODY=false
export TG_TF_PATH=terraform
export TF_PLUGIN_CACHE_DIR=$HOME/.terraform.d/plugin-cache
[ -d "$TF_PLUGIN_CACHE_DIR" ] || mkdir -p "$TF_PLUGIN_CACHE_DIR"
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export NIXPKGS_ALLOW_INSECURE=1
