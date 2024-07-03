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

precmd() { vcs_info; }
zstyle ':vcs_info:git:*' formats '%F{yellow} %b%f'
zstyle ':vcs_info:*' enable git

RPROMPT='%(?..%F{red}%f)'
PROMPT='%B%F{cyan}%~%f%b ${vcs_info_msg_0_}%B%F{white}>%f%b '




############################








####################
# autoload -Uz vcs_info
#
# zstyle ':vcs_info:git:*' formats '%F{yellow}%b%f'
# precmd() { vcs_info }
#
# PROMPT='%F{blue}%~%f ${vcs_info_msg_0_}   '


# PROMPT='%n@%m:%~%# '
# PROMPT='%~%ea  :   ) '


#
#
#

# autoload -U colors && colors


# ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# [ -s "$ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source "$ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" || echo "zsh-syntax-higlighting.zsh not found"


