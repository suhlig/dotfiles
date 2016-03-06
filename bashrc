# exports
export VISUAL=vi
export GEM_EDITOR='vi'

# Prefer US English and use UTF-8
LC_ALL="en_US.UTF-8"
LANG="en_US.UTF-8"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# teach git about GitHub
if type -t hub 2>&1 >/dev/null; then
  eval "$(hub alias -s)"
fi

# load bash profile additions and completions
for bash_dir in /usr/local/etc/bash_completion.d ~/.{bash_completion.d,bash_profile.d}; do
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
