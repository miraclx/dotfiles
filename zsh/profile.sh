export ZLE_RPROMPT_INDENT=0

eval "$(zoxide init zsh)"

if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# --- end --- #
