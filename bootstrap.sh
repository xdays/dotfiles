#!/bin/bash


export WROOT=$PWD

# install deps
install_tools() {
    if [[ "$(uname)" == "Darwin" ]]; then
        if ! command -v brew &> /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
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
}

config_vim() {
    if [[ -e $HOME/.vim ]]; then
        echo "vim is already configured"
    else
        mkdir -p $HOME/.vim
        git clone https://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
        ln -snf "$WROOT/vim/vimrc" $HOME/.vimrc
        vim +PluginInstall +qall
        cd $HOME/.vim/bundle/YouCompleteMe/ && ./install.py && cd -
    fi
}

config_neovim() {
    if [[ -e $HOME/.config/nvim/lua/custom ]]; then
        echo "vim is already configured"
    else
        git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
        ln -snf $WROOT/vim/nvchad ~/.config/nvim/lua/custom
    fi
}

config_zsh_omz() {
    if [[ -e $HOME/.oh-my-zsh ]]; then
        echo "oh-my-zsh is already configured"
    else
        git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM:=$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"
    fi
    ln -snf "$WROOT/zsh/zshrc" $HOME/.zshrc
    ln -snf "$WROOT/zsh/plugins" $HOME/.plugins
}

config_zsh_zinit() {
    local ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
    if [[ -e $ZINIT_HOME ]]; then
        echo "zinit is already configured"
    else
        mkdir -p "$(dirname $ZINIT_HOME)"
        git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    fi
    ln -snf "$WROOT/zsh/zshrc" $HOME/.zshrc
    ln -snf "$WROOT/zsh/plugins" $HOME/.plugins
}

main() {
    local cmd=${1:-}

    case "$cmd" in
        install)
            install_tools
            ;;
        config)
            config_tools
            config_zsh_zinit
            ;;
        "")
            install_tools
            config_tools
            config_zsh_zinit
            ;;
        *)
            echo "usage: $0 [install|config]  (default: run install + config)"
            return 1
            ;;
    esac
}

main "$@"
