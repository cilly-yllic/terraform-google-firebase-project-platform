# Upgrade Guide

Registry バージョン間の breaking change を時系列で記録する。

各リリースは [GitHub Releases](https://github.com/cilly-yllic/terraform-google-firebase-project-platform/releases) で参照可能。

---

## v0.x → v1.0 (Registry 初版に向けて)

Registry 公開前は破壊的変更を集約することを許容する。`v1.0.0` 以降は SemVer に従い、破壊的変更は **major bump のみ** で行う。

---

## v1.x のポリシー

- **新規機能変数の追加**: minor bump (`v1.x.0`)
- **既定値の変更で副作用が発生するもの**: minor bump + CHANGELOG で警告
- **既存変数の型変更 / 削除**: major bump (`v2.0.0`)
- **submodule の output 削除 / rename**: major bump
- **`firebase` 既定値を `null` 化**するような全体方針変更: major bump

---

## 互換性チェックリスト (PR レビュー時)

新たな破壊的変更を入れる前に確認するチェックリスト:

- [ ] 既存利用者の `terraform plan` で **削除を伴う diff** が出ないか
- [ ] outputs の rename / 削除を伴っていないか
- [ ] 機能変数の `null` → `true` 等で API 有効化のみ変わるパターンは副作用最小か
- [ ] CHANGELOG に migration 手順を書く必要があるか

---

## 将来の項目 (テンプレート)

```
## v1.x.0 (YYYY-MM-DD)

### Breaking changes
- `<variable>`: <変更内容>。<migration 手順>。

### Features
- <機能名>: <概要>

### Bug fixes
- <件名>
```

実際の breaking change が発生した際にこのテンプレートを上に積む形で運用する。
