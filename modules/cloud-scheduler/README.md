# modules/cloud-scheduler

Cloud Scheduler API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。Job (`google_cloud_scheduler_job`) 自体は本モジュールでは作成しない。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |
| `location` | `string` | (required) | Cloud Scheduler location |

## Outputs

なし。

## 関連 API

- `cloudscheduler.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.cloud_scheduler != null` の場合に呼び出される。

## 設計意図

定期実行 job は service 側のドメインロジックに紐づくため、別 Terraform stack で管理されることが多い。本モジュールでは API 有効化のみ。
