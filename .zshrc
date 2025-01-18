export PATH="$PATH:/opt/nvim-linux64/bin"

set -o promptsubst
if [ $(id -u) -ne 0 ]
then
    export PS1='%B%F{red}workspace %F{blue}$(if [[ ${PWD#*/dd/dd-source/domains/dashboardsnotebooks_backend} != $PWD ]]; then echo DBB${PWD#*/dd/dd-source/domains/dashboardsnotebooks_backend}; else echo %~; fi) %F{red}$ %b%F{reset}'
fi

alias vim="nvim"
alias dds='cd ~/dd/dd-source'
alias dbb='cd ~/dd/dd-source/domains/dashboardsnotebooks_backend/'
alias dw='cd ~/dd/dogweb/'

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

function gh () {
    repo="$(basename $(git rev-parse --show-toplevel))"
    commit="$(git rev-parse --short HEAD)"
    echo "https://github.com/DataDog/$repo/tree/$commit${$(realpath ${1:-$PWD})#*${repo}}"
}

source /home/bits/.config/dogweb.shellrc
