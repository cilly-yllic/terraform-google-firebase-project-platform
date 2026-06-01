# modules/secret-manager

Secret Manager API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。実 main.tf は API 有効化のための拡張ポイントとしてのみ存在し、現状は空。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |

## Outputs

| Name | Description |
|------|-------------|
| `enabled` | 常に `true` (この submodule が呼ばれていれば Secret Manager は有効) |

## 関連 API

- `secretmanager.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.secret_manager != null` の場合に呼び出される。

## 設計意図

Secret (`google_secret_manager_secret`) 自体は本モジュールでは作成しない。秘匿情報のライフサイクルは個別の Terraform stack / Secret Manager CLI / Console で管理する想定。

将来 Secret 自体や IAM binding を本モジュール経由で管理したくなった場合に拡張する拠点として残している。
