[ -f "$HOME/.profile.d/add-bin-to-path" ] && source "$HOME/.profile.d/add-bin-to-path"
[ -f "$HOME/.atuin/bin/env" ] && source "$HOME/.atuin/bin/env"

# Make Homebrew available to non-interactive shells (e.g. GUI apps)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Make nvm-managed Node available to non-interactive shells (e.g. GUI apps)
() {
  local default=$(<~/.nvm/alias/default) 2>/dev/null || default="node"

  # If default is an alias itself (like lts/* or lts/krypton), resolve it
  if [[ -s ~/.nvm/alias/$default ]]; then
    default=$(<~/.nvm/alias/$default)
  fi

  local node_path
  if [[ "$default" == "node" ]]; then
    node_path=(~/.nvm/versions/node/v*(Nn[-1]))
  else
    node_path=(~/.nvm/versions/node/v${default#v}*(Nn[-1]))
  fi

  if [[ -d "$node_path/bin" ]]; then
    export PATH="$node_path/bin:$PATH"
  fi
}
