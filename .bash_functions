# Ensure that the function start with the word 'function' and end with '()" so
# that the alias list function (lf) parses the function correctly.

function count(){ echo $(ls $1 | wc -l); }

function getcom() {
  printf "$(curl -s "https://api.github.com/repos/$1/commits" | jq -r '.[0].sha' | head -c 7)\n"
}

function getrev() {
  printf "$(curl -s 'https://grafana.com/api/dashboards/$1/revisions' | jq -r '.items| length')\n"
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

# Make a temporary directory and enter it
function tmpd() {
  local dir
  if [ $# -eq 0 ]; then
    dir=$(mktemp -d)
  else
    dir=$(mktemp -d -t "${1}.XXXXXXXXXX")
  fi
  cd "$dir" || exit
}

# Create a data URL from a file
function dataurl() {
  local mimeType
  mimeType=$(file -b --mime-type "$1")
  if [[ $mimeType == text/* ]]; then
    mimeType="${mimeType};charset=utf-8"
  fi
  echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')"
}

# Create a git.io short URL
function gitio() {
  if [ -z "${1}" ] || [ -z "${2}" ]; then
    echo "Usage: \`gitio slug url\`"
    return 1
  fi
  curl -i https://git.io/ -F "url=${2}" -F "code=${1}"
}

# Compare original and gzipped file size
function gz() {
  if [ -z "${1}" ]; then
    echo "Usage: \`gz file\`"
    return 1
  fi
  local origsize
  origsize=$(wc -c < "$1")
  local gzipsize
  gzipsize=$(gzip -c "$1" | wc -c)
  local ratio
  ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)
  printf "orig: %d bytes\\n" "$origsize"
  printf "gzip: %d bytes (%2.2f%%)\\n" "$gzipsize" "$ratio"
}
