# config kubernetes
export KUBECONFIG=$(for i in ~/.kube/c-*;do echo -n "$i":;done)~/.kube/config
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

kubectl() {
    if [ -e ~/workspace/bin/kubectl ]; then
        CMD=~/workspace/bin/kubectl
    else
        CMD=$BREW_BIN/kubectl
    fi
    $CMD --context="$KUBE_PROFILE" --namespace "$KUBE_NAMESPACE" "$@"
}

helm() {
    if [ -e ~/workspace/bin/helm ]; then
        CMD=~/workspace/bin/helm
    else
        CMD=$BREW_BIN/helm
    fi
    $CMD --kube-context="$KUBE_PROFILE" "$@"
}

egp() {
  echo $KUBE_PROFILE
}

kns() {
  export KUBE_NAMESPACE=${1:-default}
}

kjl() {
    kubectl logs $(kubectl get pods -a --selector=job-name="$1" --output='jsonpath={.items..metadata.name}')
}

krc() {
    for context in $(kubectl config get-contexts | grep arn | sed 's/*//' | awk '{print $1}'); do
        if echo "$context" | grep -q '/'; then
            new=$(echo "$context" | awk -F '/' '{print $2}')
            echo kubectl config rename-context "$context" "$new"
        else
            echo "$context is good"
        fi
    done
}

kexe() {
    cmd=${2:-"bash"}
    kubectl exec -it "$1" -- "$cmd"
}
