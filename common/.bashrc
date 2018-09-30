# exports
export VISUAL=vi
export EDITOR=vi
export GEM_EDITOR='vi'

# Prefer US English and use UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# load common and bash-specific completions
for directory in ~/.completion.d ~/.bash_completion.d; do
  for file in $directory/*; do
    [ -f "$file" ] && source "$file"
  done
done

# load common and bash-specific profile additions
for directory in ~/.profile.d ~/.bash_profile.d; do
  for file in $directory/*; do
    [ -f "$file" ] && source "$file"
  done
done
