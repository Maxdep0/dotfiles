#!/usr/bin/env zsh

source <(fzf --zsh)

for FZF_ENV in \
  FZF_DEFAULT_OPTS FZF_DEFAULT_COMMAND FZF_CTRL_T_COMMAND FZF_CTRL_T_OPTS \
  FZF_ALT_C_COMMAND FZF_ALT_C_OPTS FZF_CTRL_R_OPTS FZF_COMPLETION_TRIGGER \
  FZF_TMUX FZF_TMUX_OPTS FZF_TMUX_HEIGHT FZF_PREVIEW_OPTS FZF_PREVIEW_LINES \
  FZF_COMPLETION_OPTS FZF_COMPLETION_DIR_COMMAND
do
  eval "local STORE_${FZF_ENV}=\"\${$FZF_ENV}\""
  unset $FZF_ENV
done

rm -f "/tmp/fzf-select"

NOT_NVIM_EXT="exe|dll|so|o|a|bin|img|iso|elf|class|pyc|pyo|ttf|otf|woff|woff2|ico|pdf|jpg|jpeg|png|gif|webp|bmp|svg|mp3|mp4|avi|mov|mkv|flac|wav|ogg|zip|tar|gz|bz2|7z|xz|rar|apk|msi|jar|db|sqlite|tar\.gz|tar\.bz2|tar\.xz"
NVIM_EXT="js,ts,jsx,tsx,md,txt,sh,zsh,bash,py,rs,go,c,cpp,h,hpp,java,kt,rb,pl,php,html,css,scss,json,yaml,yml,toml,ini,vim,lua,xml,sql,conf,env,log"

DIRS_TO_EXCLUDE="node_modules .git .cache Cache .nvm .npm .nv go"

FD_EXCLUDE_ARGS=()
for dir in ${(s: :)DIRS_TO_EXCLUDE}; do FD_EXCLUDE_ARGS+=(--exclude "$dir") done

(
    FD_CMD_FILES="fd -t f --hidden ${FD_EXCLUDE_ARGS[*]}"
    FD_CMD_DIRS="fd -t d --hidden ${FD_EXCLUDE_ARGS[*]}"

  cd "$HOME"
  fzf --ansi \
    --color "bg:-1,fg:white,hl:red,hl+:red,bg+:black,fg+:white,header:white,info:red,pointer:red,marker:red,prompt:white,spinner:red" \
    --header '^/ - preview | Enter - cd & nvim | ^o - open with nvim' \
    --border=sharp \
    --prompt='Files> ' \
    --bind "start:reload($FD_CMD_FILES)" \
    --bind "ctrl-f:transform:[[ ! \$FZF_PROMPT =~ Files ]] && \
      echo 'change-prompt(Files> )+reload($FD_CMD_FILES)' || \
      echo 'change-prompt(Dirs>  )+reload($FD_CMD_DIRS)'" \
    --info="inline-right" \
    --preview '[[ $FZF_PROMPT =~ Files ]]  && bat --color=always --style=numbers {} || tree -C {}' \
    --preview-window='top,50%,border-double,top,hidden' \
    --bind 'ctrl-/:toggle-preview' \
    --bind 'ctrl-d:preview-down' \
    --bind 'ctrl-u:preview-up' \
    --bind 'ctrl-o:execute(nvim {})' \
    --bind 'enter:execute-silent(echo $FZF_PROMPT={} > /tmp/fzf-select; kill -SIGTERM "$PPID")'
)

if [[ -f /tmp/fzf-select ]]; then
    while IFS= read -r line; do
      [[ $line == *=* ]] || continue
      KEY="${line%%=*}"
      KEY="${KEY/#export }"
      VALUE="$HOME/${line#*=}"
      DIR=${VALUE%/*}
      FILE=${VALUE##*/}

      echo "\n==FZF DEBUG==\nKEY:$KEY\nVALUE:$VALUE\nDIR:$DIR\nFILE:$FILE\n"

      if [[ $KEY == "Dirs>  " ]]; then
          cd "$DIR"
      fi

      if [[ $KEY == "Files> " ]]; then
          # TODO: Add libreoffice, etc...
          if [[ "$FILE" =~ \.($NOT_NVIM_EXT)$ ]]; then
              echo "Not a valid file for $EDITOR"
              echo "> $FILE}"
              return 1
          fi
          cd "$DIR"
          "$EDITOR" "$FILE" || nvim "$FILE" || vim "$FILE" || echo "Editor not found.\nREASON: Better nothing than nano"
      fi

    done < /tmp/fzf-select
    rm -f "/tmp/fzf-select"
fi


for FZF_ENV in \
  FZF_DEFAULT_OPTS FZF_DEFAULT_COMMAND FZF_CTRL_T_COMMAND FZF_CTRL_T_OPTS \
  FZF_ALT_C_COMMAND FZF_ALT_C_OPTS FZF_CTRL_R_OPTS FZF_COMPLETION_TRIGGER \
  FZF_TMUX FZF_TMUX_OPTS FZF_TMUX_HEIGHT FZF_PREVIEW_OPTS FZF_PREVIEW_LINES \
  FZF_COMPLETION_OPTS FZF_COMPLETION_DIR_COMMAND
do
  eval "export $FZF_ENV=\"\${STORE_${FZF_ENV}}\""
done


