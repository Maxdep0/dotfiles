#!/bin/bash

BG_DIR="$XDG_PICTURES_DIR"

NUM_FILES=$(ls -1 $BG_DIR/img-*.png 2>/dev/null | wc -l)

RANDOM_NUM=$(( (RANDOM % NUM_FILES) + 1 ))

BG="$BG_DIR/bg-$RANDOM_NUM.webp"

# echo $BG
swaybg "-o '*' -i '$BG' -m fit"

