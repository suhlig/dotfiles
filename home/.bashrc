#
# Global scripts
#
for local_dir in ~/.{bash_completion.d,bash_profile.d}; do
  if [ -d "$local_dir" ]; then
    for local_file in "$local_dir"/*; do
      source "$local_file"
    done
  fi
done

# Source other misc. scripts
if which brew 2>&1 >/dev/null; then
  source "`brew --prefix grc`/etc/grc.bashrc"
fi

# Load RVM into a shell session *as a function*
[[ -s ~/.rvm/scripts/rvm ]] && source ~/.rvm/scripts/rvm
#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Other exports
VISUAL=vi
GEM_EDITOR='vi'
PATH=$HOME/.local/bin:$HOME/bin:$PATH

# teach git about GitHub
if which hub 2>&1 >/dev/null; then
  eval "$(hub alias -s)"
fi

# TMUX
if which tmux 2>&1 >/dev/null; then
  # if no session is started, start a new session
  test -z ${TMUX} && tmux

  # when quitting tmux, try to attach
  while test -z ${TMUX}; do
    tmux attach || break
  done
fi

# load local overrides and additions
for local_dir in ~/.local/.{bash_completion.d,bash_profile.d}; do
  if [ -d "$local_dir" ]; then
    for local_file in "$local_dir"/*; do
      source "$local_file"
    done
  fi
done

#
# This section from https://github.com/mathiasbynens/dotfiles/
#

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Prefer US English and use UTF-8
LC_ALL="en_US.UTF-8"
LANG="en_US"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

#
# Option 3 of http://unix.stackexchange.com/a/18443
#
HISTSIZE=1000000
HISTFILESIZE=1000000000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"
