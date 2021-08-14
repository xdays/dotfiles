pget() {
    lftp -c "pget -c -n 10 $1"
}

netcall() {
    while true; do
        if ping -c 1 8.8.8.8 2>/dev/null;then
            for i in seq 1 3;do
                say hey man, network is back
                sleep 3
            done
            break
        else
            sleep 5
        fi
    done
}

beep() {
    while true; do
        echo -ne '\007'
        sleep 1
    done
}
