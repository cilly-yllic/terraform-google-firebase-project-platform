# modules/eventarc

Eventarc API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。Trigger 自体は本モジュールでは作成しない。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |
| `location` | `string` | (required) | Eventarc location |

## Outputs

なし。

## 関連 API

- `eventarc.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.eventarc != null` の場合に呼び出される。

## 設計意図

Eventarc trigger は target (Cloud Run / Cloud Function) と密結合するため、target 側の Terraform stack で管理する想定。
