# config kubernetes
export KUBECONFIG=$(for i in ~/.kube/c-*;do echo -n "$i":;done)~/.kube/config
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

kgc() {
  echo $KUBE_PROFILE
}

kgn() {
  echo $KUBE_NAMESPACE
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
