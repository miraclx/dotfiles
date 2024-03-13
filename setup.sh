if platform_is darwin; then
  if ! type brew &>/dev/null; then
      echo "Download brew from https://brew.sh/"
      exit 1
    else echo "- \`brew\` is installed"
  fi
fi


if platform_is darwin; then
  if ! xcode-select --install
    then echo "- Xcode Command Line Tools are installed"
  fi
fi

if ! type zsh &>/dev/null; then
    if platform_is darwin
      then echo "Zsh should be installed by default, but I can't find it"
      else echo "Download zsh: https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH#how-to-install-zsh-on-many-platforms"
    fi
    exit 1
  else echo "- \`zsh\` is installed"
fi

if ! type git &>/dev/null; then
    if platform_is darwin
      then echo "Git should've been installed by \`xcode-select --install\`, but I can't find it"
      else echo "Download git: https://git-scm.com/downloads"
    fi
    exit 1
  else echo "- \`git\` is installed"
fi

if [ ! -e zsh/oh-my-zsh ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh zsh/oh-my-zsh
  else echo "- \`oh-my-zsh\` is installed"
fi

if [ ! -e zsh/plugins/alias-tips ]; then
    git clone https://github.com/djui/alias-tips zsh/plugins/alias-tips
  else echo "- \`alias-tips\` is installed"
fi

if [ ! -e zsh/plugins/zsh-autopair ]; then
    git clone https://github.com/hlissner/zsh-autopair zsh/plugins/zsh-autopair
  else echo"- \`zsh-autopair\` is installed"
fi

if [ ! -e zsh/plugins/zsh-interactive-cd ]; then
    git clone https://github.com/changyuheng/zsh-interactive-cd zsh/plugins/zsh-interactive-cd
  else echo"- \`zsh-interactive-cd\` is installed"
fi

if [ ! -e zsh/plugins/zsh-autosuggestions ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions zsh/plugins/zsh-autosuggestions
  else echo"- \`zsh-autosuggestions\` is installed"
fi

if [ ! -e zsh/plugins/fast-syntax-highlighting ]; then
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting zsh/plugins/fast-syntax-highlighting
  else echo"- \`fast-syntax-highlighting\` is installed"
fi

if ! type fzf &>/dev/null; then
    if platform_is darwin
      then brew install fzf
      else
        echo "Download fzf: https://github.com/junegunn/fzf"
        exit 1
    fi
  else echo "- \`fzf\` is installed"
fi

if ! type starship &>/dev/null; then
    if platform_is darwin
      then brew install starship
      else
        echo "Download starship: https://starship.rs/"
        exit 1
    fi
  else echo "- \`starship\` is installed"
fi

if ! type figlet &>/dev/null; then
    if platform_is darwin
      then brew install figlet
      else
        echo "Download figlet: https://github.com/cmatsuoka/figlet"
        exit 1
    fi
  else echo "- \`figlet\` is installed"
fi

if ! type delta &>/dev/null; then
    if platform_is darwin
      then brew install git-delta
      else
        echo "Download delta: https://github.com/dandavison/delta"
        exit 1
    fi
  else echo "- \`delta\` is installed"
fi

if ! type jq &>/dev/null; then
    if platform_is darwin
      then brew install jq
      else
        echo "Download jq: https://github.com/jqlang/jq"
        exit 1
    fi
  else echo "- \`jq\` is installed"
fi

if ! type xh &>/dev/null; then
    if platform_is darwin
      then brew install xh
      else
        echo "Download xh: https://github.com/ducaale/xh"
        exit 1
    fi
  else echo "- \`xh\` is installed"
fi

if ! type fd &>/dev/null; then
    if platform_is darwin
      then brew install fd
      else
        echo "Download fd: https://github.com/sharkdp/fd"
        exit 1
    fi
  else echo "- \`fd\` is installed"
fi

if ! type rg &>/dev/null; then
    if platform_is darwin
      then brew install ripgrep
      else
        echo "Download ripgrep: https://github.com/BurntSushi/ripgrep"
        exit 1
    fi
  else echo "- \`ripgrep\` is installed"
fi

if ! type exa &>/dev/null; then
    if platform_is darwin
      then brew install exa
      else
        echo "Download exa"
        exit 1
    fi
  else echo "- \`exa\` is installed"
fi

if ! type xxd &>/dev/null; then
    if platform_is darwin
      then echo "xxd should be installed by default, but I can't find it"
      else echo "Download xxd"
    fi
    exit 1
  else echo "- \`xxd\` is installed"
fi

if ! type bs58 &>/dev/null; then
  then echo "Download bs58: \`cargo install bs58\`"
  else echo "- \`bs58\` is installed"
fi

if ! type python3 &>/dev/null; then
    if platform_is darwin
      then echo "Python3 should be installed by default, but I can't find it"
      else echo "Download python3"
    fi
    exit 1
  else echo "- \`python3\` is installed"
fi

if ! type nano &>/dev/null; then
    if platform_is darwin
      then brew install nano
      else
        echo "Download nano"
        exit 1
    fi
  else
    if platform_is darwin; then
      if ! brew list nano &>/dev/null; then
          echo "- \`nano\` is installed, but not by brew, overriding"
          brew install nano
      fi
    fi
    echo "- \`nano\` is installed"
fi

if ! type nvm &>/dev/null
  then echo "Download nvm: \`https://github.com/nvm-sh/nvm\`"
  else echo "- \`nvm\` is installed"
fi

if ! type node &>/dev/null
  then nvm install node
  else echo "- \`node\` is installed"
fi

# todo! use node version in profile

if ! type rustup &>/dev/null
  then echo "Download rustup: \`https://rustup.rs/\`"
  else echo "- \`rustup\` is installed"
fi

if ! type rustc &>/dev/null
  then rustup install stable
  else echo "- \`rustc\` is installed"
fi

if platform_is darwin; then
  if ! brew list coreutils &>/dev/null; then
      echo "Download coreutils: \`brew install coreutils\`"
    else echo "- \`coreutils\` is installed"
  fi

  if ! brew list gnu-tar &>/dev/null; then
      echo "Download gnu-tar: \`brew install gnu-tar\`"
    else echo "- \`gnu-tar\` is installed"
  fi
fi

if ! type zoxide &>/dev/null
  if platform_is darwin
    then brew install zoxide
    else
      echo "Download zoxide"
      exit 1
  fi
  else echo "- \`zoxide\` is installed"
fi

if ! type direnv &>/dev/null
  if platform_is darwin
    then brew install direnv
    else
      echo "Download direnv"
      exit 1
  fi
  else echo "- \`direnv\` is installed"
fi

# nice to have
# cloudflared
# ffmpeg
# htop

# --- end --- #
