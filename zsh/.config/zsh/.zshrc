export ZSH_COMPDUMP="$HOME/.zcompdump"


# For initial linux setup
[ ! -d "$HOME/.config/zsh" ] && mkdir -pv "$HOME/.config/zsh"
[ ! -d "$XDG_CACHE_HOME/zsh" ] && mkdir -pv "$XDG_CACHE_HOME/zsh" 

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
# http://zsh.sourceforge.net/Doc/Release/Options.html 
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
# https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html 
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
# https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Completion-System 
# https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets 
# https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets
#

fpath=($fpath /usr/local/share/zsh/site-functions /usr/share/zsh/site-functions)

zmodload zsh/complist 
bindkey -v

if [ "$XDG_SESSION_TYPE" = 'wayland' ]; then
    zle_vi_yank_to_system_register() { zle .vi-yank; echo -n "$CUTBUFFER" | wl-copy; }
    zle_vi_paste_from_system_register() { LBUFFER+=$(wl-paste); CUTBUFFER=""; zle redisplay; }
    zle_vi_paste_visual_mode() { zle .vi-delete; LBUFFER+=$(wl-paste); CUTBUFFER=""; zle redisplay; }
else
    echo "No WAYLAND session -> .zshrc line 155"
fi

# Disable register change for delete, etc..
zle_vi_delete() { zle .vi-delete; CUTBUFFER="" }
zle_vi_change() { zle .vi-change; CUTBUFFER="" }
zle_vi_delete_char() { zle .vi-delete-char; CUTBUFFER="" }
zle_vi_substitute_char() { zle .vi-substitute-char; CUTBUFFER="" }
zle_vi_kill_line() { zle .vi-kill-line; CUTBUFFER="" }
zle_vi_change_eol() { zle .vi-change-eol; CUTBUFFER="" }

# Widgets
zle -N vi-yank zle_vi_yank_to_system_register
zle -N vi-put-after zle_vi_paste_from_system_register
zle -N vi-delete zle_vi_delete
zle -N vi-change zle_vi_change
zle -N vi-delete-char zle_vi_delete_char
zle -N vi-substitute-char zle_vi_substitute_char
zle -N vi-kill-line zle_vi_kill_line
zle -N vi-change-eol zle_vi_change_eol
zle -N vi-paste-visual zle_vi_paste_visual_mode

# Yank/Paste/Remove
bindkey -M vicmd "y" vi-yank
bindkey -M vicmd "p" vi-put-after
bindkey -M visual "p" vi-paste-visual
bindkey -M vicmd "d" vi-delete
bindkey -M vicmd "c" vi-change
bindkey -M vicmd "x" vi-delete-char
bindkey -M vicmd "s" vi-substitute-char
bindkey -M vicmd "D" vi-kill-line
bindkey -M vicmd "C" vi-change-eol

# Suggestion
bindkey '^L' autosuggest-accept
bindkey "^K" menu-select
bindkey -M menuselect "^M" .accept-line
bindkey -M menuselect "h" vi-backward-char
bindkey -M menuselect "k" vi-up-line-or-history
bindkey -M menuselect "j" vi-down-line-or-history
bindkey -M menuselect "l" vi-forward-char
bindkey -M menuselect "^I" accept-line
bindkey -M menuselect "^K" send-break

# Fzf
source <(fzf --zsh)

bindkey -s '^F' "source $ZDOTDIR/scripts/fzf-fd.sh\n"
bindkey -s '^G' "source $ZDOTDIR/scripts/fzf-rg.sh\n"

autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump_${ZSH_VERSION}"
autoload -Uz bashcompinit; bashcompinit 
autoload -U colors; colors

[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion" || echo "Bash Completions Not Found" 


_comp_options+=(globdots)

zstyle ":completion:*" use-cache on
zstyle ":completion:*" cache-path "$XDG_CACHE_HOME/zsh/.zcompcache_{$ZSH_VERSION}"
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' completer _list _expand _complete _ignored _match _correct _approximate _prefix _extensions _files
zstyle ':completion:*' expand prefix suffix
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' group-name ''
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

ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Syntax Highlighting
if [ -s "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" 
else
    [ -d $ZSH_PLUGINS_DIR/zsh-syntax-highlighting ] || mkdir -pv "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting"
    source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" 
fi

