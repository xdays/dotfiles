opon() {
  if [[ -z $OP_SESSION_$1 ]]; then
    eval $(op signin --account $1)
  fi
}

opoff() {
  op signout
  unset OP_SESSION_$1
}

getpwd() {
  opon
  op item get "$1" |jq -r '.details.fields[] |select(.designation=="password").value'
  opoff
}

# eval "$(op completion zsh)"
