# Dependabot PR 包括調査プロンプト（共通）

このテンプレートは言語非依存の共通フローです。実行コマンドは各言語別テンプレート（Next.js/Rails/Python(uv)/Terraform(AWS)）を参照してください。

## 🎯 調査対象
指定されたDependabot PRについて、以下の調査を実行：

1. ✅ PR詳細情報の取得と分析
2. ✅ パッケージ変更内容の詳細調査
3. ✅ 変更ログ調査
4. ✅ 影響範囲の特定
5. ✅ ブランチ切り替えと環境準備
6. ✅ 動作確認の実施（各言語テンプレ参照）
7. ✅ セキュリティチェック（各言語テンプレ参照）
8. ✅ 実証テスト（該当する場合）
9. ✅ 安全性評価とレポート作成

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

### Step 2: ライブラリ詳細調査（必須）
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

### Step 3: 変更ログ調査
- リリースノート/CHANGELOG/タグを確認
- Breaking changes / 新機能 / 非推奨 / セキュリティ修正 / 移行ガイド
- 必ずwebアクセスして確認すること

### Step 4: 影響範囲分析（共通観点）
- プロジェクト内使用箇所の特定（import/require、設定、間接依存）
- 実行時に影響を受けるワークスペース（アプリ/ワーカー/インフラ 等）

参考コマンド（例）：
```bash
grep -r "<パッケージ名>" --include="*.rb" --include="*.js" --include="*.ts" --include="*.tsx" \
  --include="*.json" --include="*.yml" --include="*.yaml" .
```

### Step 5: ブランチ切り替えと環境準備（必須）
⚠️ **重要**: PRの実際の変更内容を検証するため、対象ブランチに切り替えます。

```bash
# 現在のブランチを確認
git branch --show-current

# PRのブランチに切り替え
git checkout [PR-branch-name]
# 例: git checkout dependabot/npm_and_yarn/ruff-0.12.11

# 依存関係を最新の状態に同期
# npm の場合
npm ci
# uv の場合  
uv sync --frozen
# bundle の場合
bundle install --frozen
```

**注意事項**:
- 検証完了後は必ず元のブランチに戻る: `git checkout main`
- PRブランチ名は Step 1 で取得した `headRefName` を使用
- 依存関係の同期でエラーが発生した場合はレポートに記録

### Step 5完了時点: 中間調査レポート出力（必須）
Step 4までの調査結果を中間レポートとして出力し、進捗確認と問題の早期発見を行います。

出力ファイル:
```
dependabot-review/
└── #[PR番号またはコミットハッシュ]/
    └── dependabot-review-main-report-interim.md
```

中間レポート雛形:
```markdown
# 🤖 Dependabot PR中間調査レポート（Step 4完了）

## 📦 更新内容
- パッケージ: [package-name]
- 更新前: [old-version]
- 更新後: [new-version]
- 種別: [patch/minor/major]
- セキュリティ修正: [Yes/No]

## 対象ライブラリについて
- 公式説明（READMEから引用）
- 主要機能（3つ以上）
- 解決する課題 / カテゴリ / 人気度（DL・Star）

## 🔍 変更内容詳細
[重要な変更点・Breaking Changes]

## 🎯 影響範囲
- 使用箇所: [...]
- 影響度: [High/Medium/Low]
- Breaking Changes: [Yes/No]

## 📋 次のステップ
- [ ] 依存関係整合性確認
- [ ] 静的解析・セキュリティチェック  
- [ ] テスト実行による動作確認

---
*中間調査実施日時: [YYYY-MM-DD HH:MM]*  
*調査者: GitHub Copilot (自動調査)*  
*PR番号: #[PR番号]*
```

### Step 6: 動作確認実行（各言語テンプレ参照）
⚠️ **前提**: Step 5 でPRブランチに切り替えた状態で実行

- 静的解析
- セキュリティチェック
- 実機能テスト（ヘルプ表示、基本機能、オプション、エラー動作）

### Step 7: 実証テスト（該当する場合のみ）
- Before/Afterの状態取得
- 実行コマンド
- Afterの状態取得（DB等はJSONで保存）

### Step 8: レポート生成と証跡記録（必須）
出力フォルダ:
```
dependabot-review/
└── #[PR番号]/
    ├── dependabot-review-main-report.md
    ├── dependabot-review-technical-report.md
    └── dependabot-review-[package-name]-proof.md
```

