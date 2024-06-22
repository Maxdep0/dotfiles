export LSCOLORS="exfxcxdxbxegedabagacad"
export CLICOLOR=1

if [ ! -d "$HOME/.zsh-plugins" ]; then
    mkdir -p "$HOME/.zsh-plugins"
fi

if [ ! -d "$HOME/.zsh-plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh-plugins/zsh-autosuggestions
    echo 'zsh-autosuggestions installed'
fi

if [ ! -d "$HOME/.zsh-plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh-plugins/zsh-syntax-highlighting
    echo 'zsh-syntax-highlighting installed'
fi

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config ~/.config/wezterm/custom.omp.json)"
fi
