#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
# Customize to your needs...

#zmodload zsh/zprof

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

export LANG=ja_JP.UTF-8

# メタ文字でエラーにならないようにする
setopt nonomatch

# 同時に起動したzshの間でヒストリを共有する
setopt share_history

# 同じコマンドをヒストリに残さない
setopt hist_ignore_all_dups

# スペースから始まるコマンド行はヒストリに残さない
setopt hist_ignore_space

# ヒストリに保存するときに余分なスペースを削除する
setopt hist_reduce_blanks

# ディレクトリ名だけでcdする
setopt auto_cd

# cd したら自動的にpushdする
setopt auto_pushd

# 重複したディレクトリを追加しない
setopt pushd_ignore_dups


### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust
### End of Zinit's installer chunk


# Load starship theme
# line 1: `starship` binary as command, from github release
# line 2: starship setup at clone(create init.zsh, completion)
# line 3: pull behavior same as clone, source init.zsh
zinit ice as"command" from"gh-r" \
          atclone"./starship init zsh > init.zsh; ./starship completions zsh > _starship" \
          atpull"%atclone" src"init.zsh"
zinit light starship/starship
export STARSHIP_CONFIG=~/work/tahy/dotfiles/starship/starship.toml

zinit light zsh-users/zsh-autosuggestions

zstyle ':completion:*' completer _complete _approximate

## コマンド補完
zinit ice wait'0' lucid; zinit light zsh-users/zsh-completions
autoload -Uz compinit && compinit

## 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

## 補完候補を一覧表示したとき、Tabや矢印で選択できるようにする
zstyle ':completion:*:default' menu select=1 

## シンタックスハイライト
zinit ice wait'0' lucid; zinit light zsh-users/zsh-syntax-highlighting

## 区切り文字として使用しない
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

## ls 色付け
export LSCOLORS=cxfxcxdxbxegedabagacad
alias ll='ls -lGF'
alias ls='ls -GF'

# 提案戦略設定 1.履歴、2.zsh補完機能
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# origin alias
alias relogin='exec $SHELL -l'
alias ql='qlmanage -p "$@" >& /dev/null'
alias tf='terraform'
alias ce='open $1 -a "/Applications/CotEditor.app"'
alias sl='serverless'

# git branch cleanup (削除安全版)
# main, master, develop ブランチは削除しない
git-branch-cleanup() {
    echo "以下のブランチが削除されます："
    git branch --merged | grep -v "\*\|main\|master\|develop"
    echo -n "削除しますか？ (y/N): "
    read answer
    if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
        git branch --merged | grep -v "\*\|main\|master\|develop" | xargs -n 1 git branch -d
        echo "削除完了！"
    else
        echo "キャンセルしました"
    fi
}

# homebrew更新
if hash brew 2>/dev/null; then (brew update > /dev/null 2>&1 &); fi

export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# mise
eval "$(mise activate zsh)"

# 履歴検索 (ctrl + r)
# 要: brew install fzf
# --query で打ちかけの文字列をそのまま検索語として引き継ぐ
function fzf-history-selection() {
    BUFFER=$(history -n 1 | tail -r | awk '!a[$0]++' | fzf --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-history-selection
bindkey '^R' fzf-history-selection

# Go
export GOPATH="${HOME}/go"
PATH=$PATH:$GOPATH/bin

# diff -> colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

# postgresql
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# ローカルで使うbinディレクトリ
export PATH="$HOME/bin:$PATH"

# ホスト名が会社用Macと一致する場合に、会社用設定ファイルを読み込む
if [ "$(hostname)" = "LGadmins-MacBook-Pro.local" ]; then
  if [ -f ~/.zshrc.company ]; then
    source ~/.zshrc.company
  fi
else
  # 会社用ではない場合、プライベート設定ファイルを読み込む
  if [ -f ~/.zshrc.private ]; then
    source ~/.zshrc.private
  fi
fi

# uv 補完
eval "$(uv generate-shell-completion zsh)"

# claude用
export PATH="$HOME/.local/bin:$PATH"
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/hyuga/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# zoxide (z / zi)
# 要: brew install zoxide
# 訪問履歴を学習して部分一致でジャンプする。cd はそのまま残る
# 親子で名前が被る場合（foo と foo.worktrees など）は、
# 訪問回数のスコアと末尾要素のマッチで区別される
eval "$(zoxide init zsh)"

# claude 起動・セッション操作（cw/cwt, cs/cs-me, claude-me）
source "${0:A:h}/zsh/claude-wezterm.zsh"
source "${0:A:h}/zsh/claude-sessions.zsh"

# 起動直後のプロンプトを画面下端へ寄せる
# ターミナルは上から書き始めるため、新しいシェルほど視線が上に飛ぶ。
# 空行で埋めて最初から下端に置くことで、既存タブとの視線移動をなくす
if [[ -o interactive ]] && [[ -z "$_ZSH_PROMPT_PADDED" ]]; then
  export _ZSH_PROMPT_PADDED=1
  printf '\n%.0s' {1..$((LINES - 2))}
fi

# worktree を選んでまとめて削除する
# git worktree remove はパスを 1 つずつ渡す必要があり、消して良いかの判断も
# 自分で調べないといけない。一覧に判定を添えて Tab で複数選べるようにする
# 印: - マージ済み / * 未マージ / ! 未コミットあり / ? detached
gwtrm() {
  local list sel
  list=$(git-wt-clean) || return 1
  if [[ -z "$list" ]]; then
    echo "gwtrm: worktree がない" >&2
    return 0
  fi
  sel=$(print -r -- "$list" | fzf --multi --delimiter='\t' --with-nth=1,2,3,4 \
        --header='Tab で複数選択 / Enter で削除確認' \
        --preview 'git -C {5} status --short --branch 2>/dev/null | head -20' \
        --preview-window=down:8:wrap) || return 0
  [[ -z "$sel" ]] && return 0

  echo "以下を削除する:"
  print -r -- "$sel" | awk -F'\t' '{printf "  %s %s (%s)\n", $1, $2, $4}'
  echo -n "よろしいですか? (y/N): "
  local ans; read ans
  [[ "$ans" != [yY] ]] && { echo "キャンセルした"; return 0; }

  # path は zsh では PATH と連動する特殊変数なので、ローカル変数名に使わない
  local wt
  print -r -- "$sel" | cut -f5 | while read -r wt; do
    # 未コミットの変更がある worktree は --force なしでは消せない。
    # 取り返しがつかないので force はかけず、失敗として残す
    if git worktree remove "$wt" 2>/dev/null; then
      echo "削除: $(basename "$wt")"
    else
      echo "失敗: $(basename "$wt") (未コミットの変更が残っている可能性)" >&2
    fi
  done
  git worktree prune
}
