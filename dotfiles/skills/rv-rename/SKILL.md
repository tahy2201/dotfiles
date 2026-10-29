---
name: rv-rename
description: 直近のセッションを走査し、レビュー依頼セッションのタイトルを規定形式にリネームする
---

直近のセッションを調べて、PR レビュー依頼のセッションのタイトルを規定形式にリネームして。

## 手順

1. `mcp__ccd_session_mgmt__search_session_transcripts` を `query: "github.com/"`、`limit: 10` で呼び、PR URL を含むセッションを取得する。

2. 各セッションについて、以下をすべて満たすものだけを**改名候補**とする。
   - `snippet` の**先頭付近**が PR URL である（会話の途中で PR に言及しただけのセッションは対象外。「〜について説明して」のように URL が文中に埋もれているものは除外する）
   - 現在の `title` が `[Rv]` `[db]` `[rn]` のいずれでも始まっていない（改名済みは再処理しない）

3. 候補ごとに `gh pr view <番号> --repo <owner>/<repo> --json title,author` で PR 情報を取得し、以下の形式でタイトルを組み立てる。

   **author に `dependabot` を含む場合** — PR タイトル `bump <lib> from <old> to <new> in /<path>` から:
   ```
   [db] <repo>#<番号> <lib> to <new> <path>
   ```

   **author に `renovate` を含む場合** — PR タイトル `Update dependency <lib> to <version>` から:
   ```
   [rn] <repo>#<番号> <lib> to <version> <path>
   ```
   renovate は PR タイトルに path を含まないため、`gh pr diff <番号> --repo <slug> --name-only` の変更ファイル群の共通ディレクトリを path とする。

   **それ以外（人間の PR）**:
   ```
   [Rv] <repo>#<番号> <PRタイトルそのまま>
   ```

4. 改名前に、**候補一覧を表で提示**する（現在のタイトル → 新しいタイトル）。そのうえでユーザーの承認を得る。承認なしに `set_session_title` を呼んではいけない。

5. 承認されたら `mcp__ccd_session_mgmt__set_session_title` で各セッションをリネームし、結果を報告する。

## 注意

- 改名は元に戻しにくい操作なので、必ず 4 の確認を挟む。
- 同じ PR に対する重複セッションが複数あることがある（作業のやり直しなど）。それぞれ独立して改名してよい。
- PR 情報の取得に失敗したセッションはスキップし、その旨を報告する。
