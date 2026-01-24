export VPATH=~/.envs/
alias vl="ls $VPATH"
vn() {
    [ -e $VPATH ] || mkdir $VPATH
    if [ $# -eq 0 ]; then
        echo 'Please specify environment'
    else
        python -m venv $VPATH/$1/
    fi
}
vs() {
    if [ $# -eq 0 ]; then
        echo 'Please specify environment'
    else
        if [ ! -e $VPATH/$1 ]; then
            vn $1
        fi
        source $VPATH/$1/bin/activate
    fi
}
vr() {
    if [ $# -eq 0 ]; then
        echo 'Please specify environment'
    else
        rm -rf $VPATH/$1
    fi
}
alias vd='deactivate'
