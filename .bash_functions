# Ensure that the function start with the word 'function' and end with '()" so
# that the alias list function (lf) parses the function correctly.

function count(){ echo $(ls $1 | wc -l); }

function getcom() {
    curl --silent "https://api.github.com/repos/$1/commits" | jq -r '.[0].sha' | head -c 7
}

function getrev() {
    curl --silent "https://grafana.com/api/dashboards/$1/revisions" | jq -r '.items| length'
}

function dtags () {
    local image="${1}"
    wget -q https://registry.hub.docker.com/v2/repositories/"${image}"/tags/list -O - \
        | tr -d '[]" ' | tr '}' '\n' | awk -F: '{print $3}'
}

function getver() {
    curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

function mkcdir (){
    mkdir -p -- "$1" &&
    cd -P -- "$1"
}

if command -v kubectl &> /dev/null; then
    function setns(){
        kubectl config set-context --current --namespace=$1
    }
fi

function kubectlgetall {
  for i in $(kubectl api-resources --verbs=list --namespaced -o name | grep -v "events.events.k8s.io" | grep -v "events" | sort | uniq); do
    echo "Resource:" $i
    kubectl -n ${1} get --ignore-not-found=true ${i}
  done
}

function ssd(){
    echo "Device         Total  Used  Free   Pct MntPoint"
    df -h | grep "/dev/sd"
    df -h | grep "/mnt/"
}

function clone(){
    cd ~/git
    git clone git@github.com:$1.git $1
    cd $1
}

function showpkg(){
    apt-cache $1 | grep -i "$1" | sort;
}

if command -v git &> /dev/null; then
    function gc(){ git commit -m "$*"; }
fi

# Because I am a lazy bum, and this is
# surpisingly helpful..
function up(){
    for i in `seq 1 $1`; do
        cd ../
    done;
}
