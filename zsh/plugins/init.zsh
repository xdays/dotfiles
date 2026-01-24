# prezto module init: load all plugin scripts in lexical order.
load_dotfile_plugins() {
  local module_dir=${${(%):-%x}:A:h}
  local plugin

  for plugin in "${module_dir}"/*.sh(N-.); do
    [[ "$plugin" == */init.zsh ]] && continue
    source "$plugin"
  done
}

load_dotfile_plugins
unset -f load_dotfile_plugins
