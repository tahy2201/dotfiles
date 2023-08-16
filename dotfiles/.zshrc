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
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet PZT::modules/helper/init.zsh

## Load pure theme
zinit ice pick"async.zsh" src"pure.zsh" # with zsh-async library that's bundled with it.
zinit light sindresorhus/pure

zinit light zsh-users/zsh-autosuggestions

zstyle ':completion:*' completer _complete _approximate

zinit ice depth"1" lucid
zinit snippet OMZL::completion.zsh

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

# origin alias
alias relogin='exec $SHELL -l'
alias ql='qlmanage -p "$@" >& /dev/null'
alias tf='terraform'
alias ce='open $1 -a "/Applications/CotEditor.app"'

setopt auto_cd

sshd() {
  ssh -i ~/.ssh/Juicer_replace.pem ec2-user@$1
}

scpd() {
  scp -i ~/.ssh/Juicer_replace.pem $1 ec2-user@$2
}

# z
. ~/z/z.sh
alias j=z

source $(which assume-role)

# # bgnotify
# source $HOME/.zsh-background-notify/bgnotify.plugin.zsh

PATH=$PATH:/usr/local/Cellar/libpq/11.5_1/bin/:~/bin/

if hash brew 2>/dev/null; then (brew update > /dev/null 2>&1 &); fi

export PATH="$HOME/Applications/AWS-ElasticBeanstalk-CLI-2.2/eb/macosx/python2.7:$PATH"
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"


# asdf
. /usr/local/opt/asdf/libexec/asdf.sh
. ~/.asdf/plugins/java/set-java-home.zsh

# peco (ctrl + r)
function peco-history-selection() {
    BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | peco`
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N peco-history-selection
bindkey '^R' peco-history-selection

#gcloud
local s="source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'"
s="$s;source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'"
zinit ice atload"${s}" wait lucid
zinit light zdharma-continuum/null
alias gcp='gcloud'

# Go
export GOPATH="${HOME}/go"
PATH=$PATH:$GOPATH/bin

# kubectl auto complete
local s="source <(kubectl completion zsh)"
zinit ice atload"${s}" wait lucid
zinit light zdharma-continuum/null
alias k=kubectl
complete -F __start_kubectl k

# export PATH="/usr/local/opt/php@7.0/bin:/usr/local/opt/php@7.0/sbin:$PATH"
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# AWS MFA
export AWS_MFA_SEC=`cat ~/.aws/20220823_mfasecret`
alias mfa-aws='oathtool --totp --base32 $AWS_MFA_SEC | pbcopy && pbpaste && echo "[AWS] ワンタイムパスワードがコピーされました"'

# Github MFA
export GH_MFA_SEC=`cat ~/dev/keys/github-mfa-sec`
alias mfa-gh='oathtool --totp --base32 $GH_MFA_SEC | pbcopy && pbpaste && echo "[Github] ワンタイムパスワードがコピーされました"'

# PHP env
export PATH="$HOME/.phpenv/bin:$PATH"
eval "$(phpenv init -)"

export PKG_CONFIG_PATH="/usr/local/opt/krb5/lib/pkgconfig:/usr/local/opt/icu4c/lib/pkgconfig:/usr/local/opt/libedit/lib/pkgconfig:/usr/local/opt/libjpeg/lib/pkgconfig:/usr/local/opt/libpng/lib/pkgconfig:/usr/local/opt/libxml2/lib/pkgconfig:/usr/local/opt/libzip/lib/pkgconfig:/usr/local/opt/oniguruma/lib/pkgconfig:/usr/local/opt/openssl@1.1/lib/pkgconfig:/usr/local/opt/tidy-html5/lib/pkgconfig" \
export PHP_BUILD_CONFIGURE_OPTS="--with-bz2=/usr/local/opt/bzip2 --with-iconv=/usr/local/opt/libiconv" \

# diff -> colordiff
if [[ -x `which colordiff` ]]; then
  alias diff='colordiff'
fi

alias jruby='~/bin/jruby-complete-9.1.15.0.jar'

#zprof
