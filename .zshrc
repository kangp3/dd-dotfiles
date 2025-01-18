export PATH="$PATH:/opt/nvim-linux64/bin"

set -o promptsubst
if [ $(id -u) -ne 0 ]
then
  export PS1='%B%F{red}workspace %F{blue}$(if [[ ${PWD#*/dd/dd-source/domains/dashboardsnotebooks_backend} != $PWD ]]; then echo DBB${PWD#*/dd/dd-source/domains/dashboardsnotebooks_backend}; else echo %~; fi) %F{red}$ %b%F{reset}'
fi

alias vim="nvim"

source /home/bits/.config/dogweb.shellrc
