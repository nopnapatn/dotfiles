# Loaded by every zsh, including non-interactive ones.

# Foundry (forge, cast, anvil)
export PATH="$PATH:$HOME/.foundry/bin"

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# uv and other user tools
export PATH="$HOME/.local/bin:$PATH"
