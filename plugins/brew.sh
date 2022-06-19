if [ $(arch) = "x86_64" ] && [ $USER = "xdays" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    export BREW_BIN=$HOMEBREW_PREFIX/bin
fi
