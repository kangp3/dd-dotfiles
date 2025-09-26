export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

set -o promptsubst
if [ $(id -u) -ne 0 ]
then
    export PS1='%B%F{red}workspace %F{blue}$(
        if [[ ${PWD#*/dd-source/domains/dashboardsnotebooks_backend} != $PWD ]]; then echo DBB${PWD#*/dd-source/domains/dashboardsnotebooks_backend}
        elif [[ ${PWD#*/dd-source} != $PWD ]]; then echo DDS${PWD#*/dd-source}
        elif [[ ${PWD#*/web-ui/services/multiplayer-notebook-worker} != $PWD ]]; then echo MULT${PWD#*/web-ui/services/multiplayer-notebook-worker}
        elif [[ ${PWD#*/web-ui} != $PWD ]]; then echo WEB${PWD#*/web-ui}
        elif [[ ${PWD#*/dogweb} != $PWD ]]; then echo DW${PWD#*/dogweb}
        elif [[ ${PWD#*/experimental} != $PWD ]]; then echo EXP${PWD#*/experimental}
        elif [[ ${PWD#*/k8s-resources} != $PWD ]]; then echo K8S${PWD#*/k8s-resources}
        elif [[ ${PWD#*/terraform-config} != $PWD ]]; then echo TF${PWD#*/terraform-config}
        elif [[ ${PWD#*/datadog-api-spec} != $PWD ]]; then echo DOC${PWD#*/datadog-api-spec}
        else echo %~; fi
    ) %F{red}$ %b%F{reset}'
fi

alias vim="nvim"
alias dds='cd ~/dd/dd-source'
alias dbb='cd ~/dd/dd-source/domains/dashboardsnotebooks_backend/'
alias dw='cd ~/dd/dogweb/'
alias web='cd ~/dd/web-ui/'
alias doc='cd ~/dd/datadog-api-spec/'
alias attach="tmux setenv SSH_AUTH_SOCK $SSH_AUTH_SOCK; tmux attach -t 0"
alias fixssh='eval $(tmux show-env | grep SSH_AUTH)'
alias ddpip='rake python:compile_requirements && rake python:get_deps'
alias dd-compose='docker-compose -f $DATADOG_ROOT/compose.yaml'

alias dashbooks-staging="kubectl exec --context gizmo.us1.staging.dog --namespace orgstore-dashbooks -it deployment/orgstore-dashbooks-toolbox -- pg-wrap -o dashbooks psql"
alias dashbooks-us1="kubectl exec --context psyduck.us1.prod.dog --namespace orgstore-dashbooks -it deployment/orgstore-dashbooks-toolbox -- pg-wrap -o dashbooks psql"
alias dashbooks-eu1="kubectl exec --context babar.eu1.prod.dog --namespace orgstore-dashbooks -it deployment/orgstore-dashbooks-toolbox -- pg-wrap -o dashbooks psql"
alias dashbooks-ap1="kubectl exec --context whiscash.ap1.prod.dog --namespace orgstore-dashbooks -it deployment/orgstore-dashbooks-toolbox -- pg-wrap -o dashbooks psql"
alias dashbooks-us3="kubectl exec --context torkoal.us3.prod.dog --namespace orgstore-dashbooks -it deployment/orgstore-dashbooks-toolbox -- pg-wrap -o dashbooks psql"
alias dashbooks-us5="kubectl exec --context nidoking.us5.prod.dog --namespace orgstore-dashbooks -it deployment/orgstore-dashbooks-toolbox -- pg-wrap -o dashbooks psql"

alias dogweb-staging-psql="kbash -n dogq --context gizmo.us1.staging.dog dogq psql-dogweb-backend"
alias dogweb-us1-psql="kbash -n dogq --context general2.us1.prod.dog dogq psql-dogweb-backend"
alias dogweb-us3-psql="kbash -n dogq --context plain4.us3.prod.dog dogq psql-dogweb-backend"
alias dogweb-us4-psql="kbash -n dogq --context wurmple.us4.prod.dog dogq psql-dogweb-backend"
alias dogweb-us5-psql="kbash -n dogq --context hypno.us5.prod.dog dogq psql-dogweb-backend"
alias dogweb-eu1-psql="kbash -n dogq --context spirou.eu1.prod.dog dogq psql-dogweb-backend"
alias dogweb-ap1-psql="kbash -n dogq --context nidorino.ap1.prod.dog dogq psql-dogweb-backend"

function gm() {
    repo="$(git rev-parse --show-toplevel | awk -F'/' '{print $(NF)}')"
    case $repo in
        k8s-resources)
            echo master
            ;;
        dogweb)
            echo prod
            ;;
        dd-source)
            echo main
            ;;
        web-ui)
            echo preprod
            ;;
        experimental)
            echo main
            ;;
        *)
            >&2 echo "unknown repo '$repo'"
            ;;
    esac
}

function gh () {
    repo="$(basename $(git rev-parse --show-toplevel))"
    commit="$(git rev-parse --short HEAD)"
    echo "https://github.com/DataDog/$repo/tree/$commit${$(realpath ${1:-$PWD})#*${repo}}"
}

export PAGER=

source /home/bits/.config/dogweb.shellrc
