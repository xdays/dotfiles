#!/bin/bash


export WROOT=$PWD

# install deps
install_tools() {
    if [[ "$(uname)" == "Darwin" ]]; then
        if ! command -v brew &> /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew tap homebrew/cask
        brew tap homebrew/bundle
        cd $WROOT/deps && brew bundle && cd -
    elif [[ -e /etc/redhat-release ]]; then
        sudo yum install -y epel-release
        sudo yum install -y $(cat ${WROOT}/deps/tools.redhat)
    elif [[ -e /etc/debian_version ]]; then
        sudo apt -qq update
        sudo DEBIAN_FRONTEND=noninteractive apt -qq install -y $(cat ${WROOT}/deps/tools.debian)
    fi
}

config_tools() {
    for f in $(find $WROOT/configs -maxdepth 1 -type f); do
        filename=$(basename "$f")
        src="$WROOT/configs/$filename"
        dest=$HOME/.$filename
        ln -snf "$src" "$dest"
    done
    ln -snf "$WROOT/plugins" $HOME/.plugins
}

config_vim() {
    if [[ -e $HOME/.vim ]]; then
        echo "vim is already configured"
    else
        mkdir -p $HOME/.vim
        git clone https://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
        ln -snf "$WROOT/configs/vimrc" $HOME/.vimrc
        vim +PluginInstall +qall
        cd $HOME/.vim/bundle/YouCompleteMe/ && ./install.py && cd -
    fi
}

config_neovim() {
    if [[ -e $HOME/.config/nvim/lua/custom ]]; then
        echo "vim is already configured"
    else
        git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
        ln -snf $WROOT/configs/nvchad ~/.config/nvim/lua/custom
    fi
}

config_zsh() {
    if [[ -e $HOME/.oh-my-zsh ]]; then
        echo "zsh is already configured"
    else
        git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM:=$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"
    fi
    ln -snf "$WROOT/configs/zshrc" $HOME/.zshrc
}

main() {
    install_tools
    config_tools
    config_vim
    config_neovim
    config_zsh
}

main
