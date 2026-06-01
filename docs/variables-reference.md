# 変数リファレンス

各機能変数のネスト構造とデフォルト値の完全リファレンス。型定義そのものは [`variables.tf`](../variables.tf) を参照。

---

## 3 パターン指定

すべての機能変数は次の 3 パターンを受け付ける:

| 指定 | 挙動 |
|------|------|
| `null` (= 省略) | **無効**。関連リソース / API / IAM は一切作成しない |
| `true` | デフォルト設定で **有効化** |
| `{ ... }` (object) | 指定した項目を **カスタム値で有効化**、未指定項目はデフォルト値 |

`firebase` 変数のみデフォルト値が `true` (= 常に Firebase 化される)。それ以外はすべて `null` がデフォルト。

---

## プロジェクト設定

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_id` | `string` | (required) | GCP / Firebase project ID。`^[a-z][a-z0-9-]{4,28}[a-z0-9]$` のバリデーションあり |
| `region` | `string` | `"asia-northeast1"` | 各機能のデフォルト location。`^[a-z]+-[a-z]+[0-9]+$` のバリデーションあり |
| `billing_account` | `string` | `""` | Billing account ID (`XXXXXX-XXXXXX-XXXXXX`)。空文字なら billing 関連付けを行わない |

---

## Firebase core

### `firebase`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| (root) | `null / true` | `true` | Firebase Project 化。常に有効推奨 |

### `authentication`

Identity Platform 設定。

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `blocking_functions.before_create` | `string` | `""` | Cloud Function URI (Identity Platform `beforeCreate` トリガー) |
| `blocking_functions.before_sign_in` | `string` | `""` | Cloud Function URI (Identity Platform `beforeSignIn` トリガー) |

`{}` のみ指定 (=デフォルト相当) で Identity Platform config が作成される。

### `firestore`

デフォルト database は **常に作成** され、初期 ruleset として **deny-all** が書き込まれる (本番ルールは Firebase CLI で更新する前提)。

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `location` | `string` | `var.region` | デフォルト DB の location |
| `type` | `string` | `"FIRESTORE_NATIVE"` | `FIRESTORE_NATIVE` / `DATASTORE_MODE` |
| `delete_protection_state` | `string` | `"DELETE_PROTECTION_DISABLED"` | `DELETE_PROTECTION_DISABLED` / `DELETE_PROTECTION_ENABLED` |
| `point_in_time_recovery` | `bool` | `false` | PITR |
| `databases` | `list(object)` | `[]` | 追加 database のリスト |
| `databases[].database_id` | `string` | (required) | database ID |
| `databases[].location` | `string` | デフォルト DB と同じ | location |
| `databases[].type` | `string` | `"FIRESTORE_NATIVE"` | type |
| `databases[].delete_protection_state` | `string` | `"DELETE_PROTECTION_DISABLED"` | |
| `databases[].point_in_time_recovery` | `bool` | `false` | |

### `rtdb`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `location` | `string` | `var.region` | RTDB instance location |
| `type` | `string` | `"DEFAULT_DATABASE"` | `DEFAULT_DATABASE` / `USER_DATABASE` |

instance ID は `{project_id}-default-rtdb` 固定。

### `storage`

デフォルト bucket (`{project_id}.firebasestorage.app`) は **常に作成** され、初期 ruleset として **deny-all** が書き込まれる。

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `buckets` | `list(object)` | `[]` | 追加 bucket のリスト |
| `buckets[].name` | `string` | (required) | bucket 名 (デフォルトで `{project_id}-` prefix が付く) |
| `buckets[].raw_name` | `bool` | `false` | `true` なら prefix を付けず name をそのまま使う |
| `buckets[].location` | `string` | `var.region` | bucket location |
| `buckets[].storage_class` | `string` | `"REGIONAL"` | storage class |
| `buckets[].iams` | `list(object)` | `[]` | IAM binding (`role`, `members`) |
| `firestore_backup` | `object \| null` | `null` | Firestore backup 用 bucket 設定 |
| `firestore_backup.bucket_name` | `string` | `"firestore-backups"` | suffix (`{project_id}-<suffix>` に展開) |
| `firestore_backup.export_platform` | `string` | `"cloud_functions"` | `cloud_functions` / `cloud_run`。Firestore export 用 SA への IAM 付与先 |
| `firestore_backup.soft_delete_policy.retention_duration_seconds` | `number` | `0` | soft delete 保持秒数 (0 で無効) |

### `hosting`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `site_id` | `string` | `var.project_id` | Hosting site ID。空文字なら project_id |

Web App と Hosting site の両方を作成する。

### `app_hosting`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `location` | `string` | `var.region` | backend location |
| `app_id` | `string` | (required, 通常 hosting の `app_id` を渡す) | Firebase Web App ID |
| `service_account` | `string` | (auto-created) | compute SA email。空文字なら `firebase-app-hosting-compute` を作成し `roles/firebaseapphosting.computeRunner` を付与 |
| `serving_locality` | `string` | `"GLOBAL_ACCESS"` | `GLOBAL_ACCESS` / `REGION_LOCKED` |

backend ID は `{project_id}-app-hosting` 固定。

### `data_connect`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `location` | `string` | `var.region` | Data Connect service location |
| `service_id` | `string` | `"{project_id}-dataconnect"` | service ID |
| `cloud_sql` | `object \| null` | `null` | Cloud SQL instance 設定 (null なら SQL は作成しない) |
| `cloud_sql.instance_id` | `string` | `"{project_id}-fdc"` | instance 名 |
| `cloud_sql.database` | `string` | `project_id` | database 名 |
| `cloud_sql.tier` | `string` | `"db-f1-micro"` | machine tier |
| `cloud_sql.database_version` | `string` | `"POSTGRES_15"` | PostgreSQL バージョン |
| `cloud_sql.deletion_protection` | `bool` | `false` | destroy 保護 |

---

## Firebase extensions

すべて API 有効化のみ (`null / true` のみ受け付ける placeholder)。

| Name | API 有効化 |
|------|----------|
| `fcm` | `fcm.googleapis.com` |
| `remote_config` | `firebaseremoteconfig.googleapis.com` |
| `app_check` | `firebaseappcheck.googleapis.com` |
| `crashlytics` | `firebasecrashlytics.googleapis.com` |
| `performance` | `firebaseperformance.googleapis.com` |
| `analytics` | `analyticsadmin.googleapis.com`, `firebase.googleapis.com` |
| `extensions` | `firebaseextensions.googleapis.com` |

---

## GCP services

### `secret_manager`, `pubsub`, `cloud_run`, `cloud_functions`

`null / true` のみ受け付ける API 有効化トリガー。secret / topic / function 自体は本モジュールでは作成せず、別途管理する。

`cloud_run` / `cloud_functions` は `true` にすると IAM auto-determine 対象になる (CI SA に `roles/run.admin` 等が自動付与)。

### `cloud_tasks`, `cloud_scheduler`, `eventarc`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `location` | `string` | `var.region` | location |

---

## API 管理

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `additional_apis` | `list(string)` | `[]` | 自動判定外で追加有効化する API。各要素は `.googleapis.com` で終わる必要がある |

---

## IAM

### `users`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `email` | `string` | (required) | user email |
| `role` | `string` | `"viewer"` | `viewer` / `editor` / `owner` のいずれか |
| `deploy` | `bool` | `false` | `true` で `roles/cloudfunctions.admin` + `roles/artifactregistry.reader` を追加付与 |

### `ci_service_account`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `account_id` | `string` | `"ci-deploy"` | SA ID |
| `display_name` | `string` | `"CI/CD Deployment"` | display name |
| `additional_roles` | `list(string)` | `[]` | 自動判定 roles に追加で付与する roles |

roles は機能 on/off から自動決定される。詳細は [service-accounts.md](./service-accounts.md)。

### `service_accounts`

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `account_id` | `string` | (required) | SA ID |
| `display_name` | `string` | `account_id` と同じ | display name |
| `type` | `string` | (required) | 現状 `"deploy"` のみ |
| `roles` | `list(string)` | `[]` | 任意で追加する roles |
| `args` | `object` | `{}` | `type = "deploy"` 向けの機能フラグ (詳細下記) |

`args` (`type = "deploy"`) で受け取るフィールド:

| Field | 自動付与される roles |
|-------|--------------------|
| `hosting` | `roles/firebasehosting.admin` |
| `functions` | `roles/cloudfunctions.admin`, `roles/iam.serviceAccountUser`, `roles/artifactregistry.admin` |
| `firestore` | `roles/datastore.indexAdmin`, `roles/firebaserules.admin` |
| `storage` | `roles/firebasestorage.viewer`, `roles/storage.objectAdmin`, `roles/storage.admin` |
| `scheduler` | `roles/cloudscheduler.admin` |
| `tasks` | `roles/cloudtasks.queueAdmin` |
| `blocking` | `roles/firebaseauth.admin` |

全 SA に共通で `roles/runtimeconfig.admin` が付与される。
