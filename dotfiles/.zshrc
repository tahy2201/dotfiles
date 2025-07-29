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
zinit ice wait'0'; zinit light zsh-users/zsh-completions
autoload -Uz compinit && compinit

## 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

## 補完候補を一覧表示したとき、Tabや矢印で選択できるようにする
zstyle ':completion:*:default' menu select=1 

## シンタックスハイライト
zinit ice wait'0';zinit light zsh-users/zsh-syntax-highlighting

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

# homebrew更新
if hash brew 2>/dev/null; then (brew update > /dev/null 2>&1 &); fi

export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

# asdf
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# peco (ctrl + r)
# 要: brew install peco
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

# Go
export GOPATH="${HOME}/go"
PATH=$PATH:$GOPATH/bin

# diff -> colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/hyuga/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/hyuga/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/hyuga/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/hyuga/google-cloud-sdk/completion.zsh.inc'; fi

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

# Weztermでの自動ログ機能
# WEZTERM_PANEが設定されている（Weztermで実行されている）かつ
# SCRIPT_RUNNINGが設定されていない（まだscriptが実行されていない）場合のみ実行
if [[ -n "$WEZTERM_PANE" ]] && [[ -z "$SCRIPT_RUNNING" ]]; then
    # 重複実行を防ぐためのフラグを設定
    export SCRIPT_RUNNING=1
    
    # ログディレクトリを作成
    mkdir -p ~/wezterm_logs
    
    # ログファイル名を生成（日時付き）
    log_file="$HOME/wezterm_logs/session_$(date +%Y%m%d_%H%M%S).log"
    
    # ログ開始メッセージを表示・記録（英語フォーマットで日時表示）
    echo "🎯 Weztermログセッション開始: $(LC_TIME=C date)" | tee -a "$log_file"
    
    # scriptコマンドでログを開始し、現在のシェルを置き換える
    exec script -a "$log_file"
fi
