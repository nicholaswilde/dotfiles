# Ensure that the function start with the word 'function' and end with '()" so
# that the alias list function (lf) parses the function correctly.

function count(){ echo $(ls $1 | wc -l); }

function targz() { tar -zcvf $( $1 | cut -f 1 -d '.').tar.gz $1; rm -r $1; }

function getcom() {
  if [ -z "${1}" ]; then
    echo "Usage: \`getcom user/repo\`"
    return 1
  fi
  printf "$(curl -s "https://api.github.com/repos/${1}/commits" | jq -r '.[0].sha' | head -c 7)\n"
}

function getver() {
  if [ -z "${1}" ]; then
    echo "Usage: \`getver user/repo\`"
    return 1
  fi
  curl -s "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
  grep '"tag_name":' |                                        # Get tag line
  sed -E 's/.*"([^"]+)".*/\1/'                                # Pluck JSON value
}

function mkcdir() {
  if [ -z "${1}" ]; then
    echo "Usage: \`mkcdir dirname\`"
    return 1
  fi
  mkdir -p -- "$1" &&
  cd -P -- "$1"
}

if command -v kubectl &> /dev/null; then
  function setns(){
    kubectl config set-context --current --namespace=$1
  }
fi

function kubectlgetall() {
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

function showpkg() {
  apt-cache $1 | grep -i "$1" | sort;
}

if command -v git &> /dev/null; then
  function gc(){ git commit -m "$*"; }
fi

# Because I am a lazy bum, and this is
# surpisingly helpful..
function up() {
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
  local bzipsize
  bzipsize=$(bzip2 -c "$1" | wc -c)
  local ratio
  local ratio2
  ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l)
  ratio2=$(echo "$bzipsize * 100 / $origsize" | bc -l)
  printf "orig:  %d bytes\\n" "$origsize"
  printf "gzip:  %d bytes (%2.1f%%)\\n" "$gzipsize" "$ratio"
  printf "bzipz: %d bytes (%2.1f%%)\\n" "$bzipsize" "$ratio2"
}

function dcleanup(){
  local containers
  mapfile -t containers < <(docker ps --filter status=exited -q 2>/dev/null)
  docker rm "${containers[@]}" 2>/dev/null
  local images
  mapfile -t images < <(docker images --filter dangling=true -q 2>/dev/null)
  docker rmi "${images[@]}" 2>/dev/null
}
