# Dependabot PR 調査プロンプト（Rails）

本テンプレートは Rails/Ruby 向けです。共通フローは `review-general.md` を参照。

## 実行前前提
- bundler がセットアップ済み

## 動作確認チェックリスト

### 1) 依存の整合性
```bash
bundle install --path vendor/bundle
bundle lock --update <gem名> # 必要時
```

### 2) 静的解析
```bash
bundle exec standardrb
```

### 3) セキュリティ
```bash
# brakeman（Railsアプリのみ）
brakeman --no-pager -q

# bundler-audit（導入済みの場合）
bundle audit check --update || true
```

### 4) テスト/動作
```bash
# テスト
bundle exec rspec || bundle exec rails test || true

# 簡易起動確認（任意）
bundle exec rails db:prepare
bundle exec rails runner 'puts :ok'
```

### 5) 使用箇所検索
```bash
grep -r "require \'<gem名>\'\|<gem名>" --include="*.rb" .
```

### 6) ライブラリ基本情報
```bash
gem info <gem名>
```

## 証跡に含める推奨出力
- standardrb / brakeman / (bundler-audit)の結果
- テスト結果
- 使用箇所 grep 結果
