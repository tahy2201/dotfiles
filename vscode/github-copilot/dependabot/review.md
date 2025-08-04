# Dependabot PR 包括調査プロンプト

指定されたDependabot PRに対して、以下の手順で包括的な調査と動作確認を実行してください：

## 🎯 調査対象
**指定されたDependabot PR**について、以下の調査を実行：

1. ✅ PR詳細情報の取得と分析
2. ✅ パッケージ変更内容の詳細調査  
3. ✅ 影響範囲の特定
4. ✅ 動作確認の実施
5. ✅ セキュリティチェック
6. ✅ 実証テスト（該当する場合）
7. ✅ 安全性評価とレポート作成

## 📋 実行手順

### Step 1: PR情報収集
```bash
# 指定されたPRの詳細情報を取得
# PRのURL/番号が指定されている場合はそれを使用、
# 指定されていない場合は現在アクティブなPRを取得
gh pr view [PR_URL_OR_NUMBER] --json title,body,files,author,headRefName,baseRefName
```

以下の情報を抽出・分析してください：
- パッケージ名
- バージョン変更（old → new）
- 変更種別（patch/minor/major）
- セキュリティアップデートかどうか
- 変更されたファイル一覧

### Step 2: 変更ログ調査
パッケージの変更ログ、リリースノート、GitHubリリースを調査し、以下を確認：
- Breaking changesの有無
- 新機能・非推奨機能
- セキュリティ修正内容
- 移行ガイドの存在

### Step 3: 影響範囲分析
プロジェクト内でのパッケージ使用箇所を特定：

```bash
# パッケージ使用箇所の検索
grep -r "パッケージ名" --include="*.rb" --include="*.js" --include="*.ts" --include="*.tsx" --include="*.json" --include="*.yml" .

# 依存関係の確認（npm/bundlerに応じて）
npm ls パッケージ名
bundle list | grep パッケージ名
```

### Step 4: 動作確認実行
以下の確認を順次実行：

#### 静的解析
```bash
# Ruby
bundle exec standardrb

# TypeScript/JavaScript  
npm run lint
```

#### セキュリティチェック
```bash
# Ruby
brakeman --no-pager -q

# JavaScript
npm audit
```

#### 実機能テスト
パッケージの主要機能を使用した実際の動作テスト：
- ヘルプコマンド実行
- 基本機能実行
- オプション動作確認
- エラーハンドリング確認

### Step 5: 実証テスト（該当する場合）
データベース操作やファイル操作を伴うパッケージの場合：

#### 実行前状態確認
```sql
-- 関連テーブルの状態を確認
SELECT 'Before execution' as status, COUNT(*) as count FROM 対象テーブル;
```

#### テスト実行
```bash
# 実際のコマンド/機能を実行
実行コマンド
```

#### 実行後状態確認
```sql
-- 実行後の状態を確認
SELECT 'After execution' as status, COUNT(*) as count FROM 対象テーブル;
```

### Step 6: レポート生成と証跡記録
以下の3つのレポートファイルを作成してPRにコメント投稿：

1. **メイン調査レポート** (`dependabot-review-main-report.md`)
```markdown
# 🤖 Dependabot PR調査レポート

## 📦 更新内容
- **パッケージ**: [package-name]
- **更新前**: [old-version]  
- **更新後**: [new-version]
- **更新種別**: [patch/minor/major]
- **セキュリティ修正**: [Yes/No]

## 🔍 変更内容詳細
[重要な変更点のサマリー]

## 🎯 影響範囲
- **使用箇所**: [ファイル数とパス]
- **影響度**: [High/Medium/Low]
- **Breaking Changes**: [Yes/No]

## ✅ 動作確認結果
- **静的解析**: [✅ Pass / ❌ Fail]
- **セキュリティ**: [✅ Pass / ⚠️ 要確認]
- **実機能テスト**: [✅ Pass / ❌ Fail]

## 🚨 推奨アクション
- [ ] 自動承認可能
- [ ] 手動レビュー必要
- [ ] 追加テスト必要

## 💬 詳細コメント
[その他気づいた点や注意事項]

---
*調査実施日時: [YYYY-MM-DD HH:MM:SS]*  
*調査者: GitHub Copilot (自動調査)*
```

2. **技術検証レポート** (`dependabot-review-technical-report.md`)
   - 詳細な検証結果、コマンド出力、互換性確認
   - **重要**: 全てのコマンド実行結果を証跡として含めること

3. **実証テストレポート** (`dependabot-review-[package-name]-proof.md`)
   - 実際の動作テスト結果、Before/After比較、証跡データ
   - **重要**: SQL実行結果はJSON形式で記録

### Step 7: 証跡記録の実施
調査完了後、以下のコマンドでPRにコメントを投稿：
```bash
gh pr comment [PR番号] --body "$(cat dependabot-review-main-report.md)"
gh pr comment [PR番号] --body "$(cat dependabot-review-technical-report.md)"  
gh pr comment [PR番号] --body "$(cat dependabot-review-[package-name]-proof.md)"
```

## 🔧 必須要件

### 証跡記録
- 全てのコマンド実行結果を含めること
- SQL実行結果はJSON形式で記録
- エラーログも含めて完全な出力を記載

### レポート品質
- 具体的なコマンドと出力結果
- 判断根拠の明示
- 推奨アクションの理由

## 🚨 エスカレーション条件

以下の場合は即座に人間のレビューが必要：
- メジャーバージョンアップ
- Breaking changesを含む
- テスト・ビルド失敗
- 新しいセキュリティ脆弱性
- 設定ファイルへの影響

## 🚀 使用方法

```
@workspace /file:vscode/github-copilot/dependabot-quick-review.md

現在のDependabot PR を包括調査してください
```

---
*このプロンプトは Thor 1.4.0 調査をベースに作成*
