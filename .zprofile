# Login shell setup (also used by non-interactive login shells, e.g. editor tasks)

eval "$(/opt/homebrew/bin/brew shellenv)"

# Node: put nvm's default Node ahead of Homebrew's node (which stays only as a brew dependency)
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh" --no-use
  _nvm_default_node="$(nvm which default 2>/dev/null)"
  [ -n "$_nvm_default_node" ] && export PATH="${_nvm_default_node:h}:$PATH"
  unset _nvm_default_node
fi

# Go
command -v go >/dev/null && export GOPATH="$(go env GOPATH)"

# Solana
export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH${GOPATH:+:$GOPATH/bin}"

# Machine-private settings (not in this public repo)
[ -f "$HOME/.zprofile.local" ] && source "$HOME/.zprofile.local"
