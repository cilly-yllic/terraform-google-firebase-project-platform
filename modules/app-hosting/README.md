# modules/app-hosting

Firebase App Hosting backend + 必要な compute service account / IAM を作成する submodule。

## 作成するリソース

| Resource | Provider | 役割 |
|----------|----------|------|
| `google_service_account.app_hosting` | `google` | compute SA (`firebase-app-hosting-compute`) — `service_account` を空文字で渡した場合のみ作成 |
| `google_project_iam_member.app_hosting_runner` | `google` | compute SA に `roles/firebaseapphosting.computeRunner` を付与 |
| `google_firebase_app_hosting_backend.this` | `google-beta` | App Hosting backend (`{project}-app-hosting`) |

`service_account` を明示的に指定した場合、SA 作成と role 付与はスキップされる (既存 SA を再利用する)。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |
| `location` | `string` | (required) | backend location |
| `app_id` | `string` | (required) | Firebase Web App ID (通常 `hosting` submodule の `app_id` を渡す) |
| `service_account` | `string` | `""` (= auto-create) | compute SA email。空文字なら自動作成 |
| `serving_locality` | `string` | `"GLOBAL_ACCESS"` | `GLOBAL_ACCESS` / `REGION_LOCKED` |

## Outputs

| Name | Description |
|------|-------------|
| `name` | App Hosting backend resource name |
| `uri` | backend URI |

## 関連 API

- `firebaseapphosting.googleapis.com`
- `run.googleapis.com`
- `cloudbuild.googleapis.com`
- `artifactregistry.googleapis.com`
- `iam.googleapis.com` (SA 作成のため)

## ルートモジュールでの呼び出し条件

`var.app_hosting != null` の場合に呼び出される。

## 管理範囲外

- ソースリポジトリ連携 (Console 側で設定)
- App Hosting rollout policy
- ビルド設定 (`apphosting.yaml`)
