# If you come from bash you might have to change your $PATH.
export PATH=~/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

SPACESHIP_KUBECTL_SHOW=true
SPACESHIP_KUBECTL_CONTEXT_SHOW=true
SPACESHIP_IBMCLOUD_SHOW=true
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_FORMAT='%D{%Y-%m-%d %H:%M:%S.%.}'
SPACESHIP_DIR_TRUNC_REPO=false
SPACESHIP_PROMPT_DEFAULT_PREFIX=
SPACESHIP_GIT_PREFIX=

SPACESHIP_PROMPT_ORDER=(
    user          # Username section
    dir           # Current directory section
    host          # Hostname section
    git           # Git section (git_branch + git_status)
    ruby          # Ruby section
    golang        # Go section
    rust          # Rust section
    docker        # Docker section
    kubectl       # Kubectl context section
    exec_time     # Execution time
    time          # Time stamps section
    line_sep      # Line break
    battery       # Battery level and status
    jobs          # Background jobs indicator
    exit_code     # Exit code section
    char          # Prompt character
  )

if type brew > /dev/null 2>&1; then
  source $(brew --prefix)/opt/spaceship/spaceship.zsh
fi

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  autoupdate
  chruby
  colored-man-pages
  colorize
  git-prompt
  github
  golang
  python
  rake-fast
  rust
  vagrant
  zsh-autosuggestions
  zsh-vi-mode
  zsh-syntax-highlighting
)

[ -f "$ZSH"/oh-my-zsh.sh ] && source "$ZSH"/oh-my-zsh.sh

autoload bashcompinit
bashcompinit

# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
if type brew > /dev/null 2>&1; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# load common and zsh-specific profile settings
find -L ~/.zsh_profile.d ~/.profile.d ~/.zsh_completion.d -type f | while read file; do
  source "$file"
done

# Restore custom history search
# https://github.com/jeffreytse/zsh-vi-mode/issues/127#issuecomment-930104572
function zvm_after_init() {
  if type atuin >/dev/null 2>&1; then
    bindkey '^r' _atuin_search_widget
  fi
}

# must be the last line
if type brew > /dev/null 2>&1; then
  if [ -f $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi
fi

