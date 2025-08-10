#!/usr/bin/env bash

d() {
    create_or_relink_symlink "$SCRIPT_SRC_DIR"/git-test "$LOCAL_BIN"/git-test
    chmod +x "$LOCAL_BIN"/git-test

    return 0

}

idk_name_yet() {
    logger progress "Idk name yet started..."
    logger progress "D in progress......."
    if d; then
        logger ok "D ok"
        logger ok "Idk name yet done"
        return 0
    fi
    logger error "Idk name yet failed"
    return 1

}

idk_name_yet
