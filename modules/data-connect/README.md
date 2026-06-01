# modules/data-connect

Firebase Data Connect service と、任意で Cloud SQL instance / database を作成する submodule。

## 作成するリソース

| Resource | Provider | 役割 |
|----------|----------|------|
| `google_firebase_data_connect_service.this` | `google-beta` | Data Connect service |
| `google_sql_database_instance.this` | `google` | (任意) Cloud SQL instance (`cloud_sql != null` の場合のみ) |
| `google_sql_database.this` | `google` | (任意) Cloud SQL database |

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |
| `location` | `string` | (required) | Data Connect / Cloud SQL location |
| `service_id` | `string` | `"{project}-dataconnect"` (空文字フォールバック) | Data Connect service ID |
| `cloud_sql` | `object \| null` | `null` | Cloud SQL 設定。`null` なら SQL 関連リソースは作成しない |

`cloud_sql` のフィールド:

| Field | Default | Description |
|-------|---------|-------------|
| `instance_id` | `"{project}-fdc"` | Cloud SQL instance 名 |
| `database` | `project` | database 名 |
| `tier` | `"db-f1-micro"` | machine tier |
| `database_version` | `"POSTGRES_15"` | PostgreSQL バージョン |
| `deletion_protection` | `false` | instance の delete 保護 |

## Outputs

| Name | Description |
|------|-------------|
| `name` | Data Connect service resource name |
| `cloud_sql_instance_name` | Cloud SQL instance 名 (なければ `null`) |
| `cloud_sql_connection_name` | Cloud SQL connection name |
| `cloud_sql_database` | database 名 |

## 関連 API

- `firebasedataconnect.googleapis.com`
- `sqladmin.googleapis.com`

## ルートモジュールでの呼び出し条件

`var.data_connect != null` の場合に呼び出される。
