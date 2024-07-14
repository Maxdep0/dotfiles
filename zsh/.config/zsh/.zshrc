# shellcheck shell=zsh

#
# For initial linux setup
#

[ -f "$HOME/.bash_history" ] && rm -f "$HOME/.bash_history" 
[ ! -d "$HOME/.config/zsh" ] && mkdir -pv "$HOME/.config/zsh"
[ ! -d "$XDG_CACHE_HOME/zsh" ] && mkdir -pv "$XDG_CACHE_HOME/zsh" 

#
# Source secret env, etc...
#

[ -f "$HOME/.secrets.zsh" ] && source "$HOME/.secrets.zsh" || touch "$HOME/.secrets.zsh"

#
# Sourcing and installing
#

# ZSH Autosuggestions
if [ -s "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
else
    [ -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ] || mkdir -pv "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS_DIR/zsh-autosuggestions"
    source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# NVM
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh" || echo "NVM Not Found" 

# Colors
[ -s "$ZDOTDIR/src/.dircolors" ] && eval "$(dircolors -b $ZDOTDIR/src/.dircolors)" || echo "Dircolors Not Found" 

# Cursor Mode
[ -s "$ZDOTDIR/scripts/cursor_mode.sh" ] && source "$ZDOTDIR/scripts/cursor_mode.sh" || echo "Cursor Mode Not Found" 

# Aliases
[ -s "$ZDOTDIR/.aliasrc" ] && source "$ZDOTDIR/.aliasrc" || echo "Aliases not found" 

#
# Options - http://zsh.sourceforge.net/Doc/Release/Options.html 
#

# Changing Directories
setopt AUTO_CD        
setopt AUTO_PUSHD      
setopt PUSHD_SILENT     
setopt PUSHD_IGNORE_DUPS 

# Completions
setopt ALWAYS_TO_END  
setopt AUTO_LIST     
setopt COMPLETE_ALIASES
setopt COMPLETE_IN_WORD
setopt GLOB_COMPLETE
setopt LIST_PACKED
setopt MENU_COMPLETE

# Expansion and Globbing
setopt BAD_PATTERN  
setopt EXTENDED_GLOB
setopt GLOB_DOTS
setopt NOMATCH

# History
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FCNTL_LOCK
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Input/Output
setopt CLOBBER
setopt CORRECT
setopt CORRECT_ALL
setopt INTERACTIVE_COMMENTS
setopt RC_QUOTES
setopt IGNORE_EOF

# Job Control
setopt BG_NICE
setopt LONG_LIST_JOBS
setopt NOTIFY

# Prompting
setopt PROMPT_SUBST

# Zle
setopt COMBINING_CHARS
setopt VI
setopt ZLE

#
# Custom Prompt - https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html 
#

autoload -Uz vcs_info

vcs_info_precmd() {
  vcs_info
}

rprompt_precmd() {
  [[ $? -eq 0 ]] && RPROMPT="%F{green}( ͡° ͜ʖ ͡°)%f" || RPROMPT="%F{red}¯\(°_o)/¯%f"
}

add-zsh-hook precmd vcs_info_precmd
add-zsh-hook precmd rprompt_precmd

zstyle ':vcs_info:git:*' formats '%F{yellow} %b%f'
zstyle ':vcs_info:*' enable git

PROMPT='%B%F{cyan}%~%f%b ${vcs_info_msg_0_}%B%F{white}>%f%b '

#
# Prepare functions
#

fpath=($fpath /usr/local/share/zsh/site-functions /usr/share/zsh/site-functions)

source <(fzf --zsh)
zmodload zsh/complist # zmodload before compinit!
bindkey -v

CTRL="^"
ALT="M-"
BACKSPACE="^?"
TAB="^I"
ENTER="^M"
ESC="^["
SPACE="@"

#
# Functions
#

# Target specific copy manager based on OS
if [ "$XDG_SESSION_TYPE" = 'wayland' ]; then
    zle_vi_yank_to_system_register() { zle .vi-yank; echo -n "$CUTBUFFER" | wl-copy; }
    zle_vi_paste_from_system_register() { LBUFFER+=$(wl-paste); CUTBUFFER=""; zle redisplay; }
    zle_vi_paste_visual_mode() { zle .vi-delete; LBUFFER+=$(wl-paste); CUTBUFFER=""; zle redisplay; }
elif [ "$XDG_SESSION_TYPE" = 'x11' ]; then
    zle_vi_yank_to_system_register() { zle .vi-yank; echo -n "$CUTBUFFER" | xclip -selection clipboard; }
    zle_vi_paste_from_system_register() { LBUFFER+=$(xclip -o -selection clipboard); CUTBUFFER=""; zle redisplay; }
    zle_vi_paste_visual_mode() { zle .vi-delete; LBUFFER+=$(xclip -o -selection clipboard); CUTBUFFER=""; zle redisplay; }
elif [ "$OS" = 'Windows_NT' ]; then
    zle_vi_yank_to_system_register() { zle .vi-yank; echo -n "$CUTBUFFER" | clip.exe; }
    zle_vi_paste_from_system_register() { LBUFFER+=$(powershell.exe -Command "Get-Clipboard"); CUTBUFFER=""; zle redisplay; }
    zle_vi_paste_visual_mode() { zle .vi-delete; LBUFFER+=$(powershell.exe -Command "Get-Clipboard"); CUTBUFFER=""; zle redisplay; }
else
    echo "Unsupported session type for registers check -> .zshrc line $LINENO"
fi

# Custom FZF
open_fzf_fd() { BUFFER+="source $ZDOTDIR/scripts/fzf-fd.zsh"; zle accept-line; }
open_fzf_rg() { BUFFER+="source $ZDOTDIR/scripts/fzf-rg.zsh"; zle accept-line; }

# Directories movement
go_back() { BUFFER+=".."; zle accept-line; }

# Disable register change for delete, etc..
zle_vi_delete() { zle .vi-delete; CUTBUFFER=""; }
zle_vi_change() { zle .vi-change; CUTBUFFER=""; }
zle_vi_delete_char() { zle .vi-delete-char; CUTBUFFER=""; }
zle_vi_substitute_char() { zle .vi-substitute-char; CUTBUFFER=""; }
zle_vi_kill_line() { zle .vi-kill-line; CUTBUFFER=""; }
zle_vi_change_eol() { zle .vi-change-eol; CUTBUFFER=""; }

#
# Widgets  --  https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets  --  https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
#

zle -N vi-yank zle_vi_yank_to_system_register
zle -N vi-put-after zle_vi_paste_from_system_register
zle -N vi-delete zle_vi_delete
zle -N vi-change zle_vi_change
zle -N vi-delete-char zle_vi_delete_char
zle -N vi-substitute-char zle_vi_substitute_char
zle -N vi-kill-line zle_vi_kill_line
zle -N vi-change-eol zle_vi_change_eol
zle -N vi-paste-visual zle_vi_paste_visual_mode
zle -N go_back
zle -N open_fzf_fd
zle -N open_fzf_rg

# Global
bindkey -r "${ALT}j"
bindkey -r "${CTRL}j"
bindkey -r "${ALT}k"
# bindkey -r "u"
bindkey -r "${CTRL}R"
bindkey -r "${CTRL}D"
bindkey -r "${CTRL}U"
bindkey "${CTRL}Z" undo
bindkey "${CTRL}Y" redo
bindkey "${CTRL}f" open_fzf_fd
bindkey "${CTRL}g" open_fzf_rg
bindkey "${CTRL}L" accept-line
bindkey "${CTRL}H" backward-delete-char
bindkey "${BACKSPACE}" backward-delete-char
bindkey "${TAB}" menu-select

# Normal Mode
bindkey -M vicmd "${CTRL}b" go_back
bindkey -M vicmd "y" vi-yank
bindkey -M vicmd "p" vi-put-after
bindkey -M vicmd "d" vi-delete
bindkey -M vicmd "c" vi-change
bindkey -M vicmd "x" vi-delete-char
bindkey -M vicmd "s" vi-substitute-char
bindkey -M vicmd "D" vi-kill-line
bindkey -M vicmd "C" vi-change-eol

# Insert Mode
bindkey -M viins "${CTRL}${SPACE}" complete-word
bindkey -M viins "${CTRL}j" menu-select
bindkey -M viins "${CTRL}p" .history-search-backward 
bindkey -M viins "${CTRL}n" .history-search-forward 
bindkey -M viins "${CTRL}b" go_back
bindkey -M viins "${CTRL}k" forward-char 

# Visual Mode
bindkey -M visual "p" vi-paste-visual

# Completion Menu
bindkey -M menuselect "h" vi-backward-char
bindkey -M menuselect "k" vi-up-line-or-history
bindkey -M menuselect "j" vi-down-line-or-history
bindkey -M menuselect "l" vi-forward-char
bindkey -M menuselect "${CTRL}L" accept-line
bindkey -M menuselect "${CTRL}B" send-break
bindkey -M menuselect "${ESC}" send-break

#
# Completions  -- # https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Completion-System 
#

autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump_${ZSH_VERSION}"
autoload -Uz bashcompinit; bashcompinit 
autoload -U colors; colors

# Source bash completion after compinit to avoid creating duplicated zcompdump
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion" || echo "Bash Completions Not Found" 

_comp_options+=(globdots)

# Completion settions
zstyle ":completion:*" use-cache on
zstyle ":completion:*" cache-path "$XDG_CACHE_HOME/zsh/.zcompcache_{$ZSH_VERSION}"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*' expand prefix suffix

zstyle ':completion:*' completer _list _expand _complete _ignored _match _correct _approximate _prefix _extensions _files
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|[._-]=** r:|=**' 'l:|=* r:|=*' 'm:{0-9}={0-9}' 'm:{a-zA-Z0-9}={A-Za-z0-9}' 'r:|=* l:|=* r:|=*' 'l:|=* m:{a-zA-Z0-9}={A-Za-z0-9}'
zstyle ':completion:*' match-original both
zstyle ':completion:*' max-errors 2 numeric
zstyle ':completion:*' old-menu false
zstyle ":completion:*" menu select
zstyle ':completion:*' squeeze-slashes true
zstyle ":completion:*" complete-options true
zstyle ':completion:*' word true
zstyle ':completion:*:urls' sort true
zstyle ':completion:*:history-words' sort true
zstyle ':completion:*:history-words' stop true
zstyle ":completion:*:*:*:*:descriptions" format "%F{green}-- %d --%f"
zstyle ":completion:*:*:*:*:corrections" format "%F{yellow}!- %d (errors: %e) -!%f"
zstyle ":completion:*:*:-command-:*:*" group-order alias builtins functions commands

# ZSH autosuggestions settings
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Syntax Highlighting  --  have to be last!
if [ -s "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" 
else
    [ -d $ZSH_PLUGINS_DIR/zsh-syntax-highlighting ] || mkdir -pv "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
    source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" 
fi


