# タスク単位で wezterm workspace を立ち上げて claude を起動する
# claude のセッション履歴は cwd 単位で分かれるため、タスクごとに cwd を分けておくと
# --resume の候補が自動的にそのタスクのものだけに絞られる
# 使い方: cw <task-name> [dir]   dir 省略時はカレントディレクトリ
cw() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "usage: cw <task-name> [dir]" >&2
    return 1
  fi
  local dir="${2:-$PWD}"
  if [[ ! -d "$dir" ]]; then
    echo "cw: no such directory: $dir" >&2
    return 1
  fi
  # --workspace は --new-window とセットでないと効かない
  # claude を抜けてもそのままシェルが残るようにする
  wezterm cli spawn --new-window --workspace "$name" --cwd "$dir" -- zsh -lc 'claude; exec zsh'
}

# worktree を切ってから cw する。ブランチを分けたいタスク用
# 使い方: cwt <branch-name>
cwt() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "usage: cwt <branch-name>" >&2
    return 1
  fi
  local root wt
  root=$(git rev-parse --show-toplevel) || return 1
  wt="${root}-worktrees/${name}"
  if [[ ! -d "$wt" ]]; then
    git worktree add -b "$name" "$wt" || return 1
  fi
  cw "$name" "$wt"
}
