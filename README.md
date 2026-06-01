# terraform-google-firebase-project-platform

Firebase Project プラットフォームの共通 Terraform Module。

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

詳細ドキュメントは [`docs/`](./docs/) を参照してください。

---

## 概要

GCP / Firebase プロジェクトに必要なリソースを **機能変数** で選択的に作成する共通モジュール。各サービス側の Terraform Workspace から再利用する形で利用する。

本リポジトリには公開 Terraform Module 本体に加えて、Terraform Cloud (TFC) との handoff を担う 2 つの reference 実装も同梱されている:

- [`cloud-run-router/`](./cloud-run-router/) — TFC notification を受けて GitHub `repository_dispatch` を発火する Cloud Run service
- [`actions/dispatch/`](./actions/dispatch/) — 利用側リポジトリの `settings.yml` から `{service}-{env}` workspace を upsert し、Run を起動する GitHub Action

詳細は [docs/architecture.md](./docs/architecture.md) を参照。

---

## 設計思想

1. **Firebase Console で設定可能な機能はすべてパラメータ化する**
2. **変数が `null` (未設定) なら、関連リソース・IAM・API 有効化は一切行わない (副作用ゼロ)**
3. **API 有効化は機能の有効化状態から自動判定する** (利用者が個別に列挙する必要はない)
4. **on/off の判断基準は「プロジェクト仕様としてその機能が必要か」** — デプロイ手順との直接の関係ではない
5. **Console / IAM 権限もパラメータで指定可能** (`users` / `ci_service_account` / `service_accounts`)

詳細な背景は [docs/architecture.md](./docs/architecture.md) を参照。

---

## 機能変数の指定方法

各機能変数は次の **3 パターン** で指定する:

```hcl
# パターン 1: 無効 (デフォルト) — 関連リソース / IAM / API は一切作成されない
firestore = null

# パターン 2: デフォルト設定で有効化
firestore = true

# パターン 3: カスタム設定で有効化 (未指定項目はデフォルト値)
firestore = {
  location = "asia-northeast1"
  type     = "FIRESTORE_NATIVE"
  databases = [
    { database_id = "analytics-db" },
  ]
}
```

各機能で受け取れる設定項目は [docs/variables-reference.md](./docs/variables-reference.md) を参照。

---

## Quick Start

### 最小構成 (Firebase + Firestore のみ)

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

実例: [examples/minimal/](./examples/minimal/)

