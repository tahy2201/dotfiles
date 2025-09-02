# Dependabot PR 包括調査プロンプト（共通）

このテンプレートは言語非依存の共通フローです。実行コマンドは各言語別テンプレート（Next.js/Rails/Python(uv)/Terraform(AWS)）を参照してください。

## 🎯 調査対象
指定されたDependabot PRについて、以下の調査を実行：

1. ✅ PR詳細情報の取得と分析
2. ✅ パッケージ変更内容の詳細調査
3. ✅ 影響範囲の特定
4. ✅ 動作確認の実施（各言語テンプレ参照）
5. ✅ セキュリティチェック（各言語テンプレ参照）
6. ✅ 実証テスト（該当する場合）
7. ✅ 安全性評価とレポート作成

---

## 📋 実行手順（共通）

### Step 1: PR情報収集（必須）
GitHubの最新情報を取得して分析します。

```bash
# GitHub CLIでPRの詳細を取得
# 例: gh pr view 123 --json ...
gh pr view [PR番号またはURL] \
  --json title,body,files,author,headRefName,baseRefName,state,statusCheckRollup,mergeable
```
抽出・分析:
- パッケージ名 / バージョン変更（old→new） / 変更種別（patch/minor/major）
- セキュリティアップデートか
- 変更ファイル一覧

### Step 2: 変更ログ調査
- リリースノート/CHANGELOG/タグを確認
- Breaking changes / 新機能 / 非推奨 / セキュリティ修正 / 移行ガイド

### Step 3: 影響範囲分析（共通観点）
- プロジェクト内使用箇所の特定（import/require、設定、間接依存）
- 実行時に影響を受けるワークスペース（アプリ/ワーカー/インフラ 等）

参考コマンド（例）：
```bash
grep -r "<パッケージ名>" --include="*.rb" --include="*.js" --include="*.ts" --include="*.tsx" \
  --include="*.json" --include="*.yml" --include="*.yaml" .
```

### Step 3完了時点: 中間調査レポート出力（必須）
Step 3までの調査結果を中間レポートとして出力し、進捗確認と問題の早期発見を行います。

出力ファイル:
```
dependabot-review/
└── #[PR番号またはコミットハッシュ]/
    └── dependabot-review-main-report-interim.md
```

中間レポート雛形:
```markdown
# 🤖 Dependabot PR中間調査レポート（Step 3完了）

## 📦 更新内容
- パッケージ: [package-name]
- 更新前: [old-version]
- 更新後: [new-version]
- 種別: [patch/minor/major]
- セキュリティ修正: [Yes/No]

## 🔍 変更内容詳細
[重要な変更点・Breaking Changes]

## 🎯 影響範囲
- 使用箇所: [...]
- 影響度: [High/Medium/Low]
- Breaking Changes: [Yes/No]

## 📋 次のステップ（Step 4以降で実施）
- [ ] 依存関係整合性確認
- [ ] 静的解析・セキュリティチェック  
- [ ] テスト実行による動作確認

---
*中間調査実施日時: [YYYY-MM-DD HH:MM]*  
*調査者: GitHub Copilot (自動調査)*  
*PR番号: #[PR番号]*
```

### Step 3.5: ライブラリ詳細調査（必須）
- 公式説明（READMEから引用）
- 主要機能（3つ以上）
- 解決する課題 / カテゴリ / 人気度（DL・Star）
- 代替手段

参考（npm/gem）:
```bash
npm info <package>
# gemの場合
# gem info <package>
```

### Step 4: 動作確認実行（各言語テンプレ参照）
- 静的解析
- セキュリティチェック
- 実機能テスト（ヘルプ表示、基本機能、オプション、エラー動作）

### Step 5: 実証テスト（該当する場合のみ）
- Before/Afterの状態取得
- 実行コマンド
- Afterの状態取得（DB等はJSONで保存）

### Step 6: レポート生成と証跡記録（必須）
出力フォルダ:
```
dependabot-review/
└── #[PR番号]/
    ├── dependabot-review-main-report.md
    ├── dependabot-review-technical-report.md
    └── dependabot-review-[package-name]-proof.md
```

メイン調査レポート雛形:
```markdown
# 🤖 Dependabot PR調査レポート

## 📦 更新内容
- パッケージ: [package-name]
- 更新前: [old-version]
- 更新後: [new-version]
- 種別: [patch/minor/major]
- セキュリティ修正: [Yes/No]

## 📚 ライブラリについて
- 用途・役割: [...]
- 公式リポジトリ: [...]
- 主要機能: [...]

## 🔍 変更内容詳細
[重要な変更点]

## 🎯 影響範囲
- 使用箇所: [...]
- 影響度: [High/Medium/Low]
- Breaking Changes: [Yes/No]

## ✅ 動作確認結果
- 静的解析: [✅/❌]
- セキュリティ: [✅/⚠️]
- 実機能テスト: [✅/❌]

## 🚨 推奨アクション
- [ ] 自動承認可能
- [ ] 手動レビュー必要
- [ ] 追加テスト必要

---
*調査実施日時: [YYYY-MM-DD HH:MM]*  
*調査者: GitHub Copilot (自動調査)*  
*PR番号: #[PR番号]*
```

### Step 7: 証跡記録（コメント投稿）
```bash
PR_NUMBER=[PR番号]
REPORT_DIR="dependabot-review/#${PR_NUMBER}"

gh pr comment ${PR_NUMBER} --body "$(cat ${REPORT_DIR}/dependabot-review-main-report.md)"
gh pr comment ${PR_NUMBER} --body "$(cat ${REPORT_DIR}/dependabot-review-technical-report.md)"
gh pr comment ${PR_NUMBER} --body "$(cat ${REPORT_DIR}/dependabot-review-[package-name]-proof.md)"
```

---

## 🚨 エスカレーション条件（共通）
- メジャーアップデート / Breaking changes
- ビルド・テスト失敗
- 新規セキュリティ脆弱性
- 設定ファイルへの影響

## 🔧 手動確認が必要な場合（共通）
- 環境セットアップ / 主要機能テスト / ベンチマーク / 期待値照合

> 実コマンドは各言語テンプレートをご利用ください。
