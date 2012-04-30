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
source "`brew --prefix grc`/etc/grc.bashrc"

# Load RVM into a shell session *as a function*
[[ -s "~/.rvm/scripts/rvm" ]] && source "~/.rvm/scripts/rvm"
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# exports
export VISUAL=vi
export GEM_EDITOR='vi'
export HISTSIZE=1000000
export HISTFILESIZE=1000000000

# teach git about GitHub
eval "$(hub alias -s)"

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

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Prefer US English and use UTF-8
export LC_ALL="en_US.UTF-8"
export LANG="en_US"

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2)" scp sftp ssh

#
# EOF
#