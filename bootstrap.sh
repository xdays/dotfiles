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
        echo "zsh is already configured"
    else
        git clone https://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-completions "${ZSH_CUSTOM:=$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"
    fi
    ln -snf "$WROOT/zsh/zshrc" $HOME/.zshrc
    ln -snf "$WROOT/zsh/plugins" $HOME/.plugins
}

config_zsh_prezto() {
    if [[ -e $HOME/.zprezto ]]; then
        echo "prezto is already configured"
    else
        git clone --recursive https://github.com/sorin-ionescu/prezto.git $HOME/.zprezto
    fi
    for rcfile in zlogin zlogout zpreztorc zprofile zshenv zshrc; do
        ln -snf "$HOME/.zprezto/runcoms/$rcfile" "$HOME/.${rcfile}"
    done
    mkdir -p $HOME/.zprezto/modules
    ln -snf "$WROOT/zsh/plugins" $HOME/.zprezto/modules/plugins
    if [[ -e "$WROOT/zsh/plugins/functions/prompt_xdays_setup" ]]; then
        mkdir -p $HOME/.zprezto/modules/prompt/functions
        ln -snf "$WROOT/zsh/plugins/functions/prompt_xdays_setup" \
            $HOME/.zprezto/modules/prompt/functions/prompt_xdays_setup
    fi
    echo "To enable custom module: add 'plugins' to zstyle ':prezto:load' pmodule in ~/.zpreztorc"
}

main() {
    local cmd=${1:-}

    case "$cmd" in
        install)
            install_tools
            ;;
        config)
            config_tools
            config_zsh_prezto
            ;;
        "")
            install_tools
            config_tools
            config_zsh_prezto
            ;;
        *)
            echo "usage: $0 [install|config]  (default: run install + config)"
            return 1
            ;;
    esac
}

main "$@"
