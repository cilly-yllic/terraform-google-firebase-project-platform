# terraform-google-firebase-project-platform

Firebase Project プラットフォームの共通 Terraform Module。

Terraform Registry: `cilly-yllic/firebase-project-platform/google`

---

## 概要

GCP / Firebase プロジェクトに必要なリソースを設定変数で選択的に作成する共通モジュール。
各サービス側の Workspace から再利用する形で利用する。

### 設計思想

1. **Firebase Console で設定できるものはすべてパラメータ化する**
2. **変数が `null` (未設定) なら関連リソース・IAM は一切作成しない**
3. **API 有効化は機能の有効化状態から自動判定する**
4. **Console アクセス権限もパラメータで指定可能**

### 機能変数の指定方法

各機能変数は以下の 3 パターンで指定する:

```hcl
# 無効 (デフォルト: リソース・API 一切作成しない)
firestore = null

# デフォルト設定で有効化
firestore = true

# カスタム設定で有効化 (未指定項目はデフォルト値)
firestore = {
  location    = "asia-northeast1"
  database_id = "(default)"
}
```

---

## 使い方

```hcl
module "firebase_platform" {
  source  = "cilly-yllic/firebase-project-platform/google"
  # version = "x.y.z"

  project_id = "my-project-id"
  region     = "asia-northeast1"

  firebase       = true
  hosting        = true
  firestore      = { location = "asia-northeast1" }
  secret_manager = true
  authentication = true

  console_editors = ["user:dev-lead@example.com"]
  console_viewers = ["group:devs@example.com"]
}
```

---

## Variables

### プロジェクト設定

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | GCP / Firebase project ID | `string` | — | yes |
| `region` | デフォルト GCP リージョン | `string` | `"asia-northeast1"` | no |
| `billing_account` | Billing account ID | `string` | `""` | no |

### 機能変数

各変数は `null` (無効) / `true` (デフォルト有効) / `{ … }` (カスタム設定有効) のいずれかを指定する。

#### Firebase core

| Name | Description | Default | 設定可能項目 |
|------|-------------|---------|-------------|
| `firebase` | Firebase Project | `true` | — |
| `authentication` | Authentication / Identity Platform | `null` | `blocking_functions.before_create`, `blocking_functions.before_sign_in` |
| `firestore` | Cloud Firestore | `null` | `location`, `type`, `delete_protection_state`, `point_in_time_recovery`, `databases[]` |
| `rtdb` | Realtime Database | `null` | `location`, `type` |
| `storage` | Cloud Storage for Firebase | `null` | `buckets[].name`, `buckets[].raw_name`, `buckets[].location`, `buckets[].storage_class` |
| `hosting` | Firebase Hosting | `null` | `site_id` |
| `app_hosting` | Firebase App Hosting | `null` | `location`, `app_id`, `service_account`, `serving_locality` |
| `data_connect` | Firebase Data Connect | `null` | `location` |

#### Firebase extensions

| Name | Description | Default |
|------|-------------|---------|
| `fcm` | Firebase Cloud Messaging | `null` |
| `remote_config` | Firebase Remote Config | `null` |
| `app_check` | Firebase App Check | `null` |
| `crashlytics` | Firebase Crashlytics | `null` |
| `performance` | Firebase Performance Monitoring | `null` |
| `analytics` | Google Analytics for Firebase | `null` |
| `extensions` | Firebase Extensions | `null` |

#### GCP services

| Name | Description | Default | 設定可能項目 |
|------|-------------|---------|-------------|
| `secret_manager` | Secret Manager | `null` | — |
| `cloud_tasks` | Cloud Tasks | `null` | `location` |
| `cloud_scheduler` | Cloud Scheduler | `null` | `location` |
| `pubsub` | Pub/Sub | `null` | — |
| `eventarc` | Eventarc | `null` | `location` |
| `cloud_run` | Cloud Run IAM | `null` | — |
| `cloud_functions` | Cloud Functions IAM | `null` | — |

### API 管理

| Name | Description | Default |
|------|-------------|---------|
| `additional_apis` | 自動判定以外に追加で有効化する API | `[]` |

### Console アクセス権限

| Name | Description | Default |
|------|-------------|---------|
| `console_editors` | Editor アクセス権限 (member 形式: `user:`, `group:`, `serviceAccount:`) | `[]` |
| `console_viewers` | Viewer アクセス権限 (member 形式: `user:`, `group:`, `serviceAccount:`) | `[]` |

### Service Account

| Name | Description | Default |
|------|-------------|---------|
| `service_accounts` | 作成する Service Account のリスト | `[]` |

---

## API 自動判定ルール

