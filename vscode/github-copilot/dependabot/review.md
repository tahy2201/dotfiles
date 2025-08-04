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
**重要**: 必ずGitHubに直接アクセスしてPRの正確な情報を確認してください。

**推奨**: GitHub CLIを使用してください（プライベートリポジトリでも認証済みであれば利用可能）。

```bash
# GitHub CLIを使用してPRの詳細情報を取得
gh pr view [PR番号またはURL] --json title,body,files,author,headRefName,baseRefName,state,statusCheckRollup,mergeable
```

**⚠️ 注意**: PRの内容が古い情報やキャッシュと異なる可能性があるため、必ずGitHubの最新情報を確認すること。

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

### Step 3.5: ライブラリ詳細調査
**重要**: チームメンバーの知識レベル統一のため、以下を必ず調査・記載：

#### ライブラリ基本情報の調査
```bash
# パッケージの詳細情報取得
npm info [package-name] 
gem info [package-name]

# 公式ドキュメント・README確認
# GitHubリポジトリの README.md を参照
# 主要機能、使用目的、基本的な使い方を把握
```

#### プロジェクトでの使用状況調査
1. **使用箇所の特定**
   - どのファイルで import/require されているか
   - 設定ファイルでの使用有無
   - 依存関係チェーン（他のライブラリから間接的に使用）

2. **使用方法の分析**
   - 主要な API の使用パターン
   - 設定やオプションの使用状況
   - プロジェクト固有のカスタマイズ

3. **重要度評価**
   - プロジェクトにとっての重要性（High/Medium/Low）
   - 障害時の影響範囲
   - 代替手段の有無

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

**📁 出力フォルダ構造**:
```
dependabot-review/
└── #[PR番号]/
    ├── dependabot-review-main-report.md
    ├── dependabot-review-technical-report.md
    └── dependabot-review-[package-name]-proof.md
```

1. **メイン調査レポート** (`dependabot-review/#[PR番号]/dependabot-review-main-report.md`)
```markdown
# 🤖 Dependabot PR調査レポート

## 📦 更新内容
- **パッケージ**: [package-name]
- **更新前**: [old-version]  
- **更新後**: [new-version]
- **更新種別**: [patch/minor/major]
- **セキュリティ修正**: [Yes/No]

## � ライブラリについて
### 基本情報
- **ライブラリ名**: [package-name]
- **用途・役割**: [このライブラリが何をするものか、なぜプロジェクトで使用しているか]
- **公式リポジトリ**: [GitHub URL等]
- **主要機能**: [主な機能の箇条書き]

### プロジェクトでの使用状況
- **使用箇所**: [具体的なファイル名とパス]
- **使用方法**: [どのように使われているか]
- **重要度**: [High/Medium/Low] - プロジェクトにとっての重要性
- **代替可能性**: [他のライブラリで置き換え可能か]

## �🔍 変更内容詳細
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

## 🔧 手動確認が必要な場合
**⚠️ 手動確認要否**: [必要/不要]

### 手動確認項目（該当する場合のみ）
- [ ] **機能テスト**: [具体的なテスト手順]
- [ ] **パフォーマンステスト**: [測定方法と基準値]
- [ ] **設定ファイル確認**: [確認すべきファイルと項目]
- [ ] **依存関係確認**: [他ライブラリとの競合チェック]

### 手動確認手順
```bash
# 手動確認が必要な場合の具体的なコマンド例
[確認コマンド1]
[確認コマンド2]
[期待される結果の説明]
```

## 💬 詳細コメント
[その他気づいた点や注意事項]

---
*調査実施日時: [YYYY-MM-DD HH:MM:SS]*  
*調査者: GitHub Copilot (自動調査)*
*PR番号: #[PR番号]*
```

2. **技術検証レポート** (`dependabot-review/#[PR番号]/dependabot-review-technical-report.md`)
   - 詳細な検証結果、コマンド出力、互換性確認
   - **重要**: 全てのコマンド実行結果を証跡として含めること

3. **実証テストレポート** (`dependabot-review/#[PR番号]/dependabot-review-[package-name]-proof.md`)
   - 実際の動作テスト結果、Before/After比較、証跡データ
   - **重要**: SQL実行結果はJSON形式で記録

### Step 7: 証跡記録の実施
調査完了後、以下のコマンドでPRにコメントを投稿：
```bash
# PR番号を変数に設定
PR_NUMBER=[PR番号]

# レポートファイルのパスを設定
REPORT_DIR="dependabot-review/#${PR_NUMBER}"

# コメント投稿
gh pr comment ${PR_NUMBER} --body "$(cat ${REPORT_DIR}/dependabot-review-main-report.md)"
gh pr comment ${PR_NUMBER} --body "$(cat ${REPORT_DIR}/dependabot-review-technical-report.md)"  
gh pr comment ${PR_NUMBER} --body "$(cat ${REPORT_DIR}/dependabot-review-[package-name]-proof.md)"
```

**📁 ファイル管理**:
- 各PR調査のレポートは `dependabot-review/#[PR番号]/` フォルダに保存
- 過去の調査結果も保持され、比較参照が容易
- ファイル名規則を統一して管理効率を向上

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

## 🔧 手動確認判定基準

### 自動確認で十分な場合
- パッチ・マイナーアップデート
- Breaking changesなし
- 全CI/CDテストパス
- セキュリティ問題なし
- 設定変更不要

### 手動確認が必要な場合
- **メジャーアップデート**: API変更の可能性
- **設定ファイル影響**: 新しい設定オプション追加
- **データベース関連**: マイグレーション、クエリ影響
- **パフォーマンス影響**: 重要な処理の変更
- **外部サービス連携**: API変更、認証方式変更
- **UI/UX関連**: 見た目や操作に影響する変更

### 手動確認手順テンプレート
```bash
# 1. 開発環境での動作確認
[環境セットアップコマンド]

# 2. 主要機能のテスト
[機能テストコマンド]

# 3. パフォーマンステスト（必要に応じて）
[ベンチマークコマンド]

# 4. 結果の確認
[期待値との比較方法]
```

## 🚀 使用方法

```
@workspace /file:vscode/github-copilot/dependabot-quick-review.md

現在のDependabot PR を包括調査してください
```

---
*このプロンプトは Thor 1.4.0 調査をベースに作成*