### 🔄 自動レポート同期ルール（重要）
**検証中に以下の状況が発生した場合、自動的にレポートファイルを最新状態に同期すること：**

#### 1. 検証ステップの再実行時
- **トリガー**: 環境問題解決後の再実行、追加検証の実施
- **自動処理**: 
  - 古い検証結果を新しい結果で上書き更新
  - 実行日時を現在時刻に自動更新
  - 検証ステータス（❌→✅等）を自動修正

#### 2. 口頭報告後の自動ファイル反映
- **トリガー**: 検証完了を口頭で報告した時点
- **自動処理**:
  - 報告内容を対応するレポートファイルに即座に記載
  - 結論・推奨アクションを自動更新
  - 全レポート間の整合性を自動保持

#### 3. 検証環境の状態変化検知
- **トリガー**: PRブランチ切り替え、依存関係解決、新しいテスト実行
- **自動処理**:
  - 古い環境での検証結果を新環境の結果で自動置換
  - 「最新」「更新済み」のラベルを自動付与
  - タイムスタンプの自動一括更新

#### 実装原則：
- **プロアクティブ更新**: ユーザーの指摘を待たずに自動更新
- **リアルタイム同期**: 検証実行と同時にレポート更新
- **整合性保証**: 全レポートファイル間での情報の一貫性を自動維持
- **証跡保持**: 初回調査時刻と最終検証時刻の両方を記録

## 📋 レポート構成と役割分担

### 1. メイン調査レポート（main-report.md）
**目的**: 調査結果の総合的な要約とApprove判定
**対象**: 開発者・マネージャー向け

```markdown
# 🤖 Dependabot PR調査レポート

## 📦 更新内容
- パッケージ: [package-name]
- 更新前: [old-version]
- 更新後: [new-version]
- 種別: [patch/minor/major]
- セキュリティ修正: [Yes/No]

## 📚 ライブラリについて
- 用途・役割: [パッケージが解決する問題・役割]
- 公式リポジトリ: [GitHubリンク]
- 主要機能: 
  1. [機能1]
  2. [機能2]
  3. [機能3]

## 対象ライブラリについて
- 公式説明（READMEから引用）
- 解決する課題 / カテゴリ / 人気度（DL・Star）

## 🔍 変更内容詳細
[v[old] → v[new]の重要な変更点・Bug fixes・新機能]

## 🎯 影響範囲
- 使用箇所: [具体的なファイル・箇所]
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

### 承認理由 (自動承認可能の場合)
1. [理由1: バージョン種別・Breaking Changes]
2. [理由2: 環境影響範囲]
3. [理由3: テスト結果]
4. [理由4: 変更内容の性質]
5. [理由5: CI/CDステータス]

---
*調査実施日時: [YYYY-MM-DD HH:MM]*  
*調査者: [Claude code/Github copilot(model名)/その他agent名など]*  
*PR番号: #[PR番号]*
```

### 2. 技術詳細レポート（technical-report.md）
**目的**: 技術的影響分析・アーキテクチャ観点
**対象**: 技術リード・アーキテクト向け

```markdown
# 🔧 Dependabot PR技術詳細レポート

## PR基本情報
- PR番号: #[PR番号]
- タイトル: [PR title]
- 作成者: app/dependabot
- ブランチ: [head] → [base]
- ステータス: [OPEN/CLOSED], [MERGEABLE/CONFLICTING]
- 変更ファイル: [ファイル名] ([additions] additions, [deletions] deletions)

## 技術的詳細分析

### 依存関係の詳細
```[toml/json/yaml]
# 設定ファイルでの定義
[dependency-section]
"[package-name]": "[version-constraint]"
```

### 使用状況分析
- **直接インポート**: [有無・箇所]
- **設定ファイル**: [設定箇所・ルール]
- **間接依存**: [他の依存パッケージ経由での使用]

### バージョン間の詳細変更履歴
- **Bug fixes累積**: [件数・重要な修正]
- **Preview features追加**: [新機能・実験的機能]
- **Performance improvements**: [パフォーマンス改善]
- **Documentation updates**: [ドキュメント修正]

### アーキテクチャ影響分析
- **ワークスペース**: [影響を受けるワークスペース・ディレクトリ]
- **影響範囲**: [開発環境/本番環境/インフラ等への影響]
- **統合ポイント**: [CI/CD・ビルドプロセス・デプロイでの統合箇所]

### セキュリティ評価
- **脆弱性**: [CVE情報・セキュリティ修正有無]
- **信頼性**: [メンテナー・組織の信頼性]
- **監査**: [ランタイム・ビルドタイムでのセキュリティ影響]

### パフォーマンス影響
- **ビルド時間**: [変更有無・影響度]
- **実行時**: [ランタイムパフォーマンスへの影響]
- **メモリ使用量**: [メモリ使用量の変化]

## 推奨事項
1. **技術的リスク評価**: [リスクレベル・対処法]
2. **追加調査事項**: [必要に応じて追加調査項目]
3. **モニタリング推奨**: [アップデート後の監視項目]

---
*技術調査実施: [YYYY-MM-DD HH:MM]*  
*使用ツール: [使用したツール一覧]*  
*分析対象: [対象ワークスペース・ディレクトリ]*
```

