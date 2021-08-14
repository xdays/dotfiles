#!/bin/bash


export WROOT=$PWD

# install deps
install_tools() {
    if [ "$(uname)" == "Darwin" ]; then
        if ! command -v brew &> /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew tap homebrew/cask
        brew tap homebrew/bundle
        cd $WROOT/deps && brew bundle
    elif [ -e /etc/redhat-release ]; then
        sudo yum install -y epel-release
        sudo yum install -y $(cat ${WROOT}/deps/tools.redhat)
    else
        sudo apt -qq update
        sudo DEBIAN_FRONTEND=noninteractive apt -qq install -y $(cat ${WROOT}/deps/tools.debian)
    fi
}

config_tools() {
    for f in $(find configs -type f); do
        filename=$(basename "$f")
        src="$WROOT/configs/$filename"
        dest=$HOME/.$filename
        ln -snf "$src" "$dest"
    done
    ln -snf "$WROOT/plugins" $HOME/.plugins
}

config_vim() {
    if [ -e $HOME/.vim ]
    then
        echo "vim is already configured"
    else
        mkdir -p $HOME/.vim
        git clone https://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
        ln -snf "$WROOT/configs/vimrc" $HOME/.vimrc
        vim +PluginInstall +qall
        cd $HOME/.vim/bundle/YouCompleteMe/ && ./install.py && cd -
    fi
}

config_zsh() {
    if [ -e $HOME/.oh-my-zsh ]; then
        echo "zsh is already configured"
    else
        git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
        git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM:=$HOM/.oh-my-zsh/custom}/plugins/zsh-completions"
    fi
    ln -snf "$WROOT/configs/zshrc" $HOME/.zshrc
}

main() {
    install_tools
    config_tools
    config_vim
    config_zsh
}

main
