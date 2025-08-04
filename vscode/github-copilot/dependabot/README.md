# Dependabot PR調査ツール

Dependabot PRの調査・承認プロセスを自動化するためのプロンプトテンプレートです。

## 📁 ファイル構成

```
vscode/github-copilot/dependabot/
├── review.md     # 包括的な調査プロンプト（メイン）
└── README.md     # このファイル（使用方法説明）
```

## 🚀 使用方法

### GitHub Copilot使用

#### パターン1: 現在アクティブなPRを調査
```
@workspace /file:vscode/github-copilot/dependabot/review.md

現在のDependabot PR を包括調査してください
```

#### パターン2: 特定のPRを指定して調査
```
@workspace /file:vscode/github-copilot/dependabot/review.md

以下のDependabot PR を包括調査してください:
https://github.com/owner/repo/pull/1234
```

または

```
@workspace /file:vscode/github-copilot/dependabot/review.md

Dependabot PR #1234 を包括調査してください
```

### 🎯 Copilotが自動実行する内容
- PR詳細情報の取得と分析
- パッケージ変更内容の詳細調査  
- 影響範囲の特定
- 動作確認（静的解析・セキュリティチェック）
- 実証テスト（該当する場合）
- 3つの詳細レポート生成
- **🔖 PRへの調査証跡コメント投稿**

## 📊 生成されるレポート

### 1. メイン調査レポート
- パッケージ基本情報
- 影響範囲と安全性評価
- 推奨アクション

### 2. 技術検証レポート
- 詳細な検証結果
- コマンド実行出力
- 互換性確認結果

### 3. 実証テストレポート
- 実際の動作テスト結果
- Before/After比較データ
- SQL実行証跡（JSON形式）

## 💡 特徴

- **包括性**: 技術調査から実証テストまで一連の流れを自動化
- **証跡重視**: 全ての検証結果を詳細に記録
- **自動投稿**: GitHub CLIを使用してPRに調査結果を自動投稿
- **標準化**: ファイル名やフォーマットを統一して再利用性を向上

## 📋 調査項目

### ✅ 自動チェック項目
- [ ] パッケージ情報の抽出
- [ ] バージョン変更タイプ（patch/minor/major）
- [ ] 変更ログ・リリースノートの確認
- [ ] プロジェクト内使用箇所の特定
- [ ] 静的解析（standardrb, eslint等）
- [ ] セキュリティ脆弱性チェック
- [ ] 実機能テスト（該当する場合）

### 🚨 エスカレーション判定
- メジャーバージョンアップ
- Breaking changes含有
- テスト・ビルド失敗
- セキュリティ脆弱性検出
- 設定ファイル変更

## 🎯 判定結果

### ✅ 自動承認可能
- パッチ・マイナーアップデート
- 全テストパス
- Breaking changesなし
- セキュリティ問題なし

### ⚠️ 手動レビュー必要
- メジャーアップデート
- テスト失敗
- 設定変更必要
- セキュリティ要確認

### 🚨 緊急対応必要
- クリティカル脆弱性修正
- ビルド破綻
- 重大なBreaking changes

## 📝 レポート例

```markdown
# 🤖 Dependabot PR調査レポート

## 📦 更新内容
- **パッケージ**: thor
- **更新前**: 1.3.2  
- **更新後**: 1.4.0
- **更新種別**: minor
- **セキュリティ修正**: No

## 🔍 変更内容詳細
- 新機能追加: enhanced error handling
- 非推奨機能なし
- Breaking changesなし

## 🎯 影響範囲
- **使用箇所**: 3ファイル (Gemfile, lib/tasks/*.rb)
- **影響度**: Low
- **Breaking Changes**: No

## ✅ 動作確認結果
- **静的解析**: ✅ Pass
- **セキュリティ**: ✅ Pass
- **実機能テスト**: ✅ Pass

## 🚨 推奨アクション
- [x] 自動承認可能

---
*調査実施日時: 2025-08-04 XX:XX:XX*  
*調査者: GitHub Copilot (自動調査)*
```

## 🔧 カスタマイズ

### 対応パッケージマネージャー
- npm (JavaScript/TypeScript)
- bundler (Ruby)
- 追加可能: pip, poetry, composer等

### 追加できるチェック項目
- パフォーマンステスト
- E2Eテスト
- Docker builds
- 特定環境での動作確認

---

このツールを使用して、Dependabot PRの効率的で安全な管理を実現しましょう！💯