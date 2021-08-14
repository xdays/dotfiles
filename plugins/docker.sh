# docker alias
which kubectl.docker >/dev/null 2>&1 && rm "$(which kubectl.docker)"
alias dps='docker ps'
alias dmg='docker images'
alias denv='eval $(docker-machine env default)'

# docker functions
daddr() {
    docker inspect --format="{{.NetworkSettings.IPAddress}}" $1
}

duri() {
    export DOCKER_HOST=tcp://10.50.0.$1:${2:-2375}
}

denter() {
    cmd=${2:-bash}
    docker exec -it "$1" "$cmd"
}

dmount() {
    container=$1
    container_pool=`dmsetup ls | grep pool | cut -f1`
    container_id=`docker inspect --format='{{.Config.Hostname}}' $container`
    device_id=`docker inspect --format='{{.GraphDriver.Data.DeviceId}}' $container`
    device_size=`docker inspect --format='{{.GraphDriver.Data.DeviceSize}}' $container`
    container_path=/tmp/$container_id
    dmsetup create $container_id --table "0 $(($device_size/512))thin /dev/mapper/$pool $device_id"
    [ -e /tmp/$container_path ] || mkdir /tmp/$container_path
    mount /dev/mapper/$container_path /tmp/$container_path
}

dcclean() {
    docker container prune -f
}

dmclean() {
    docker image prune -f
}
