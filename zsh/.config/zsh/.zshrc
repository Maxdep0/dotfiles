#!/usr/bin/env zsh

[[ -f "$HOME/.bash_history" ]] && rm -f "$HOME/.bash_history" 
[[ ! -d "$HOME/.config/zsh" ]] && mkdir -pv "$HOME/.config/zsh"
[[ ! -d "$XDG_CACHE_HOME/zsh" ]] && mkdir -pv "$XDG_CACHE_HOME/zsh" 

[ -s "$ZDOTDIR/scripts/local-utils.zsh" ] && source "$ZDOTDIR/scripts/local-utils.zsh" 
load_plugin "zsh-autosuggestions" 
load eval "$(dircolors -b $ZDOTDIR/src/.dircolors)" 
load source "$ZDOTDIR/scripts/cursor_mode.sh"
load source "$ZDOTDIR/.aliasrc"
load source "$ZDOTDIR/scripts/global-utils.sh"

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
unsetopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Input/Output
setopt CLOBBER
unsetopt CORRECT
unsetopt CORRECT_ALL
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

vcs_info_precmd() { vcs_info; }
rprompt_precmd() { [[ $? -eq 0 ]] && RPROMPT="%F{green}( ͡° ͜ʖ ͡°)%f" || RPROMPT="%F{red}¯\(°_o)/¯%f"; }

autoload -Uz add-zsh-hook
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
zmodload zsh/complist #  WARN: zmodload before compinit!
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
open_fzf() { BUFFER+="source $ZDOTDIR/scripts/open-fzf.zsh"; zle accept-line; }

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
zle -N open_fzf

# Global
bindkey -r "${ALT}j"
bindkey -r "${CTRL}j"
bindkey -r "${ALT}k"
bindkey -r "${CTRL}R"
bindkey -r "${CTRL}D"
bindkey -r "${CTRL}U"
bindkey "${CTRL}f" open_fzf

bindkey "${CTRL}L" accept-line
bindkey "${CTRL}H" backward-delete-char

bindkey "${BACKSPACE}" backward-delete-char

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
bindkey -M viins "${CTRL}j" menu-select
bindkey -M viins "${CTRL}p" .history-search-backward 
bindkey -M viins "${CTRL}n" .history-search-forward 
bindkey -M viins "${CTRL}b" go_back
bindkey -M viins "${CTRL}k" forward-char 

# Visual Mode
bindkey -M visual "p" vi-paste-visual


# Completion Menu
bindkey -M viins "${CTRL}${SPACE}" menu-select
bindkey -M menuselect "${TAB}" accept-line
bindkey -M menuselect "${CTRL}j" vi-down-line-or-history
bindkey -M menuselect "${CTRL}k" vi-up-line-or-history 
bindkey -M menuselect "${CTRL}h" vi-backward-char
bindkey -M menuselect "${CTRL}l" accept-line
bindkey -M menuselect "${CTRL}e" send-break
bindkey -M menuselect "${ESC}" send-break

#
# Completions  -- # https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Completion-System 
#

autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump_${ZSH_VERSION}"
autoload -Uz bashcompinit; bashcompinit 
autoload -U colors; colors

load source "$ZDOTDIR/scripts/lazy-load.zsh"  # NOTE: Lazy load NVM

_comp_options+=(globdots)

# Completion settions
zstyle ":completion:*" use-cache on
zstyle ":completion:*" cache-path "$XDG_CACHE_HOME/zsh/.zcompcache_{$ZSH_VERSION}"
zstyle ':completion:*' menu select
zstyle ':completion:*' list-packed false
zstyle ':completion:*' list-rows-first true
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+r:|[._-]=* r:|=*'
zstyle ':completion:*' rehash true
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:history-words:*' remove-all-dups true
zstyle ':completion:*:*:-command-:*:*' functions commands group-order builtins
zstyle ':completion:*' completer _complete _ignored

# ZSH autosuggestions settings
ZSH_AUTOSUGGEST_STRATEGY=(history completion)


load_plugin "zsh-syntax-highlighting" # WARN: Syntax Highlighting  --  have to be last!
