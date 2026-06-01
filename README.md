# terraform-google-firebase-project-platform

A shared Terraform module for the Firebase project platform.

Terraform Registry: `cilly-yllic/firebase-project-platform/google`

```hcl
module "firebase_platform" {
  source  = "cilly-yllic/firebase-project-platform/google"
  # version = "x.y.z"

  project_id = "my-project-id"
  firebase   = true
  firestore  = true
  hosting    = true
}
```

See [`docs/`](./docs/) for the full documentation set.

<details><summary>Ja</summary>

Firebase Project プラットフォームの共通 Terraform Module。

Terraform Registry: `cilly-yllic/firebase-project-platform/google`

詳細ドキュメントは [`docs/`](./docs/) を参照してください。

</details>

---

## Overview

A shared module that selectively provisions GCP / Firebase resources via **feature variables**. It is intended to be referenced as the `source` from each service's Terraform Workspace.

In addition to the public Terraform Module itself, this repository ships two reference implementations that handle the Terraform Cloud (TFC) handoff:

- [`cloud-run-router/`](./cloud-run-router/) — A Cloud Run service that receives TFC notifications and fires GitHub `repository_dispatch`.
- [`actions/dispatch/`](./actions/dispatch/) — A GitHub Action that upserts the `{service}-{env}` workspace from the caller's `settings.yml` and starts a Run.

See [docs/architecture.md](./docs/architecture.md) for details.

<details><summary>Ja</summary>

GCP / Firebase プロジェクトに必要なリソースを **機能変数** で選択的に作成する共通モジュール。各サービス側の Terraform Workspace から再利用する形で利用する。

本リポジトリには公開 Terraform Module 本体に加えて、Terraform Cloud (TFC) との handoff を担う 2 つの reference 実装も同梱されている:

- [`cloud-run-router/`](./cloud-run-router/) — TFC notification を受けて GitHub `repository_dispatch` を発火する Cloud Run service
- [`actions/dispatch/`](./actions/dispatch/) — 利用側リポジトリの `settings.yml` から `{service}-{env}` workspace を upsert し、Run を起動する GitHub Action

詳細は [docs/architecture.md](./docs/architecture.md) を参照。

</details>

---

## Design principles

1. **Every Firebase Console-configurable feature is exposed as a parameter.**
2. **If a variable is `null` (unset), no resources / IAM / API enablement happens at all (zero side effects).**
3. **API enablement is auto-derived from the feature flags** — callers do not need to enumerate APIs manually.
4. **The on/off criterion is "does the project actually need this feature"** — not "is it required for deploy".
5. **Console / IAM access is also parameter-driven** (`users` / `ci_service_account` / `service_accounts`).

See [docs/architecture.md](./docs/architecture.md) for the rationale.

<details><summary>Ja</summary>

1. **Firebase Console で設定可能な機能はすべてパラメータ化する**
2. **変数が `null` (未設定) なら、関連リソース・IAM・API 有効化は一切行わない (副作用ゼロ)**
3. **API 有効化は機能の有効化状態から自動判定する** (利用者が個別に列挙する必要はない)
4. **on/off の判断基準は「プロジェクト仕様としてその機能が必要か」** — デプロイ手順との直接の関係ではない
5. **Console / IAM 権限もパラメータで指定可能** (`users` / `ci_service_account` / `service_accounts`)

詳細な背景は [docs/architecture.md](./docs/architecture.md) を参照。

</details>

---

## Feature variable patterns

Every feature variable accepts one of these **three patterns**:

```hcl
# Pattern 1: disabled (default) — no resources / IAM / API are created
firestore = null

# Pattern 2: enabled with defaults
firestore = true

# Pattern 3: enabled with custom settings (unspecified fields use defaults)
firestore = {
  location = "asia-northeast1"
  type     = "FIRESTORE_NATIVE"
  databases = [
    { database_id = "analytics-db" },
  ]
}
```

For the configurable fields per feature, see [docs/variables-reference.md](./docs/variables-reference.md).

<details><summary>Ja</summary>

各機能変数は次の **3 パターン** で指定する:

