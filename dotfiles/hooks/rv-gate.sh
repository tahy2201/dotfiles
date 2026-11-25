#!/bin/bash
# Claude が実行する git push の前に、ブランチ全体を rv エージェントでレビューする。
# PreToolUse(Bash) から呼ばれる。[NITS] 以外の指摘があれば exit 2 で push を止め、レビュー結果を Claude に返す。
# [NITS] だけなら push を通し、指摘は additionalContext で Claude に見せる。
# 見送り済みの指摘は <repo>/.tahy/rv-ack/<ブランチ名の / を _ にしたもの>.md に書く（ユーザーが承認した理由だけ書くこと）。
# 手打ちの push は通らない（指摘を無視して出したいときは自分で push する）。
set -uo pipefail

input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
cd "$(jq -r '.cwd // "."' <<<"$input")" || exit 0

# コマンドの先頭か区切り（; & | ( 改行）の直後にある git push だけを拾う。echo や grep の文字列に含まれる git push は対象外
push_re=$'(^|[;&|(\n])[[:space:]]*git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+push([[:space:]]|$)'
[[ $cmd =~ $push_re ]] || exit 0
# ブランチ削除の push はレビュー対象外
[[ $cmd =~ [[:space:]](--delete|-d)([[:space:]]|$) ]] && exit 0

# git -C <dir> push / cd <dir> && git push の移動先に合わせる
if [[ $cmd =~ git[[:space:]]+-C[[:space:]]+([^[:space:]]+) ]] || [[ $cmd =~ ^cd[[:space:]]+([^[:space:];&]+) ]]; then
  dir=${BASH_REMATCH[1]//[\"\']/}
  cd "${dir/#\~/$HOME}" || exit 0
fi
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# ponytail: push するのは現在の HEAD とみなす。`git push origin <別ブランチ>` はレビュー範囲がずれる
base=$(gh pr view --json baseRefName -q .baseRefName 2>/dev/null)
base=${base:-main}
git fetch -q origin "$base" 2>/dev/null
range="origin/$base...HEAD"
[ -z "$(git diff --name-only "$range" 2>/dev/null)" ] && exit 0

log_dir=~/.claude/rv-logs
mkdir -p "$log_dir"
log="$log_dir/$(basename "$(git rev-parse --show-toplevel)")_$(git branch --show-current | tr / _)_$(git rev-parse --short HEAD)_$(date +%Y%m%d%H%M%S).md"

# 見送り済みの指摘と理由。あれば rv に渡し、妥当なものは出さない
ack="$(git rev-parse --show-toplevel)/.tahy/rv-ack/$(git branch --show-current | tr / _).md"
prompt="対象範囲: $range"
[ -f "$ack" ] && prompt+=$'\n\n見送り済みの指摘（ユーザー承認済み。理由が妥当なら出さない）:\n'"$(cat "$ack")"

# RV_MODEL は Sonnet / Opus の比較用
review=$(claude -p --agent rv ${RV_MODEL:+--model "$RV_MODEL"} \
  --max-budget-usd "${RV_BUDGET_USD:-3}" \
  --allowedTools "Read Grep Glob Bash(git diff *) Bash(git log *) Bash(git show *) Bash(git grep *)" \
  <<<"$prompt" 2>&1)
status=$?
printf '%s\n' "$review" >"$log"

# 判定は rv の VERDICT ではなくラベルの数で行う。最終行が VERDICT でなければレビュー失敗とみなして止める（fail-closed）
if [ $status -eq 0 ] && [[ $(grep -v '^[[:space:]]*$' <<<"$review" | tail -1) == VERDICT:* ]]; then
  if ! grep -qE '^[^[:alnum:]]*\[(MUST|ASK|IMO)\]' <<<"$review"; then
    grep -q '\[NITS\]' <<<"$review" && jq -n --arg r "$review" \
      '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"allow",additionalContext:("rv の指摘（[NITS] のみ。push は通した）:\n"+$r)}}'
    exit 0
  fi
fi

{
  echo "rv ゲートが push を止めた（範囲: ${range} / ログ: ${log}）。"
  echo "指摘を直して amend / fixup してから再 push すること。指摘に同意できない場合はユーザーに判断を仰ぎ、見送りが承認されたら $ack に指摘と理由を書くこと（承認前に書かない）。"
  echo
  echo "$review"
} >&2
exit 2
