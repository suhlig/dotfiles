# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

for brew_home in "$HOME/.linuxbrew" /home/linuxbrew/.linuxbrew; do
  if [[ -d "$brew_home" ]]; then
    export PATH="$brew_home/bin:$PATH"
    export MANPATH="$brew_home/share/man:$MANPATH"
    export INFOPATH="$brew_home/share/info:$INFOPATH"
  fi
done

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="robbyrussell"
ZSH_THEME="spaceship"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  battery
  boot2docker
  chruby
  colored-man-pages
  colorize
  docker
  docker-compose
  docker-machine
  fasd
  git-prompt
  github
  golang
  gpg-agent
  jsontools
  kubectl
  minikube
  npm
  osx
  pass
  postgres
  python
  rake
  ruby
  thor
  tmux
  tmuxinator
  vagrant
  zsh_reload
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"

# IBM Cloud CLI
source /usr/local/Bluemix/bx/zsh_autocomplete
alias wsk='bx wsk'

# git
alias gd='git diff'
alias gdc='git diff --cached'
alias g='git status'
alias gpr='git pull --rebase'

# ruby
alias be='bundle exec'
alias bi='bundle install'
alias bake='bundle exec rake'

# docker
alias docker-gc-containers="docker ps -a | awk 'NR > 1 {print $1}' | xargs docker rm"
alias ctop='docker run --name ctop -it --rm -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest'

# misc
alias urlencode="ruby -r cgi -e 'puts CGI.escape ARGF.read'"
alias urldecode="ruby -r cgi -e 'puts CGI.unescape ARGF.read'"
alias yaml_pp='ruby -r yaml -r pp -e "pp YAML::load(ARGF.read)"'
alias yaml2json='ruby -r yaml -r json -e "puts YAML::load(ARGF.read).to_json"'
alias serve='ruby -r webrick -e "s = WEBrick::HTTPServer.new(:Port => 3000, :DocumentRoot => ARGV[0] || Dir.pwd); trap(\"INT\") { s.shutdown }; s.start"'
alias now='date "+%Y-%m-%d_%H%M"'
eval "$(direnv hook zsh)"
eval "$(fasd --init posix-alias zsh-hook)"