各機能が有効な場合、以下の API が自動的に有効化される:

| 機能 | APIs |
|------|------|
| (常に有効) | `cloudresourcemanager.googleapis.com`, `serviceusage.googleapis.com` |
| `firebase` | `firebase.googleapis.com` |
| `authentication` | `identitytoolkit.googleapis.com` |
| `firestore` | `firestore.googleapis.com` |
| `rtdb` | `firebasedatabase.googleapis.com` |
| `storage` | `firebasestorage.googleapis.com`, `storage.googleapis.com` |
| `hosting` | `firebasehosting.googleapis.com` |
| `app_hosting` | `firebaseapphosting.googleapis.com`, `run.googleapis.com`, `cloudbuild.googleapis.com`, `artifactregistry.googleapis.com` |
| `data_connect` | `firebasedataconnect.googleapis.com`, `sqladmin.googleapis.com` |
| `fcm` | `fcm.googleapis.com` |
| `remote_config` | `firebaseremoteconfig.googleapis.com` |
| `app_check` | `firebaseappcheck.googleapis.com` |
| `crashlytics` | `firebasecrashlytics.googleapis.com` |
| `performance` | `firebaseperformance.googleapis.com` |
| `analytics` | `analyticsadmin.googleapis.com`, `firebase.googleapis.com` |
| `extensions` | `firebaseextensions.googleapis.com` |
| `secret_manager` | `secretmanager.googleapis.com` |
| `cloud_tasks` | `cloudtasks.googleapis.com` |
| `cloud_scheduler` | `cloudscheduler.googleapis.com` |
| `pubsub` | `pubsub.googleapis.com` |
| `eventarc` | `eventarc.googleapis.com` |
| `cloud_run` | `run.googleapis.com` |
| `cloud_functions` | `cloudfunctions.googleapis.com`, `cloudbuild.googleapis.com`, `artifactregistry.googleapis.com` |

`additional_apis` で上記以外の API も追加可能。

---

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | GCP project ID |
| `enabled_apis` | 有効化された API リスト |
| `firebase_project_id` | Firebase project ID |
| `auth_config_name` | Identity Platform config name |
| `firestore_default_database` | Default Firestore database name |
| `firestore_default_location` | Default Firestore database location |
| `firestore_additional_databases` | Additional Firestore database names |
| `rtdb_name` | Realtime Database instance name |
| `rtdb_database_url` | Realtime Database URL |
| `storage_default_bucket` | Default Storage bucket name |
| `storage_additional_buckets` | Additional bucket names map |
| `hosting_site_id` | Hosting site ID |
| `hosting_app_id` | Firebase Web App ID |
| `hosting_default_url` | Hosting default URL |
| `app_hosting_name` | App Hosting backend name |
| `app_hosting_uri` | App Hosting backend URI |
| `data_connect_name` | Data Connect service name |
| `console_editor_members` | Editor access members |
| `console_viewer_members` | Viewer access members |
| `service_account_emails` | Service account emails |

---

## モジュール構成

```
.
├── main.tf              # Root module (API enablement + submodule wiring)
├── variables.tf         # Input variables
├── outputs.tf           # Outputs
├── versions.tf          # Provider constraints
├── modules/
│   ├── firebase/        # Firebase Project
│   ├── auth/            # Authentication / Identity Platform
│   ├── firestore/       # Cloud Firestore
│   ├── rtdb/            # Realtime Database
│   ├── storage/         # Cloud Storage for Firebase
│   ├── hosting/         # Firebase Hosting
│   ├── app-hosting/     # Firebase App Hosting
│   ├── data-connect/    # Firebase Data Connect
│   ├── fcm/             # Firebase Cloud Messaging
│   ├── remote-config/   # Firebase Remote Config
│   ├── app-check/       # Firebase App Check
│   ├── crashlytics/     # Firebase Crashlytics
│   ├── performance/     # Firebase Performance Monitoring
│   ├── analytics/       # Google Analytics for Firebase
│   ├── extensions/      # Firebase Extensions
│   ├── secret-manager/  # Secret Manager
│   ├── cloud-tasks/     # Cloud Tasks
│   ├── cloud-scheduler/ # Cloud Scheduler
│   ├── pubsub/          # Pub/Sub
│   ├── eventarc/        # Eventarc
│   └── iam/             # IAM (Console access, Service Accounts)
└── examples/
    ├── minimal/         # 最小構成
    └── full/            # 全機能 on
```

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.10.0 |
| google | >= 6.0, < 8.0 |
| google-beta | >= 6.0, < 8.0 |

---

## License

MIT License - see [LICENSE](LICENSE) for details.
