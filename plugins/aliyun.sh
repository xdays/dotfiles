if which aliyun > /dev/null 2>&1; then
    complete -C aliyun aliyun
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -F aliyun aliyun
fi

ecs-list() {
    for i in `aliyun ecs DescribeRegions | jq '.Regions.Region[] | .RegionId' |sed 's/"//g'`; do
        aliyun ecs DescribeInstances --region $i |  jq '.Instances.Instance[]|{status: .Status, id: .InstanceId}'
    done
}
