# アーキテクチャ

本リポジトリ (`terraform-google-firebase-project-platform`) の位置づけと、同梱する reference 実装との責務分離を説明する。

---

## 本リポジトリの位置づけ

GCP / Firebase Project を **構築する Terraform 実行基盤** と、**それらの基盤から呼び出される共通 Module** は別レイヤーであり、本リポジトリは後者にあたる。

```text
+--- Terraform 実行基盤 (利用側のリポジトリ群) ----------------------+
|                                                                  |
|   infra-bootstrap          : Workload Identity Federation など     |
|   project-factory          : GCP Project / Billing / 初期 IAM の作成 |
|   {service}-dev / stg / prd: サービス単位の workspace              |
|                                                                  |
+------------------------------------------------------------------+
                          ↓ module source = registry
+--- 本リポジトリ (公開 Terraform Module) ---------------------------+
|                                                                  |
|   terraform-google-firebase-project-platform                     |
|     - GCP Project 内部のリソース / API / IAM のみ管理              |
|     - 機能変数 (null / true / object) で on/off                  |
|                                                                  |
+------------------------------------------------------------------+
```

- **本モジュールは Project そのものを作らない**。`project_id` は引数として受け取り、Project 内部のリソース・API 有効化・IAM のみ管理する
- 上流の **project-factory ステージ** で Project / Billing 紐付け / 初期 SA を作成しておく前提
- 各サービス側 Workspace は本モジュールを `source = "cilly-yllic/firebase-project-platform/google"` で参照して利用する

---

## レイヤー分離の原則

| レイヤー | 責務 | 本リポジトリでの担当 |
|----------|------|---------------------|
| Bootstrap | WIF / Terraform 実行用の共通 GCP Project | × (別リポジトリ) |
| project-factory | GCP Project 作成 / Billing 紐付け / 初期 IAM | × (別リポジトリ) |
| **firebase-project-platform** | Project 内部の API / Firebase / IAM | **○ (本モジュール)** |
| サービス Workspace 設定 | 本モジュールへの値の流し込み | × (利用側) |

レイヤーごとに **使う Service Account** と **state file** を分離する想定であり、本モジュールは「Project 内部のみ」に責務を絞ることで他レイヤーへの干渉を防ぐ。

---

## 同梱する reference 実装

公開 Terraform Module 本体に加えて、Terraform Cloud (TFC) との handoff を担う実装を 2 種類同梱している。**いずれも利用は任意** で、Module 単独で利用してもよい。

```
.
├── (Terraform Module 本体: main.tf / modules/)
│
├── cloud-run-router/   # TFC notification → repository_dispatch を行う Cloud Run service
└── actions/dispatch/   # {service}-{env} workspace upsert + Run 起動を行う GitHub Action
```

### cloud-run-router

- **入力**: TFC からの Run completion notification (`POST /webhook`, HMAC-SHA512 署名付き)
- **出力**: GitHub `repository_dispatch` (Project Repository に対して `firebase_platform_requested` event)
- **目的**: project-factory の Run 完了を検知して、続く firebase-platform の Run を発火する Phase 2 (webhook-driven) アーキテクチャの中核
- 詳細: [cloud-run-router/README.md](../cloud-run-router/README.md)

### actions/dispatch

- **入力**: 利用側リポジトリの `settings.yml` (`firebase_platform` セクション) + `service` / `environment`
- **出力**: TFC `{service}-{environment}` workspace の upsert + Run 起動
- **目的**: project-factory の outputs (project_id 等) を参照し、機能変数を Terraform 変数として注入して Run を作る
- 詳細: [actions/dispatch/README.md](../actions/dispatch/README.md)

---

## handoff の流れ (Phase 2 webhook-driven)

```text
project-factory workspace (TFC)
  ↓ Run applied
  ↓ TFC notification (HTTP POST, HMAC-SHA512)
cloud-run-router (Cloud Run, 本リポジトリ同梱)
  ↓ HMAC 検証 → workspace_name routing → (service, env, source_repo) 解析
  ↓ GitHub repository_dispatch (event_type = firebase_platform_requested)
利用側 Project Repository (GitHub Actions)
  ↓ actions/dispatch を call
  ↓ settings.yml + project-factory outputs を読み込み
  ↓ {service}-{env} workspace upsert + variables 同期
  ↓ TFC Run 起動
{service}-{env} workspace (TFC)
  ↓ module "firebase_platform" { source = "cilly-yllic/firebase-project-platform/google" } を apply
GCP Project 内に Firebase / Firestore / Storage / IAM 等が作成
```

### Phase 1 (polling) との関係

cloud-run-router は TFC notification が設定されていない限り呼ばれない。Phase 1 (orchestrator が polling で project-factory 完了を検知し actions/dispatch を call) と共存できる。

| 状態 | cloud-run-router | actions/dispatch |
|------|------------------|-----------------|
| Phase 1 only | 未デプロイ | orchestrator から call |
| 移行期 | デプロイ済 (service 単位 opt-in) | どちらの経路からも call |
| Phase 2 only | デプロイ済 (全 service) | repository_dispatch 経由のみ |

---

## API 有効化の自動判定

利用者が `google_project_service` を個別に列挙しなくて済むよう、機能 on/off から有効化する API を自動決定する。

- `firestore = true` → `firestore.googleapis.com`, `firebaserules.googleapis.com`
- `app_hosting = { ... }` → `firebaseapphosting.googleapis.com`, `run.googleapis.com`, `cloudbuild.googleapis.com`, `artifactregistry.googleapis.com`
- `cloud_functions = true` → `cloudfunctions.googleapis.com`, `cloudbuild.googleapis.com`, `artifactregistry.googleapis.com`

完全な対応表は [api-auto-enablement.md](./api-auto-enablement.md) を参照。

`additional_apis` でさらに追加可能 (例: `iap.googleapis.com`)。

---

## 副作用ゼロの原則

機能変数を `null` にした場合、その機能に対応する以下のすべてが **作成されない**:

- submodule のリソース (Firestore database, Storage bucket, IAM binding, etc.)
- API 有効化 (`google_project_service`)
- CI SA に自動付与される roles

機能を後から無効化した場合、Terraform は通常通り destroy を行う (API 自体は `disable_on_destroy = false` のため有効のまま残るが、追加リソースは消える)。

---

## 状態とプロバイダー

- `terraform >= 1.10.0`
- `hashicorp/google` `>= 6.0, < 8.0`
- `hashicorp/google-beta` `>= 6.0, < 8.0`

`google-beta` は Firebase 関連リソース (`google_firebase_*`) でのみ利用している。
