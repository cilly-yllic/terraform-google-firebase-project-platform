# modules/cloud-tasks

Cloud Tasks API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。Queue (`google_cloud_tasks_queue`) 自体は本モジュールでは作成しない。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |
| `location` | `string` | (required) | Cloud Tasks location (root module から `var.region` または `cloud_tasks.location` が渡される) |

## Outputs

なし。

## 関連 API

- `cloudtasks.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.cloud_tasks != null` の場合に呼び出される。

## 設計意図

queue は service 単位 / 用途単位で別 Terraform stack や Service Account から作成するケースが多いため、本モジュールでは API 有効化のみに留めている。queue を本モジュール経由で管理したくなった場合の拡張ポイントとして残している。
