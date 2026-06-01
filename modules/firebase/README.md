# modules/firebase

GCP Project を **Firebase 化** する submodule。

## 作成するリソース

| Resource | Provider | 役割 |
|----------|----------|------|
| `google_firebase_project.this` | `google-beta` | GCP Project を Firebase Project として有効化 |

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | Firebase project ID |
| `display_name` | Firebase project display name |

## 関連 API

- `firebase.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.firebase != null` (デフォルト `true`) の場合に呼び出される。これを `null` にすると Firebase 化されず、他の Firebase 系 submodule (`auth`, `firestore`, `hosting` 等) も依存解決のために `module.firebase` を待たないだけで、本来 Firebase 化前提のリソース作成はエラーになりうる。**通常は `true` のままにする**。
