for brew_home in "$HOME/.linuxbrew" /home/linuxbrew/.linuxbrew /opt/homebrew; do
  if [[ -d "$brew_home" ]]; then
    export PATH="$brew_home/bin:$PATH"
    export MANPATH="$brew_home/share/man:$MANPATH"
    export INFOPATH="$brew_home/share/info:$INFOPATH"
  fi
done

if type brew &>/dev/null && test -d "$(brew --prefix)/sbin"; then
  export PATH=$PATH:"$(brew --prefix)/sbin"
fi

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

# https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
if type brew > /dev/null 2>&1; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

autoload -Uz compinit
compinit

# load common and zsh-specific profile settings
find -L ~/.zsh_profile.d ~/.profile.d ~/.zsh_completion.d -type f | while read file; do
  source "$file"
done
