# Dependabot PR 調査プロンプト（Python / uv）

本テンプレートは Python で uv を使うプロジェクト向けです。共通フローは `review-general.md` を参照。

## 実行前前提
- uv が導入済み（https://github.com/astral-sh/uv）
- pyproject.toml / uv.lock 管理

## 動作確認チェックリスト

### 1) 依存の整合性
```bash
uv sync --frozen
```

### 2) 静的解析
```bash
# ruff
uv run ruff check .

# mypy（型定義がある場合）
uv run mypy . || true
```

### 3) セキュリティ
```bash
# pip-audit を uv 経由で
uv run pip-audit -r requirements.txt || true
# または pyproject/lock を直接
uv export -f requirements.txt | uv run pip-audit -r /dev/stdin || true
```

### 4) テスト
```bash
uv run pytest -q || true
```

### 5) 使用箇所検索
```bash
grep -r "import <package>\|from <package> import" --include="*.py" .
```

### 6) ライブラリ基本情報
```bash
uv run python - <<'PY'
import json, pkgutil
# ここではPyPI API利用は省略し、プロジェクト内メタ情報の確認例
print("ok")
PY
```

## 証跡に含める推奨出力
- uv sync / ruff / mypy / pytest / pip-audit の結果
- 使用箇所 grep 結果