### 全機能 on の構成

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
  secret_manager  = true
  cloud_tasks     = { location = "asia-northeast1" }
  pubsub          = true

  # IAM
  users = [
    { email = "dev-lead@example.com", role = "editor", deploy = true },
    { email = "viewer@example.com",   role = "viewer" },
  ]

  # CI Service Account (roles を機能 on/off から自動決定)
  ci_service_account = true
}
```

実例: [examples/full/](./examples/full/)

### 共通の流れ

```bash
cd examples/minimal
terraform init
terraform plan -var "project_id=<YOUR_PROJECT_ID>"
terraform apply
```

> **前提:** GCP Project 自体は upstream の project-factory ステージで作成されている前提。本モジュールは Project 内のリソース・API・IAM のみを管理する。詳細は [docs/architecture.md](./docs/architecture.md)。

---

## Inputs (概要)

正確な型と既定値は [variables.tf](./variables.tf)、解説は [docs/variables-reference.md](./docs/variables-reference.md) を参照。

### プロジェクト設定

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `project_id` | GCP / Firebase project ID | `string` | — | yes |
| `region` | デフォルト GCP リージョン | `string` | `"asia-northeast1"` | no |
| `billing_account` | Billing account ID (空文字なら billing 関連付けを行わない) | `string` | `""` | no |

### Firebase core / extensions / GCP services (機能変数)

全機能変数は `null` (無効) / `true` (デフォルト有効) / `{ ... }` (カスタム設定有効) のいずれかを受け付ける。

| 種別 | 機能変数 |
|------|---------|
| Firebase core | `firebase` (default `true`), `authentication`, `firestore`, `rtdb`, `storage`, `hosting`, `app_hosting`, `data_connect` |
| Firebase extensions | `fcm`, `remote_config`, `app_check`, `crashlytics`, `performance`, `analytics`, `extensions` |
| GCP services | `secret_manager`, `cloud_tasks`, `cloud_scheduler`, `pubsub`, `eventarc`, `cloud_run`, `cloud_functions` |

各変数のネスト構造は [docs/variables-reference.md](./docs/variables-reference.md) を参照。

### IAM

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `users` | プロジェクトに付与するユーザー (`email`, `role`=`viewer\|editor\|owner`, `deploy`=bool) | `list(object)` | `[]` |
| `ci_service_account` | CI デプロイ用 SA。`null` / `true` / `{ account_id, display_name, additional_roles }` | `any` | `null` |
| `service_accounts` | 追加 SA (deploy type) と付与する機能フラグ | `list(object)` | `[]` |

CI SA の roles は機能 on/off から自動決定される。詳細は [docs/service-accounts.md](./docs/service-accounts.md)。

### API 管理

| Name | Description | Default |
|------|-------------|---------|
| `additional_apis` | 自動判定外で追加有効化する API (末尾 `.googleapis.com` 必須) | `[]` |

自動判定ルールは [docs/api-auto-enablement.md](./docs/api-auto-enablement.md)。

---

## Outputs (概要)

完全なリストは [outputs.tf](./outputs.tf)。代表的なものは以下:

| Name | Description |
|------|-------------|
| `project_id` / `enabled_apis` | プロジェクトの基本情報 |
| `firebase_project_id` | Firebase 化された場合の project_id |
| `firestore_default_database` / `firestore_additional_databases` | Firestore database 名 |
| `storage_default_bucket` / `storage_additional_buckets` | Storage bucket 名 |
| `hosting_site_id` / `hosting_default_url` | Hosting site の情報 |
| `app_hosting_name` / `app_hosting_uri` | App Hosting backend の情報 |
| `ci_service_account_email` / `ci_service_account_roles` | CI SA の email と自動付与 roles |
| `service_account_emails` / `service_account_roles` | 追加 SA の email と roles |

---

## モジュール構成

```
.
├── main.tf                # Root module (API enablement + 機能ごとに submodule を call)
├── variables.tf           # Input variables (機能変数 = null / true / object)
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
│   ├── minimal/           # Firebase + Firestore のみ
│   └── full/              # 全機能 on
│
├── cloud-run-router/      # [reference] TFC notification → repository_dispatch (Cloud Run, TypeScript)
├── actions/dispatch/      # [reference] {service}-{env} workspace upsert + Run 起動 (GitHub Action)
│
└── docs/                  # 詳細ドキュメント (アーキテクチャ / variables / API / IAM 等)
```

各 submodule の責務は `modules/<name>/README.md`、reference 実装は各ディレクトリの README を参照。

---

## Reference 実装

公開 Terraform Module 本体とは別に、Terraform Cloud との handoff を担う実装が同梱されている。利用は任意。

| ディレクトリ | 役割 |
|-------------|------|
| [`cloud-run-router/`](./cloud-run-router/) | TFC `run:completed` notification を受信し、`workspace_name` パターンから `(service, env, source_repo)` を解析して GitHub `repository_dispatch` を発火する Cloud Run service |
| [`actions/dispatch/`](./actions/dispatch/) | 利用側リポジトリの `settings.yml` を読み、project-factory workspace の outputs を参照、`{service}-{env}` workspace を upsert、変数同期、Run 起動を行う GitHub Action |

責務分離と handoff の流れは [docs/architecture.md](./docs/architecture.md) を参照。

---

## トラブルシューティング

| 症状 | 原因 / 対処 |
|------|-----|
| `Error: googleapi: Error 403: ... API has not been used` | 該当 API が有効化されていない。機能変数を `null` 以外にすると自動有効化される。手動で追加したい API は `additional_apis` に列挙する |
| `Error: Permission denied while enabling Service Usage API` | Terraform 実行 SA に `roles/serviceusage.serviceUsageAdmin` (または同等) が必要 |
| `Error: ... project not found` | 上流 project-factory ステージで Project がまだ作成されていない。先に project-factory workspace を apply する |
| `Error: A new Firebase Hosting site already exists with the ID` | `hosting.site_id` を変更するか、`google_firebase_hosting_site.this` を import する |
| Firestore rules が想定と異なる | 本モジュールは初期 ruleset として **deny-all** を書き込む。本番ルールは Firebase CLI でデプロイする想定 |
| Cloud SQL instance の destroy がブロックされる | `data_connect.cloud_sql.deletion_protection = false` を指定 (デフォルトは `false`、明示的に `true` を入れている場合) |
| `additional_apis must end with '.googleapis.com'` | API の完全名を指定する (例: `iap.googleapis.com`) |
| `users[*].role` のバリデーションエラー | `viewer` / `editor` / `owner` のいずれかのみ許容 |

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.10.0 |
| google | >= 6.0, < 8.0 |
| google-beta | >= 6.0, < 8.0 |

---

## 関連ドキュメント

- [docs/architecture.md](./docs/architecture.md) — 全体アーキテクチャ / 本モジュールの位置づけ / reference 実装との責務分離
- [docs/variables-reference.md](./docs/variables-reference.md) — 機能変数の詳細リファレンス
- [docs/api-auto-enablement.md](./docs/api-auto-enablement.md) — API 自動判定ルール表
- [docs/console-access.md](./docs/console-access.md) — Firebase Console / GCP IAM の権限設計
- [docs/service-accounts.md](./docs/service-accounts.md) — CI SA と追加 SA の運用
- [docs/upgrade-guide.md](./docs/upgrade-guide.md) — Registry バージョン間の breaking change 一覧
- [terraform-architecture.md](./terraform-architecture.md) — Terraform 実行基盤の運用方針

---

## License

MIT License - see [LICENSE](LICENSE) for details.
