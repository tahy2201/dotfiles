#!/bin/sh
SCRIPT_DIR=$(cd $(dirname $0); pwd)
ln -sf $SCRIPT_DIR/.zshrc ~/.zshrc
ln -sf $SCRIPT_DIR/.vimrc ~/.vimrc
mkdir -p ~/.config/git
ln -sf $SCRIPT_DIR/.gitconfig ~/.config/git/config
ln -sf $SCRIPT_DIR/.gitignore_global ~/.config/git/ignore
ln -sf $SCRIPT_DIR/CLAUDE.md ~/.claude/CLAUDE.md
# ディレクトリへのリンクは -n が必須。付けないと再実行時にリンク先の中へ潜り込む
ln -sfn $SCRIPT_DIR/persona ~/.claude/persona
