# exports
export VISUAL=vi
export GEM_EDITOR='vi'

#
# Option 3 of http://unix.stackexchange.com/a/18443
#
export HISTSIZE=1000000
export HISTFILESIZE=1000000000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"

# Add local bin folder to PATH
[[ -s ~/.local/bin ]] && export PATH=$PATH:~/.local/bin

#
# This section from https://github.com/mathiasbynens/dotfiles/
#

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Prefer US English and use UTF-8
LC_ALL="en_US.UTF-8"
LANG="en_US.UTF-8"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Source misc. scripts
if type -t brew 2>&1 >/dev/null; then
  # grc - frontend for generic colouriser grcat(1)
  source "`brew --prefix grc`/etc/grc.bashrc"
fi

# teach git about GitHub
if type -t hub 2>&1 >/dev/null; then
  eval "$(hub alias -s)"
fi

# load bash profile additions and completions
for bash_dir in ~/.{bash_completion.d,bash_profile.d}; do
  if [ -d "$bash_dir" ]; then
    for local_file in "$bash_dir"/*; do
      source "$local_file"
    done
  fi
done

# load local overrides and additions
for local_dir in ~/.local/.{bash_completion.d,bash_profile.d}; do
  if [ -d "$local_dir" ]; then
    for local_file in "$local_dir"/*; do
      source "$local_file"
    done
  fi
done
