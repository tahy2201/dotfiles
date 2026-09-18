# claude セッションの検索・再開・アカウント間の輸入
#
# 個人アカウントは CLAUDE_CONFIG_DIR を分けて使う（claude-me）。認証情報は
# CLAUDE_CONFIG_DIR ごとに keychain のサービス名が分かれるため、設定ディレクトリを
# 分けるだけで会社/個人のログインを併存できる。
# ただしセッション履歴も CLAUDE_CONFIG_DIR/projects 配下に分かれてしまうため、
# 素の `claude --resume` では反対側のアカウントで作ったセッションが見えない。
# cs / cs-me はこの分断を検索と輸入で埋める

alias cr='claude --resume'
alias cc='claude --continue'

# 個人アカウントで claude を起動する
# グローバル設定は ~/.claude-personal 側から symlink して共用する
alias claude-me='CLAUDE_CONFIG_DIR="$HOME/.claude-personal" claude'

# 全プロジェクト横断でセッションを選ぶ（resume も輸入もここが起点）
# claude の履歴は cwd ごとにディレクトリが分かれるため、標準の --resume では
# リポジトリをまたいだ検索ができない。その穴を埋める
# $1: CLAUDE_CONFIG_DIR（空なら会社側=デフォルト）, $2: 検索語（省略可）
# 標準出力: <cwd>\t<sessionId>\t<jsonl のルートディレクトリ>（選択なしなら何も出さない）
_claude_session_pick() {
  local config_dir="$1" query="$2"
  local root="${config_dir:-$HOME/.claude}/projects"
  local list sel cwd sid
  list=$(CLAUDE_SESSIONS_ROOT="$root" claude-sessions) || return 1
  if [[ -n "$query" ]]; then
    # 中身の全文検索。ヒットしたセッションのファイル名から id を引いて一覧を絞る
    local ids
    ids=$(grep -rl -- "$query" "$root"/*/*.jsonl 2>/dev/null \
          | sed 's|.*/||; s|\.jsonl$||')
    if [[ -z "$ids" ]]; then
      echo "no session contains: $query" >&2
      return 1
    fi
    # 複数行を 1 パターンとして渡すと取りこぼすため -f - でパターン列として読ませる
    list=$(print -r -- "$list" | grep -F -f <(print -r -- "$ids"))
  fi
  # 表示は日付/プロジェクト/タイトルのみ。cwd と id は後段で使うため列としては残す
  sel=$(print -r -- "$list" | fzf --delimiter='\t' --with-nth=1,2,3 \
        --preview 'echo {3}' --preview-window=down:3:wrap) || return 0
  [[ -z "$sel" ]] && return 0
  cwd=$(print -r -- "$sel" | cut -f4)
  sid=$(print -r -- "$sel" | cut -f5)
  printf '%s\t%s\t%s\n' "$cwd" "$sid" "$root"
}

# 選んだセッションを反対側の CLAUDE_CONFIG_DIR へコピーする
# jsonl の中身に CLAUDE_CONFIG_DIR 依存の情報は無いため単純コピーで問題ない
# $1: セッションの sessionId, $2: そのセッションの root (projects ディレクトリ),
# $3: コピー先の CLAUDE_CONFIG_DIR（空なら会社側=デフォルト）
_claude_session_import() {
  local sid="$1" src_root="$2" dst_config_dir="$3"
  # jsonl はプロジェクトディレクトリ名（cwd をエンコードしたもの）配下にある。
  # src_root と同じ階層構造をコピー先の projects にも作ってコピーする
  local src proj dst_root dst_dir dst
  proj=$(basename "$(dirname "$(print -r -- "$src_root"/*/"${sid}.jsonl"(N[1]))")")
  src="$src_root/$proj/$sid.jsonl"
  [[ -f "$src" ]] || { echo "session file not found: $src" >&2; return 1; }
  dst_root="${dst_config_dir:-$HOME/.claude}/projects"
  dst_dir="$dst_root/$proj"
  dst="$dst_dir/$sid.jsonl"
  if [[ -f "$dst" ]]; then
    echo -n "$dst は既に存在する。上書きする? (y/N): "
    local ans; read ans
    [[ "$ans" != [yY] ]] && { echo "キャンセルした"; return 0; }
  fi
  mkdir -p "$dst_dir"
  cp "$src" "$dst"
  echo "imported: $dst"
}

# cs / cs-me の共通本体。通常は resume、--import / -i を付けると
# resume せず反対側の CLAUDE_CONFIG_DIR へ jsonl を輸入する
# $1: CLAUDE_CONFIG_DIR（空なら会社側）, $2: 輸入先 CLAUDE_CONFIG_DIR, $3以降: --import/検索語
_claude_session_cmd() {
  local config_dir="$1" dst_config_dir="$2"
  shift 2
  local do_import=0
  if [[ "$1" == "--import" || "$1" == "-i" ]]; then
    do_import=1
    shift
  fi
  local query="$1"
  local picked cwd sid root
  picked=$(_claude_session_pick "$config_dir" "$query") || return $?
  [[ -z "$picked" ]] && return 0
  cwd=$(print -r -- "$picked" | cut -f1)
  sid=$(print -r -- "$picked" | cut -f2)
  root=$(print -r -- "$picked" | cut -f3)

  if (( ! do_import )); then
    [[ -d "$cwd" ]] || { echo "directory is gone: $cwd" >&2; return 1; }
    (cd "$cwd" && CLAUDE_CONFIG_DIR="$config_dir" claude --resume "$sid")
    return
  fi
  _claude_session_import "$sid" "$root" "$dst_config_dir"
}

# 会社側セッションの検索・再開
# タイトルで絞り込む: cs / 会話の中身で絞り込む: cs <検索語>
# --import / -i を付けると resume せず personal 側へ輸入する
cs() { _claude_session_cmd "" "$HOME/.claude-personal" "$@" }

# 個人アカウント（claude-me）側セッションの検索・再開版
# --import / -i を付けると resume せず会社側へ輸入する
cs-me() { _claude_session_cmd "$HOME/.claude-personal" "" "$@" }
