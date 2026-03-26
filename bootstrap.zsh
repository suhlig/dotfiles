#!/usr/bin/env zsh

setopt ERR_EXIT NO_UNSET PIPE_FAIL

main() {
  update-repo
  check-prerequisites
  check-suggestions
  upsert-antidote
  remove-defaults
  stow-dotfiles
}

update-repo() {
  git pull --rebase
}

check-prerequisites() {
  local prerequisites=(
    git
    stow
    zsh
  )

  local missing=0

  for p in $prerequisites; do
    if (( ! $+commands[$p] )); then
      missing=1
      print -u2 "Error: Required tool $p missing."
    fi
  done

  if (( missing )); then
    exit 1
  fi
}

check-suggestions() {
  local suggestions=(
    atuin
    starship
    tmux
  )

  local -a missing
  missing=()

  for s in $suggestions; do
    (( $+commands[$s] )) || missing+=($s)
  done

  if (( $#missing )); then
    print "Consider installing ${(j:, :)missing} to improve the zsh experience."
  fi
}

upsert-antidote() {
  local antidote_dir="${ZDOTDIR:-$HOME}/.antidote"

  if [[ -d $antidote_dir/.git ]]; then
    git -C $antidote_dir pull
  elif [[ ! -d $antidote_dir ]]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git $antidote_dir
  fi
}

remove-defaults() {
  local defaults=(
    .bashrc
    .config/atuin/config.toml
    .profile
    .zshrc
  )

  for c in $defaults; do
    [[ -e ~/$c ]] && rm ~/$c
  done
}

stow-dotfiles() {
  local platform
  platform=$(detect-platform) || exit 1
  stow common $platform
}

detect-platform() {
  case "$OSTYPE" in
    linux*)
      print "linux"
      ;;
    darwin*)
      print "osx"
      ;;
    cygwin*|msys*|win32*)
      print "windows"
      ;;
    *)
      print -u2 "Error: Unsupported operating system '$OSTYPE'"
      return 1
      ;;
  esac
}

main
