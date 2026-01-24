if command -v aliyun >/dev/null 2>&1; then
    if aliyun completion zsh >/dev/null 2>&1; then
        source <(aliyun completion zsh)
    fi
fi

ecs-list() {
    for i in `aliyun ecs DescribeRegions | jq '.Regions.Region[] | .RegionId' |sed 's/"//g'`; do
        aliyun ecs DescribeInstances --region $i |  jq '.Instances.Instance[]|{status: .Status, id: .InstanceId}'
    done
}
