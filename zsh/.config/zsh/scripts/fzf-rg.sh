#!/usr/bin/env zsh


source <(fzf --zsh)

MOVIE_EXTENSIONS="mkv|mp4|avi|flv|mov|wmv|mpeg|mpg|m4v|3gp|webm|vob|ogv|mxf|rm|rmvb"
PHOTO_EXTENSIONS="jpg|jpeg|png|gif|bmp|tiff|tif|svg|webp|heic|raw|cr2|nef|orf|sr2"
NEOVIM_EXTENSIONS="txt|md|html|css|js|ts|json|xml|yaml|yml|csv|py|rb|sh|zsh|vim|lua|java|c|cpp|h|hpp|cs|php|pl|go|rs|swift|sql|toml|ini|conf|cfg"

rm -f /tmp/rg-fzf-{r,f}
RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
INITIAL_QUERY="${*:-}"
fzf --ansi --disabled --query "$INITIAL_QUERY" \
    --bind "start:reload:$RG_PREFIX {q}" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --bind 'ctrl-g:transform:[[ ! $FZF_PROMPT =~ Rg ]] &&
      echo "rebind(change)+change-prompt(Rg> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
      echo "unbind(change)+change-prompt(Fzf> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --prompt 'Rg> ' \
    --delimiter : \
    --header 'CTRL-G:  rg/fzf' \
    --preview 'bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    --bind 'enter:execute-silent(echo {} > /tmp/fzf-rg-select; kill -SIGTERM $PPID)' 



if [[ -f /tmp/fzf-rg-select ]]; then
    SELECTED_FILE=$(cat /tmp/fzf-fd-select)
    rm -f /tmp/fzf-rg-select

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