- `null` → 無効。関連リソース / IAM / API は一切作成されない
- `true` → デフォルト設定で有効化
- `{ ... }` → カスタム値で有効化 (未指定項目はデフォルト値)

各機能で受け取れる設定項目は [docs/variables-reference.md](./docs/variables-reference.md) を参照。

</details>

---

## Quick Start

### Minimal (Firebase + Firestore only)

```hcl
module "firebase_platform" {
  source  = "cilly-yllic/firebase-project-platform/google"
  # version = "x.y.z"

  project_id = "my-minimal-project"
  region     = "asia-northeast1"

  firebase  = true
  firestore = true
}
```

Working example: [examples/minimal/](./examples/minimal/)

### Full (every feature on)

```hcl
module "firebase_platform" {
  source  = "cilly-yllic/firebase-project-platform/google"

  project_id      = "my-full-project"
  region          = "asia-northeast1"
  billing_account = "XXXXXX-XXXXXX-XXXXXX"

  # Firebase core
  firebase       = true
  authentication = true
  firestore = {
    location = "asia-northeast1"
    databases = [
      { database_id = "analytics-db" },
    ]
  }
  storage = {
    buckets = [{ name = "uploads" }]
  }
  hosting = { site_id = "my-full-project-web" }

  # Firebase extensions
  fcm           = true
  remote_config = true
  app_check     = true

  # GCP services
  secret_manager = true
  cloud_tasks    = { location = "asia-northeast1" }
  pubsub         = true

  # IAM
  users = [
    { email = "dev-lead@example.com", role = "editor", deploy = true },
    { email = "viewer@example.com",   role = "viewer" },
  ]

  # CI Service Account (roles auto-derived from enabled features)
  ci_service_account = true
}
```

Working example: [examples/full/](./examples/full/)

### Common flow

```bash
cd examples/minimal
terraform init
terraform plan -var "project_id=<YOUR_PROJECT_ID>"
terraform apply
```

> **Prerequisite:** The GCP Project itself is expected to be created by the upstream project-factory stage. This module only manages resources / APIs / IAM **inside** an existing Project. See [docs/architecture.md](./docs/architecture.md).

<details><summary>Ja</summary>

### 最小構成 (Firebase + Firestore のみ)

実例: [examples/minimal/](./examples/minimal/)

### 全機能 on の構成

実例: [examples/full/](./examples/full/)

### 共通の流れ

```bash
cd examples/minimal
terraform init
terraform plan -var "project_id=<YOUR_PROJECT_ID>"
terraform apply
```

**前提**: GCP Project 自体は upstream の project-factory ステージで作成されている前提。本モジュールは Project 内のリソース・API・IAM のみを管理する。詳細は [docs/architecture.md](./docs/architecture.md)。

</details>

---

## Inputs (overview)

For exact types and defaults see [variables.tf](./variables.tf); for prose explanations see [docs/variables-reference.md](./docs/variables-reference.md).

### Project settings

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | GCP / Firebase project ID | `string` | — | yes |
| `region` | Default GCP region | `string` | `"asia-northeast1"` | no |
| `billing_account` | Billing account ID (empty = no billing association) | `string` | `""` | no |

### Firebase core / extensions / GCP services (feature variables)

Each accepts `null` (disabled), `true` (enabled with defaults), or `{ ... }` (enabled with custom settings).

| Category | Feature variables |
|----------|-------------------|
| Firebase core | `firebase` (default `true`), `authentication`, `firestore`, `rtdb`, `storage`, `hosting`, `app_hosting`, `data_connect` |
| Firebase extensions | `fcm`, `remote_config`, `app_check`, `crashlytics`, `performance`, `analytics`, `extensions` |
| GCP services | `secret_manager`, `cloud_tasks`, `cloud_scheduler`, `pubsub`, `eventarc`, `cloud_run`, `cloud_functions` |

Nested structures are documented in [docs/variables-reference.md](./docs/variables-reference.md).

### IAM

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `users` | Project members (`email`, `role`=`viewer\|editor\|owner`, `deploy`=bool) | `list(object)` | `[]` |
| `ci_service_account` | CI deploy SA. `null` / `true` / `{ account_id, display_name, additional_roles }` | `any` | `null` |
| `service_accounts` | Additional SAs (deploy type) with per-feature flags | `list(object)` | `[]` |