### 3. 実証テスト記録（proof.md）
**目的**: 実際のテスト実行・コマンド結果・具体的証跡
**対象**: QA・DevOps向け

```markdown
# 📋 Dependabot PR実証テスト記録 - [package-name]

## テスト実行環境
- 作業ディレクトリ: [full-path]
- [言語]バージョン: [version]
- [パッケージマネージャー] version: [version]
- テスト日時: [YYYY-MM-DD HH:MM]

## Before/After比較
### Before ([old-version])
- 設定: [設定内容]
- 動作: [動作状況]

### After ([new-version])
- 設定: [設定内容]
- 動作: [動作状況]
- CIステータス: [CI結果]

## 実行コマンドとその結果
### 1. [テスト名]
```bash
$ [command]
[出力結果]

結果: ✅/❌ [結果説明]
```

[各テストケースを同様の形式で記録]

## 動作確認詳細
### [パッケージ名]の基本機能テスト
- **[機能1]**: [テスト結果・詳細]
- **[機能2]**: [テスト結果・詳細]
- **[設定読み込み]**: [設定ファイルの読み込み確認]

### CI/CD統合テスト結果
[CI/CDシステム名]での自動実行結果:
- ✅ [ジョブ1]: [結果]
- ✅ [ジョブ2]: [結果]
- ✅ [全体パイプライン]: [結果]

## 証跡保存データ
### [設定ファイル]差分 (主要部分)
```diff
[重要な差分を記録]
```

### パフォーマンス測定
- [操作1]処理時間: [時間] ([詳細])
- [操作2]処理: [結果・時間]

## 結論
[old-version]から[new-version]への更新は:
- ✅ [結論1]
- ✅ [結論2] 
- ✅ [結論3]

**推奨アクション: [承認/保留/拒否]**

---
*実証テスト実施者: [実施者名]*  
*実行環境: [OS + tools]*  
*検証完了時刻: [YYYY-MM-DD HH:MM]*
```

### Step 9: 証跡記録とクリーンアップ（必須）

#### レポートコメント投稿
```bash
PR_NUMBER=[PR番号]
REPORT_DIR="dependabot-review/#${PR_NUMBER}"

gh pr comment ${PR_NUMBER} --body "$(cat ${REPORT_DIR}/dependabot-review-main-report.md)"
gh pr comment ${PR_NUMBER} --body "$(cat ${REPORT_DIR}/dependabot-review-technical-report.md)"
gh pr comment ${PR_NUMBER} --body "$(cat ${REPORT_DIR}/dependabot-review-[package-name]-proof.md)"
```

#### ブランチクリーンアップ（必須）
```bash
# 元のブランチに戻る
git checkout main

# 作業ディレクトリの状態確認
git status
```

**チェックリスト**:
- [ ] 全レポートファイルが生成済み
- [ ] PRにコメント投稿完了
- [ ] 元のブランチ（main等）に戻った
- [ ] 作業ディレクトリがクリーンな状態

---

## 🚨 エスカレーション条件（共通）
- メジャーアップデート / Breaking changes
- ビルド・テスト失敗
- 新規セキュリティ脆弱性
- 設定ファイルへの影響

## 🔧 手動確認が必要な場合（共通）
- 環境セットアップ / 主要機能テスト / ベンチマーク / 期待値照合

> 実コマンドは各言語テンプレートをご利用ください。
