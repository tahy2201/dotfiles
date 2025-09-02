# Dependabot PR 調査プロンプト（Terraform / AWS）

本テンプレートは Terraform(AWS) インフラ向けです。共通フローは `review-general.md` を参照。

## 実行前前提
- terraform / tflint / tfsec / checkov が利用可能
- backend や provider は読み取り専用で確認（applyは原則禁止）

## 動作確認チェックリスト

### 1) 初期化と検証
```bash
terraform init -backend=false
terraform validate
```

### 2) Lint/静的解析
```bash
tflint --no-color

# セキュリティ
tfsec . || true
checkov -d . || true
```

### 3) 影響差分（読み取り）
```bash
# backend を使わない plan（stateは参照しない範囲で）
terraform plan -refresh=false -lock=false -input=false -no-color || true
```

### 4) 使用箇所検索
```bash
grep -r "source\s*=\s*\"<module-or-registry>\"\|provider \"<name>\"" --include="*.tf" .
```

### 5) ライブラリ（Provider/Module）情報
- Registry の CHANGELOG/Release notes を確認

## 証跡に含める推奨出力
- validate / tflint / tfsec / checkov の結果
- plan の差分サマリ（state非依存）
