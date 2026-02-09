# Prompt with AWS profile, Kubernetes context/namespace, and git branch.

setopt PROMPT_SUBST

precmd() {
    local aws_seg='' k8s_seg='' git_seg=''

    # AWS segment
    if [[ -n "$AWS_PROFILE" ]]; then
        aws_seg="%F{6}[aws:${AWS_PROFILE}]%f "
    fi

    # Kubernetes segment
    if command -v kubectl >/dev/null 2>&1; then
        local kctx=$(kubectl config current-context 2>/dev/null)
        if [[ -n "$kctx" ]]; then
            local kns=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
            [[ -z "$kns" ]] && kns=default
            k8s_seg="%F{5}[k8s:${kctx}/${kns}]%f "
        fi
    fi

    # Git segment with emoji status
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        if [[ -n "$branch" ]]; then
            local git_status=''
            local gs=$(git status --porcelain 2>/dev/null)
            [[ -n $(echo "$gs" | grep '^??' 2>/dev/null) ]] && git_status+='🆕'
            [[ -n $(echo "$gs" | grep '^.[MD]' 2>/dev/null) ]] && git_status+='📝'
            [[ -n $(echo "$gs" | grep '^[MADRC]' 2>/dev/null) ]] && git_status+='✅'
            [[ -z "$gs" ]] && git_status='✨'
            git_seg="%F{2}[git:${branch}${git_status}]%f "
        fi
    fi

    PROMPT="${aws_seg}${k8s_seg}${git_seg}%F{4}%~%f $ "
}
