# config kubernetes
export KUBECONFIG=$(for i in ~/.kube/c-*;do echo -n "$i":;done)~/.kube/config
export KUBE_EDITOR="vim"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

helm() {
    if [ -e ~/workspace/bin/helm ]; then
        CMD=~/workspace/bin/helm
    else
        CMD=/usr/local/bin/helm
    fi
    $CMD --kube-context="$KUBE_PROFILE" "$@"
}

kube_log() {
    kubectl logs $(kubectl get pods -a --selector=job-name="$1" --output='jsonpath={.items..metadata.name}')
}

kube_context() {
    for context in $(kubectl config get-contexts | grep arn | sed 's/*//' | awk '{print $1}'); do
        if echo "$context" | grep -q '/'; then
            new=$(echo "$context" | awk -F '/' '{print $2}')
            echo kubectl config rename-context "$context" "$new"
        else
            echo "$context is good"
        fi
    done
}

kenter() {
    cmd=${2:-"bash"}
    kubectl exec -it "$1" -- "$cmd"
}

kube_pods() {
    for i in `kubectl get nodes | awk '{print $1}'`;do
        kubectl describe node $i | sed '1,/  Namespace/d' | sed '/Allocated resources/,$d' | grep -v '\----'
    done
}
