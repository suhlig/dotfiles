source `brew --prefix`/Library/Contributions/brew_bash_completion.sh
export VISUAL=vi
GEM_EDITOR='vi'

source ~/.git-completion.bash
source ~/.rake-completion.bash
PATH=~/Dropbox/bin:$PATH

alias t=task

mail2kindle () { 
    echo "${1}" | mutt -s "${1}" -a "${1}" -- Steffen.Uhlig@free.kindle.com
}

# Load RVM into a shell session *as a function*
[[ -s "/Users/suhlig/.rvm/scripts/rvm" ]] && source "/Users/suhlig/.rvm/scripts/rvm"

# http://www.cyberciti.biz/faq/bsd-appleosx-linux-bash-shell-run-command-n-times/#comment-60204
# Call like
# repeat 3 echo Hello World
repeat() { local i n; n=$1; shift; for ((i=1; i<=n; i++)); do "$@"; done; }

# teach git about GitHub
eval "$(hub alias -s)"

# open ETN.fm with QuickTime
alias etn.fm="open -a '/Applications/QuickTime Player.app' http://etn.fm/playlists/etn1beta.m3u"

# keep huge history
export HISTSIZE=1000000
export HISTFILESIZE=1000000000

# TMUX
if which tmux 2>&1 >/dev/null; then
	# if no session is started, start a new session
	test -z ${TMUX} && tmux

	# when quitting tmux, try to attach
	while test -z ${TMUX}; do
	  tmux attach || break
	done
fi

source "`brew --prefix grc`/etc/grc.bashrc"


PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
