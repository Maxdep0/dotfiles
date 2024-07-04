#!/usr/bin/env zsh


source <(fzf --zsh)

MOVIE_EXTENSIONS="mkv|mp4|avi|flv|mov|wmv|mpeg|mpg|m4v|3gp|webm|vob|ogv|mxf|rm|rmvb"
PHOTO_EXTENSIONS="jpg|jpeg|png|gif|bmp|tiff|tif|svg|webp|heic|raw|cr2|nef|orf|sr2"
NEOVIM_EXTENSIONS="txt|md|html|css|js|ts|json|xml|yaml|yml|csv|py|rb|sh|zsh|vim|lua|java|c|cpp|h|hpp|cs|php|pl|go|rs|swift|sql|toml|ini|conf|cfg"



fzf --prompt 'Files> ' \
  --header 'CTRL-F: Switch between Files/Directories' \
  --bind 'ctrl-f:transform:[[ ! $FZF_PROMPT =~ Files ]] &&
          echo "change-prompt(Files> )+reload(fd -t f --hidden)" ||
          echo "change-prompt(Directories> )+reload(fd -t d --hidden)"' \
  --preview '[[ $FZF_PROMPT =~ Files ]] && bat --color=always {} || tree -C {}' \
  --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
  --bind 'ctrl-p:toggle-preview' \
  --bind 'enter:execute-silent(echo {} > /tmp/fzf-fd-select; kill -SIGTERM $PPID)' 


if [[ -f /tmp/fzf-fd-select ]]; then
    SELECTED_FILE=$(cat /tmp/fzf-fd-select)
    rm -f /tmp/fzf-fd-select

    if [[ "$SELECTED_FILE" =~ \.($NEOVIM_EXTENSIONS)$ ]]; then
        nvim "$SELECTED_FILE"
        echo "Neovim open"
    elif [[ "$SELECTED_FILE" =~ \.($MOVIE_EXTENSIONS)$ ]]; then
        play "$SELECTED_FILE" 
        echo "video open"

    elif [[ "$SELECTED_FILE" =~ \.($PHOTO_EXTENSIONS)$ ]]; then
        feh "$SELECTED_FILE"
        echo "image open"

    else
        echo "Extension Error"
    fi

else
    echo "No file selected."
fi

