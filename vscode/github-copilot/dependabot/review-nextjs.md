# Dependabot PR 調査プロンプト（Next.js / TypeScript / refine）

本テンプレートは Next.js(Typescript) と refine を採用するフロントエンド向けです。共通フローは `review-general.md` を参照。

## 実行前前提
- Node.js / pnpm or npm が利用可能
- lockfile 更新はDependabot管理

## 動作確認チェックリスト

### 1) 依存とビルドの健全性
```bash
# パッケージの整合性
npm ci || pnpm install --frozen-lockfile

# 型チェック
npm run typecheck || tsc -p .

# Lint
npm run lint

# セキュリティ監査
npm audit --audit-level=high || true

# Next.js ビルド
npm run build

# refine（該当時）ビルド確認
# refine は通常 Next と同一ビルドで検知されます。
```

### 2) ランタイム軽検証（任意）
```bash
npm run start -- -p 3000 &
# ヘルスチェック (別ターミナル)
curl -sSf http://localhost:3000/ | head -c 200
```

### 3) 影響箇所検索
```bash
grep -r "from '\\?<package>'\|require(\\?'<package>')" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" .
```

### 4) ライブラリ基本情報
```bash
npm info <package>
```

## 証跡に含める推奨出力
- npm ci / build / typecheck / lint / audit の出力
- Next.js の Build ID と warnings
- 変更箇所 grep 結果

## よくある追加確認
- ESLint ルール更新に伴う `eslint.config.js` の影響
- Next.js メジャーでの config 互換 (`next.config.js|mjs`)
- SWC/webpack バージョン連動

## メインレポートの補助項目
- ページ/コンポーネントのビルド影響
- refine のリソース・データプロバイダ関連変更