The CI SA's roles are auto-derived from feature flags. See [docs/service-accounts.md](./docs/service-accounts.md).

### API management

| Name | Description | Default |
|------|-------------|---------|
| `additional_apis` | APIs to enable beyond those auto-derived (must end with `.googleapis.com`) | `[]` |

Auto-enablement rules: [docs/api-auto-enablement.md](./docs/api-auto-enablement.md).

<details><summary>Ja</summary>

正確な型と既定値は [variables.tf](./variables.tf)、解説は [docs/variables-reference.md](./docs/variables-reference.md) を参照。

### プロジェクト設定

- `project_id` (string, required): GCP / Firebase project ID
- `region` (string, default `"asia-northeast1"`): デフォルト GCP リージョン
- `billing_account` (string, default `""`): Billing account ID。空文字なら billing 関連付けを行わない

### Firebase core / extensions / GCP services (機能変数)

全機能変数は `null` (無効) / `true` (デフォルト有効) / `{ ... }` (カスタム設定有効) のいずれかを受け付ける。

- Firebase core: `firebase` (default `true`), `authentication`, `firestore`, `rtdb`, `storage`, `hosting`, `app_hosting`, `data_connect`
- Firebase extensions: `fcm`, `remote_config`, `app_check`, `crashlytics`, `performance`, `analytics`, `extensions`
- GCP services: `secret_manager`, `cloud_tasks`, `cloud_scheduler`, `pubsub`, `eventarc`, `cloud_run`, `cloud_functions`

各変数のネスト構造は [docs/variables-reference.md](./docs/variables-reference.md) を参照。

### IAM

- `users` (list(object), default `[]`): プロジェクトに付与するユーザー (`email`, `role`=`viewer|editor|owner`, `deploy`=bool)
- `ci_service_account` (any, default `null`): CI デプロイ用 SA。`null` / `true` / `{ account_id, display_name, additional_roles }`
- `service_accounts` (list(object), default `[]`): 追加 SA (deploy type) と付与する機能フラグ

CI SA の roles は機能 on/off から自動決定される。詳細は [docs/service-accounts.md](./docs/service-accounts.md)。

### API 管理

- `additional_apis` (list(string), default `[]`): 自動判定外で追加有効化する API (末尾 `.googleapis.com` 必須)

自動判定ルールは [docs/api-auto-enablement.md](./docs/api-auto-enablement.md)。

</details>

---

## Outputs (overview)

The full list is in [outputs.tf](./outputs.tf). Highlights:

| Name | Description |
|------|-------------|
| `project_id` / `enabled_apis` | Basic project info |
| `firebase_project_id` | Firebase project ID (when `firebase` enabled) |
| `firestore_default_database` / `firestore_additional_databases` | Firestore database names |
| `storage_default_bucket` / `storage_additional_buckets` | Storage bucket names |
| `hosting_site_id` / `hosting_default_url` | Hosting site info |
| `app_hosting_name` / `app_hosting_uri` | App Hosting backend info |
| `ci_service_account_email` / `ci_service_account_roles` | CI SA email and auto-assigned roles |
| `service_account_emails` / `service_account_roles` | Additional SA emails and roles |

<details><summary>Ja</summary>

完全なリストは [outputs.tf](./outputs.tf)。代表的なものは:

- `project_id` / `enabled_apis` — プロジェクトの基本情報
- `firebase_project_id` — Firebase 化された場合の project_id
- `firestore_default_database` / `firestore_additional_databases` — Firestore database 名
- `storage_default_bucket` / `storage_additional_buckets` — Storage bucket 名
- `hosting_site_id` / `hosting_default_url` — Hosting site の情報
- `app_hosting_name` / `app_hosting_uri` — App Hosting backend の情報
- `ci_service_account_email` / `ci_service_account_roles` — CI SA の email と自動付与 roles
- `service_account_emails` / `service_account_roles` — 追加 SA の email と roles

</details>

---

## Module layout

