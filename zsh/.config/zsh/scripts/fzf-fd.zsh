#!/usr/bin/env zsh


source <(fzf --zsh)

rm -f "/tmp/fzf-cd-command"
rm -f "/tmp/fzf-fd-select"

MOVIE_EXTENSIONS="mkv|mp4|avi|flv|mov|wmv|mpeg|mpg|m4v|3gp|webm|vob|ogv|mxf|rm|rmvb"
PHOTO_EXTENSIONS="jpg|jpeg|png|gif|bmp|tiff|tif|svg|webp|heic|raw|cr2|nef|orf|sr2"
NEOVIM_EXTENSIONS="txt|md|html|css|js|ts|json|xml|yaml|yml|csv|py|rb|sh|zsh|vim|lua|java|c|cpp|h|hpp|cs|php|pl|go|rs|swift|sql|toml|ini|conf|cfg"
LIBREOFFICE_EXTENSIONS="odt|ott|oth|odm|sxw|stw|sxg|doc|dot|docx|docm|dotx|dotm|wpd|wps|lwp|abw|zabw|cwk|mw|mcw|rtf|ods|ots|fods|sxc|stc|xls|xlw|xlt|xlsx|xlsm|xlts|xltm|xlsb|wk1|wks|123|dif|sdc|vor|dbf|slk|uos|uof|ppt|pptx|odp|otp|sxi|sti|uop|odg|otg|pdf|epub"

(cd "$HOME" && 
fzf --prompt 'Files> ' \
  --header '^/ - preview | ^C - cd | ^Y - yank path | ^F - modes' \
  --bind 'ctrl-f:transform:[[ ! $FZF_PROMPT =~ Files ]] &&
          echo "change-prompt(Files> )+reload(fd -t f --hidden)" ||
          echo "change-prompt(Directories> )+reload(fd -t d --hidden)"' \
  --preview '[[ $FZF_PROMPT =~ Files ]] && bat --color=always {} || tree -C {}' \
  --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
  --bind 'ctrl-/:toggle-preview' \
  --bind 'ctrl-c:execute(echo {} > /tmp/fzf-cd-command; kill -SIGTERM $PPID)' \
  --bind 'enter:execute-silent(echo {} > /tmp/fzf-fd-select; kill -SIGTERM $PPID)' \
  --bind 'ctrl-y:execute-silent(echo -n {} | wl-copy && echo "Path copied to clipboard. Paste it now."; kill -SIGTERM $PPID)' 
)

if [[ -f /tmp/fzf-cd-command ]];then 
    CD_COMMAND=$(cat /tmp/fzf-cd-command)
    rm -f /tmp/fzf-cd-command
    cd "/${HOME}/${CD_COMMAND%/*}"
fi

if [[ -f /tmp/fzf-fd-select ]]; then
    SELECTED_FILE=$(cat /tmp/fzf-fd-select)
    rm -f /tmp/fzf-fd-select

    if [[ -d "$SELECTED_FILE" ]]; then
        cd "$SELECTED_FILE"

    elif [[ "$SELECTED_FILE" =~ \.($MOVIE_EXTENSIONS)$ ]]; then
        play "$SELECTED_FILE" 

    elif [[ "$SELECTED_FILE" =~ \.($PHOTO_EXTENSIONS)$ ]]; then
        feh "$SELECTED_FILE"

    elif [[ "$SELECTED_FILE" =~ \.($LIBREOFFICE_EXTENSIONS)$ ]]; then
        libreoffice "$SELECTED_FILE"

    else
    # elif [[ "$SELECTED_FILE" =~ \.($NEOVIM_EXTENSIONS)$ ]]; then
        cd "${SELECTED_FILE%/*}" && nvim ${SELECTED_FILE##*/} 

    # else
        # echo "Extension Error"
    fi
fi

