# modules/rtdb

Firebase Realtime Database instance を作成する submodule。

## 作成するリソース

| Resource | Provider | 役割 |
|----------|----------|------|
| `google_firebase_database_instance.this` | `google-beta` | RTDB instance (`{project}-default-rtdb`) |

instance ID は `{project}-default-rtdb` 固定 (現状カスタマイズ不可)。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |
| `location` | `string` | (required) | RTDB location (`us-central1`, `asia-southeast1` 等) |
| `type` | `string` | `"DEFAULT_DATABASE"` | `DEFAULT_DATABASE` / `USER_DATABASE` |

## Outputs

| Name | Description |
|------|-------------|
| `name` | RTDB instance resource name |
| `database_url` | RTDB の HTTPS URL |

## 関連 API

- `firebasedatabase.googleapis.com`

## ルートモジュールでの呼び出し条件

`var.rtdb != null` の場合に呼び出される。
