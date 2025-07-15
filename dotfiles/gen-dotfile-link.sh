#!/bin/sh
SCRIPT_DIR=$(cd $(dirname $0); pwd)
ln -sf $SCRIPT_DIR/.zshrc ~/.zshrc
ln -sf $SCRIPT_DIR/.vimrc ~/.vimrc
ln -sf $SCRIPT_DIR/CLAUDE.md ~/.claude/CLAUDE.md
