# dispatch-tfc-firebase-platform

Firebase Platform 用の Terraform Cloud Run を起動する GitHub Action。

Project Repository が `terraform/settings.yml` を起点に、project-factory workspace の outputs を取得し、`{service}-{env}` workspace を upsert → 変数同期 → Run 作成までを一括実行する。

---

## Inputs

| Name | Description | Required | Default |
|------|-------------|:--------:|---------|
| `service` | サービス名 | yes | — |
| `environment` | 対象環境 (`dev` / `stg` / `prd`) | yes | — |
| `settings_path` | settings.yml のパス | no | `terraform/settings.yml` |
| `tfc_org` | Terraform Cloud organization 名 | yes | — |
| `project_factory_workspace` | 上流 project-factory workspace 名パターン (`{service}` 展開) | no | `project-factory-{service}` |
| `target_workspace` | 作成する workspace 名パターン (`{service}`, `{environment}` 展開) | no | `{service}-{environment}` |
| `bootstrap_project_id` | GCP bootstrap project ID (Workload Identity 用) | no | `infra-bootstrap` |
| `bootstrap_project_number` | GCP bootstrap project number (数値, WIF パス用) | yes | — |
| `workload_identity_pool_id` | Workload Identity Pool ID | no | `terraform-cloud` |
| `workload_identity_provider_id` | Workload Identity Provider ID | no | `terraform-cloud` |
| `tfc_token` | Terraform Cloud API token | yes | — |
| `apply_policy` | Run apply policy: `auto` / `manual` / `env-based` | no | `env-based` |
| `enable_webhook_notification` | Phase 2 webhook 通知を設定するか | no | `false` |
| `cloud_run_webhook_url` | Cloud Run router URL (webhook 有効時必須) | no | — |
| `cloud_run_webhook_secret` | HMAC secret (Cloud Run router と共有) | no | — |

## Outputs

| Name | Description |
|------|-------------|
| `run_id` | Terraform Cloud Run ID |
| `run_url` | Terraform Cloud UI の Run URL |
| `workspace_id` | Terraform Cloud Workspace ID |
| `workspace_name` | Terraform Cloud Workspace 名 |

---

## Apply Policy

`apply_policy` input で Run の自動 apply を制御する。

| 値 | 動作 |
|---|---|
| `auto` | 全環境で auto-apply |
| `manual` | 全環境で手動承認 |
| `env-based` (default) | dev = auto-apply, stg/prd = 手動承認 |

---

## settings.yml 構造

Action が読み取る `firebase_platform` セクション例:

```yaml
service: my-app

environments:
  dev:
    project_id: my-app-dev
    firebase_platform:
      firebase: true
      firestore:
        location: asia-northeast1
      hosting: true
      storage: true
      authentication: true
      secret_manager: true
      cloud_tasks:
        location: asia-northeast1
  stg:
    project_id: my-app-stg
    firebase_platform:
      firebase: true
      firestore: true
      hosting: true
  prd:
    project_id: my-app-prd
    firebase_platform:
      firebase: true
      firestore: true
      hosting: true
      storage: true
```

各機能は `null` (省略) / `true` / `{ ... }` (カスタム設定) で指定する。

---

## 使用例

### Phase 1 (orchestrator 内で call)

```yaml
jobs:
  firebase-platform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Dispatch Firebase Platform Run
        id: dispatch
        uses: MoooDoNE/terraform-google-firebase-project-platform/actions/dispatch@v1
        with:
          service: my-app
          environment: dev
          tfc_org: my-tfc-org
          bootstrap_project_number: "123456789012"
          tfc_token: ${{ secrets.TFC_TOKEN }}

      - name: Print Run URL
        run: echo "${{ steps.dispatch.outputs.run_url }}"
```

### Phase 2 (Project Repo workflow 直接 call)

```yaml
name: Firebase Platform Trigger
on:
  repository_dispatch:
    types: [firebase-platform-trigger]

jobs:
  dispatch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: MoooDoNE/terraform-google-firebase-project-platform/actions/dispatch@v1
        with:
          service: ${{ github.event.client_payload.service }}
          environment: ${{ github.event.client_payload.environment }}
          tfc_org: my-tfc-org
          bootstrap_project_number: ${{ secrets.BOOTSTRAP_PROJECT_NUMBER }}
          tfc_token: ${{ secrets.TFC_TOKEN }}
          apply_policy: env-based
          enable_webhook_notification: "true"
          cloud_run_webhook_url: ${{ secrets.WEBHOOK_URL }}
          cloud_run_webhook_secret: ${{ secrets.WEBHOOK_SECRET }}
```

---

## 処理フロー

1. `settings.yml` を読み込み、`environments[env].firebase_platform` セクションを抽出
2. TFC API で `project-factory-{service}` workspace の outputs から `project_id` / `project_number` / `terraform_service_account_email` を取得
3. `{service}-{env}` workspace を upsert (存在すれば update、なければ create)
4. Terraform Variables を同期 (各機能 flag を `null | true | object` 形式で HCL 変数にマッピング)
5. Environment Variables を同期 (TFC Dynamic Credentials 用)
6. Run を起動 (env 別 apply policy 適用)

> **⚠️ Full Workspace Management:** この Action は workspace の変数を完全に管理する。Action が生成しない変数 (手動追加や他ツールで設定した変数) は **毎回削除される**。手動で設定が必要な変数がある場合は `settings.yml` の `firebase_platform` セクションに含めるか、別の workspace を使用すること。

> **ℹ️ API-driven Workspace:** この Action は VCS 接続なしの API-driven workspace を作成・管理する。GitHub Actions 側がリポジトリの変更を検知し、settings.yml の値を元に Terraform 変数を設定して apply run を実行する設計のため、VCS 連携は不要。
