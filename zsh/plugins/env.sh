# env helpers - manage AWS profile and kube context with state persistence

ENV_STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/e-state"
[ -d "$(dirname "$ENV_STATE_FILE")" ] || mkdir -p "$(dirname "$ENV_STATE_FILE")"

_env_save_state() {
  cat >| "$ENV_STATE_FILE" <<EOF
export AWS_PROFILE="$AWS_PROFILE"
export KUBE_PROFILE="$KUBE_PROFILE"
export KUBE_NAMESPACE="$KUBE_NAMESPACE"
EOF
}

_env_load_state() {
  if [ -f "$ENV_STATE_FILE" ]; then
    . "$ENV_STATE_FILE"
    if [ -n "$KUBE_PROFILE" ]; then
      kubectl config use-context "$KUBE_PROFILE" 2>/dev/null
    fi
    if [ -n "$KUBE_NAMESPACE" ]; then
      kubectl config set-context --current --namespace="$KUBE_NAMESPACE" 2>/dev/null
    fi
  fi
}

# env switcher
# usage: goenv [dev|staging|prod]
goenv() {
  if [ -z "$1" ]; then
    echo "AWS_PROFILE:    ${AWS_PROFILE:-<not set>}"
    echo "KUBE_CONTEXT:   ${KUBE_PROFILE:-<not set>}"
    echo "KUBE_NAMESPACE: ${KUBE_NAMESPACE:-<not set>}"
    return 0
  fi

  case "$1" in
    dev)
      export AWS_PROFILE="loop-staging"
      export KUBE_PROFILE="dev-firework"
      ;;
    staging)
      export AWS_PROFILE="loop-staging"
      export KUBE_PROFILE="staging-firework"
      ;;
    prod)
      export AWS_PROFILE="loop-prod"
      export KUBE_PROFILE="prod-firework"
      ;;
    *)
      echo "usage: goenv [dev|staging|prod]"
      return 1
      ;;
  esac

  kubectl config use-context "$KUBE_PROFILE"
  ksn "default"
  _env_save_state
  echo "AWS_PROFILE=$AWS_PROFILE"
  echo "KUBE_CONTEXT=$KUBE_PROFILE"
  echo "KUBE_NAMESPACE=$KUBE_NAMESPACE"
}

# load state on shell startup
_env_load_state
