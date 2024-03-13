export W0RK_D1R3CT0RY="$HOME/git"

export EDITOR=nano
export NEAR_ENV=mainnet

if platform_is darwin; then
  # brew likes to prioritized, so we need to manually check and only add if not already in path
  eval "$(/opt/homebrew/bin/brew shellenv | sed -E 's,(export (.*PATH)="(.*)\${.*".*),pathy_has "$\2" "\3" || \1,g')"
fi

export PATH="$(pathadd "$PATH" "$HOME/.local/bin")"

export NVM_NODE_VER="v21.6.0"
export NVM_DIR="$HOME/.nvm"
export NVM_BIN="$NVM_DIR/versions/node/$NVM_NODE_VER/bin"

export PATH="$(pathadd "$PATH" "$HOME/.yarn/bin")"
export PATH="$(pathadd "$PATH" "$NVM_BIN")"

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" --no-use

export NODE_PATH=$(pathadd "$NODE_PATH" "$(realpath "$NVM_BIN/../lib/node_modules")")

if platform_is darwin; then
  export PNPM_HOME="$HOME/Library/pnpm"
  export PATH="$(pathadd "$PATH" "$PNPM_HOME")"
fi

source "$HOME/.cargo/env"

export STARSHIP_CONFIG="$HOME/.dotfiles/configs/starship.toml"

export GPG_TTY="$(tty)"

export WASMTIME_HOME="$HOME/.wasmtime"

export PATH="$(pathadd "$PATH" "$WASMTIME_HOME/bin")"

if platform_is darwin; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

  export PATH="$(pathadd "$PATH" "$HOME/Library/Python/3.8/bin")"

  export PATH="$(pathadd "$PATH" "$HOMEBREW_REPOSITORY/opt/gnu-tar/libexec/gnubin")"

  export PATH="$(pathadd "$PATH" "$HOMEBREW_REPOSITORY/opt/coreutils/libexec/gnubin")"

  export PATH="$(pathadd "$PATH" "/Applications/RustRover 2023.3 EAP.app/Contents/MacOS")"
fi

# --- end --- #
