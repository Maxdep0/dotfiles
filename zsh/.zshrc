if [[ -f "/usr/bin/fd" ]] || [[ -f "$HOME/bin/fd" ]] || [[ -f "$HOME/.local/bin/fd" ]]; then
    alias fdf='fd -H -d 1 -t f'
    alias fdd='fd -H -d 1 -t d'
    alias fda='fd -H -d 1'
else
    echo "fdfind not installed"
fi

alias cl="clear"

alias pacpac="sudo pacman -S --needed"

alias gs="git status"
alias gc="git commit -m"
alias remote="git remote set-url origin git@github.com:Maxdep0/"

alias ft="ranger"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias .dot="cd ~/.config"
alias dot="cd ~/dotfiles"

# cd first so i can use telescope
alias nvimcfg="cd ~/.config/nvim && nvim init.lua"
alias wtcfg="cd ~/dotfiles/wezterm/.config/wezterm && nvim wezterm.lua"
alias swaycfg="cd ~/dotfiles/sway/.config/sway && nvim config"
alias barcfg="cd ~/dotfiles/waybar/.config/waybar && nvim config.jsonc"
alias zshcfg="cd ~/dotfiles/zsh && nvim .zshrc"



autoload -Uz compinit
compinit
zstyle ':completion:*' menu select 
_comp_options+=(globdots)

zstyle ':completion:*' verbose true
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} 'ma=48;5;197;1'
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:warnings' format "%B%F{red}No matches for:%f %F{magenta}%d%b"
zstyle ':completion:*:descriptions' format '%F{yellow}[-- %d --]%f'
zstyle ':vcs_info:*' formats ' %B%s-[%F{magenta}%f %F{yellow}%b%f]-'


autoload -U colors && colors
autoload -U compinit && compinit
autoload -Uz compinit

setopt complete_aliases

setopt NO_BG_NICE
setopt NO_HUP
setopt NO_LIST_BEEP
setopt NO_NOMATCH

setopt LOCAL_OPTIONS
setopt LOCAL_TRAPS

setopt SHARE_HISTORY


setopt CORRECT
setopt COMPLETE_IN_WORD
setopt IGNORE_EOF

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY
setopt HIST_VERIFY

setopt AUTOCD       
setopt PROMPT_SUBST 
setopt MENU_COMPLETE
setopt LIST_PACKED	
setopt AUTO_LIST    
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt COMPLETE_IN_WORD    

setopt notify


HISTFILE=~/.zsh_history
SAVEHIST=100000
HISTSIZE=100000
HISTCONTROL=ignorespace

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source ~/.zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source "$HOME/.zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"


