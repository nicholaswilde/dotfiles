# Check if command exists
function command_exists(){
  command -v "${1}" &> /dev/null
}

# Check is variable is null
function is_null {
  [ -z "$1" ]
}

# Check if directory exists
function dir_exists(){
  [ -d "${1}" ]
}

# Check if file exists
function file_exists(){
  [ -f "{1}" ]
}

# nano
if [ -f "${HOME}/.nanorc" ]; then
  # don't allow tabs
  alias utab="sed '/^#.*tabstospaces/s/^#//' -i ~/.nanorc"
  # allow tabs
  alias tab="sed '/^set tabstospaces/s/^/#/' -i ~/.nanorc"
fi

# pass
if command_exists pass; then
  # main is the name of the repo branch
  alias passpull='pass git pull origin main'
  alias passpush='pass git push -u --all'
fi

if command_exists shred; then
  # Remove the file by default
  alias shred='shred -u'
fi

if command_exists fping; then
	alias pingall='fping -l 192.168.1.202 192.168.1.203 192.168.1.189 192.168.1.195 192.168.1.199 192.168.1.172 192.168.1.201'
fi

#boinc-client
if command_exists boinccmd; then
  alias getstate='boinccmd --get_state'
  alias gettasks='boinccmd --get_tasks'
  alias getoldtasks='boinccmd --get_old_tasks'
fi

# ansible
if command_exists ansible; then
  alias ap='ansible-playbook'
  alias rebootcluster='ansible k3s_cluster -a "reboot" -b'
fi

# Apt
if command_exists apt-get; then
  alias apt-get='sudo apt-get'
  alias upgrate='sudo apt-get update && sudo apt-get -y upgrade && brew update && sudo snap refresh && sudo npm update -g'
  alias cleanup='sudo apt-get autoremove -y && sudo apt-get autoclean'
  alias install='sudo apt-get install -y'
  alias remove='sudo apt-get remove'
  alias purge='sudo apt-get remove --purge'
fi

#openports
alias openports='sudo lsof -i -P -n | grep LISTEN'

#Python
if [ -x /usr/bin/python3.7 ]; then
    alias python='/usr/bin/python3.7'
fi
if [ -x /usr/bin/pip3 ]; then
    alias pip='/usr/bin/pip3'
fi

# Find files
alias search='sudo find / -name'
alias fhere='find . -name'

# Navigation
alias ls='ls --sort=extension --color=auto'
alias sl='ls --sort=extension --color=auto' # Typo
alias lsl='ls -lhFA | less' # Long format
alias ll='ls -lh'c
alias lal='ls -alh'
alias la='ls -A'
alias l='ls -CF'
alias cd..='cd ..'
alias ..='cd ..'
alias back='cd "$OLDPWD"'

# System
alias pms='sudo pm-suspend'
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'

# pydf
if command_exists pydf; then
	alias df='pydf -ha'
fi

alias du='du -ach | sort -h'
alias free='free -mt'
alias ps='ps auxf'
alias histg='history | grep'

# Change to using htop
if command_exists htop; then
	alias top='htop'
fi

# Editor
if command_exists nano; then
  alias sn='sudo nano'
  alias n='nano'
fi

# List our functions
alias lf='cat ~/.bash_functions|grep -o -P "(?<=function ).*(?=\(\))"'

# Cool colors for man pages
alias man="TERMINFO=~/.terminfo TERM=mostlike LESS=C PAGER=less man"

# Enable color support of ls and also add handy aliases
if dir_exists /usr/bin/dircolors; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# This one is to take care of make
# Give me a nice, distinguishable make output
if command_exists make; then
	alias make='clear && make'
	alias m='make'
	alias smi='sudo make install'
fi

# File attributes
alias rm='rm -rf'
alias cp='cp -r'
alias mv='mv -i'
alias mkdir='mkdir -pv' # Parent directories

# Downloads
if command_exists wget; then
    alias wget='wget -c'
fi

# Git Commands
if command_exists git; then
	alias gpo='git push origin main'
	alias gp='git pull origin main'
	alias gs='git status'
	alias gd='git diff'
	alias gr='git reflog'
	alias glf='git ls-files'
	alias ga='git add'
	alias revert='git reset --hard'
  alias gc='git commit -s -m'
fi

# Color the output of cat
if command_exists pygmentize; then
    alias catc='pygmentize -O style=friendly -g' # sudo apt-get install python3-pygments
fi

# Get my public ip
alias myip='curl http://ipecho.net/plain; echo'

# Change the default go
if command_exists go1.15.2; then
  alias go='go1.15.2'
fi

# Docker
if command_exists docker; then
  alias dc='docker-compose'
  # Restart builder https://github.com/nicholaswilde/docker-template/wiki/Troubleshooting#restart-buildkit
  alias dr='docker restart buildx_buildkit_mybuilder0'
fi

# kubectl
if command_exists kubectl; then
    alias k=kubectl
    alias ke='kubectl edit'
    alias kg='kubectl get'
    alias kd='kubectl describe'
    alias kgp='kubectl get pods'
    alias kgn='kubectl get namespaces'
    alias kga='kubectl get all'
    alias kgi='kubectl get ingress'
    alias kl='kubectl logs'
    alias kdesc='kubectl describe'
    alias kdel='kubectl delete'
    alias wkp='watch kubectl get pods'
    alias wkns='watch kubectl get ns'
    alias wka='watch kubectl get all'
    alias getkubeconfig='scp pirate@192.168.1.201:~/.kube/config ~/.kube/config-turing-pi'
    alias restartpod='kubectl rollout restart deployment'
    alias geting="kubectl get all -n kube-system | grep '^service/traefik ' | awk '{print \$4}'"
fi

alias ea='nano ~/.bash_aliases'
alias ee='nano ~/.bash_exports'
alias ef='nano ~/.bash_functions'
# Quickly load bashrc
alias reload='source ~/.bashrc && git -C /home/nicholas/git/dotfiles commit --allow-empty-message -a -m ""; git -C /home/nicholas/git/dotfiles push origin main'
