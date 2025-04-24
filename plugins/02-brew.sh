if [[ $(arch) = "x86_64" ]] && [[ $USER = "xdays" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ $(arch) = "arm64" ]] && [[ $USER = "xdays" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
export BREW_BIN=$HOMEBREW_PREFIX/bin
export PATH=$BREW_BIN:$PATH