```
.
├── main.tf                # Root module (API enablement + per-feature submodule calls)
├── variables.tf           # Input variables (feature vars = null / true / object)
├── outputs.tf             # Outputs
├── versions.tf            # Provider constraints (terraform >= 1.10, google >= 6.0 < 8.0)
│
├── modules/
│   ├── firebase/          # Firebase Project enable
│   ├── auth/              # Authentication / Identity Platform (blocking functions)
│   ├── firestore/         # Cloud Firestore (default DB + additional databases + deny-all rules)
│   ├── rtdb/              # Realtime Database
│   ├── storage/           # Cloud Storage for Firebase (default + additional buckets + firestore-backup bucket)
│   ├── hosting/           # Firebase Hosting (Web App + Hosting site)
│   ├── app-hosting/       # Firebase App Hosting (backend + compute SA + IAM)
│   ├── data-connect/      # Firebase Data Connect (service + optional Cloud SQL)
│   ├── fcm/               # FCM (API placeholder)
│   ├── remote-config/     # Remote Config (API placeholder)
│   ├── app-check/         # App Check (API placeholder)
│   ├── crashlytics/       # Crashlytics (API placeholder)
│   ├── performance/       # Performance Monitoring (API placeholder)
│   ├── analytics/         # Google Analytics for Firebase (API placeholder)
│   ├── extensions/        # Firebase Extensions (API placeholder)
│   ├── secret-manager/    # Secret Manager (API placeholder)
│   ├── cloud-tasks/       # Cloud Tasks (API placeholder)
│   ├── cloud-scheduler/   # Cloud Scheduler (API placeholder)
│   ├── pubsub/            # Pub/Sub (API placeholder)
│   ├── eventarc/          # Eventarc (API placeholder)
│   └── iam/               # IAM (users + CI SA + service_accounts)
│
├── examples/
│   ├── minimal/           # Firebase + Firestore only
│   └── full/              # Every feature on
│
├── cloud-run-router/      # [reference] TFC notification → repository_dispatch (Cloud Run, TypeScript)
├── actions/dispatch/      # [reference] {service}-{env} workspace upsert + Run dispatch (GitHub Action)
│
└── docs/                  # Detailed documentation (architecture / variables / API / IAM, etc.)
```

Each submodule's responsibility is documented in `modules/<name>/README.md`; reference implementations have READMEs in their own directories.

<details><summary>Ja</summary>

各 submodule の責務は `modules/<name>/README.md`、reference 実装は各ディレクトリの README を参照。

</details>

---

## Reference implementations

Two implementations bundled alongside the public Terraform Module to handle the Terraform Cloud handoff. **Both are optional** — the Module can be used standalone.

| Directory | Role |
|-----------|------|
| [`cloud-run-router/`](./cloud-run-router/) | A Cloud Run service that receives TFC `run:completed` notifications, parses `(service, env, source_repo)` from `workspace_name` patterns, and fires GitHub `repository_dispatch` |
| [`actions/dispatch/`](./actions/dispatch/) | A GitHub Action that reads the caller repo's `settings.yml`, references the project-factory workspace outputs, upserts the `{service}-{env}` workspace, syncs variables, and starts a Run |

For the responsibility split and handoff flow, see [docs/architecture.md](./docs/architecture.md).

<details><summary>Ja</summary>

公開 Terraform Module 本体とは別に、Terraform Cloud との handoff を担う実装が同梱されている。いずれも利用は任意で、Module 単独で利用してもよい。

- [`cloud-run-router/`](./cloud-run-router/) — TFC `run:completed` notification を受信し、`workspace_name` パターンから `(service, env, source_repo)` を解析して GitHub `repository_dispatch` を発火する Cloud Run service
- [`actions/dispatch/`](./actions/dispatch/) — 利用側リポジトリの `settings.yml` を読み、project-factory workspace の outputs を参照、`{service}-{env}` workspace を upsert、変数同期、Run 起動を行う GitHub Action

責務分離と handoff の流れは [docs/architecture.md](./docs/architecture.md) を参照。

</details>

---

## Troubleshooting

| Symptom | Cause / fix |
|---------|-------------|
| `Error: googleapi: Error 403: ... API has not been used` | The API was not enabled. Setting the corresponding feature variable to anything other than `null` auto-enables it. For APIs not covered by auto-derivation, list them in `additional_apis`. |
| `Error: Permission denied while enabling Service Usage API` | The Terraform-executing SA needs `roles/serviceusage.serviceUsageAdmin` (or equivalent). |
| `Error: ... project not found` | The Project has not been created yet by the upstream project-factory stage. Apply project-factory first. |
| `Error: A new Firebase Hosting site already exists with the ID` | Change `hosting.site_id` or `terraform import` the existing `google_firebase_hosting_site.this`. |
| Firestore rules differ from expectations | This module writes a **deny-all** initial ruleset. Deploy production rules via Firebase CLI. |
| Cloud SQL instance destroy is blocked | Set `data_connect.cloud_sql.deletion_protection = false` (default is `false`; only an issue if explicitly set to `true`). |
| `additional_apis must end with '.googleapis.com'` | Use the fully-qualified API name (e.g. `iap.googleapis.com`). |
| `users[*].role` validation error | Only `viewer` / `editor` / `owner` are accepted. |

<details><summary>Ja</summary>

- `Error: googleapi: Error 403: ... API has not been used` — 該当 API が有効化されていない。機能変数を `null` 以外にすると自動有効化される。手動で追加したい API は `additional_apis` に列挙する
- `Error: Permission denied while enabling Service Usage API` — Terraform 実行 SA に `roles/serviceusage.serviceUsageAdmin` (または同等) が必要
- `Error: ... project not found` — 上流 project-factory ステージで Project がまだ作成されていない。先に project-factory workspace を apply する
- `Error: A new Firebase Hosting site already exists with the ID` — `hosting.site_id` を変更するか、`google_firebase_hosting_site.this` を import する
- Firestore rules が想定と異なる — 本モジュールは初期 ruleset として **deny-all** を書き込む。本番ルールは Firebase CLI でデプロイする想定
- Cloud SQL instance の destroy がブロックされる — `data_connect.cloud_sql.deletion_protection = false` を指定 (デフォルトは `false`、明示的に `true` を入れている場合)
- `additional_apis must end with '.googleapis.com'` — API の完全名を指定する (例: `iap.googleapis.com`)
- `users[*].role` のバリデーションエラー — `viewer` / `editor` / `owner` のいずれかのみ許容

</details>

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.10.0 |
| google | >= 6.0, < 8.0 |
| google-beta | >= 6.0, < 8.0 |

---

## Related documentation

- [docs/architecture.md](./docs/architecture.md) — Overall architecture, this module's position, responsibility split with the reference implementations
- [docs/variables-reference.md](./docs/variables-reference.md) — Detailed reference for every feature variable
- [docs/api-auto-enablement.md](./docs/api-auto-enablement.md) — Feature → API auto-enablement table
- [docs/console-access.md](./docs/console-access.md) — Firebase Console / GCP IAM access design
- [docs/service-accounts.md](./docs/service-accounts.md) — CI SA and additional SA operations
- [docs/upgrade-guide.md](./docs/upgrade-guide.md) — Breaking changes between Registry versions
- [terraform-architecture.md](./terraform-architecture.md) — Operational policy for the Terraform execution platform

<details><summary>Ja</summary>

- [docs/architecture.md](./docs/architecture.md) — 全体アーキテクチャ / 本モジュールの位置づけ / reference 実装との責務分離
- [docs/variables-reference.md](./docs/variables-reference.md) — 機能変数の詳細リファレンス
- [docs/api-auto-enablement.md](./docs/api-auto-enablement.md) — API 自動判定ルール表
- [docs/console-access.md](./docs/console-access.md) — Firebase Console / GCP IAM の権限設計
- [docs/service-accounts.md](./docs/service-accounts.md) — CI SA と追加 SA の運用
- [docs/upgrade-guide.md](./docs/upgrade-guide.md) — Registry バージョン間の breaking change 一覧
- [terraform-architecture.md](./terraform-architecture.md) — Terraform 実行基盤の運用方針

</details>

---

## License

MIT License - see [LICENSE](LICENSE) for details.
