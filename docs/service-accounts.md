# Service Accounts

本モジュールが扱う Service Account は次の 2 種類:

| 変数 | 用途 | roles の決定方法 |
|------|------|----------------|
| `ci_service_account` | CI/CD で deploy を実行する **共通の 1 SA** | 機能 on/off から **自動判定** |
| `service_accounts` | アプリ・バッチ・連携用の **任意の SA 群** | `args` で機能フラグを指定 |

App Hosting 用の compute SA (`firebase-app-hosting-compute`) は `app_hosting` 機能が有効な場合に自動作成される (これは別ロジック)。

---

## CI Service Account (`ci_service_account`)

### 指定方法

```hcl
# 無効
ci_service_account = null

# デフォルト設定で有効化
ci_service_account = true

# カスタム
ci_service_account = {
  account_id       = "ci-deploy"
  display_name     = "CI/CD Deployment"
  additional_roles = ["roles/viewer"]
}
```

### 自動付与される roles

`enable_*` が `true` の機能に応じて以下が付与される。重複は `distinct()` で排除される。

| 機能 | 付与 roles |
|------|----------|
| 常に | `roles/runtimeconfig.admin` |
| `hosting` | `roles/firebasehosting.admin` |
| `cloud_functions` | `roles/cloudfunctions.admin`, `roles/iam.serviceAccountUser`, `roles/artifactregistry.admin` |
| `firestore` | `roles/datastore.indexAdmin`, `roles/firebaserules.admin` |
| `storage` | `roles/firebasestorage.viewer`, `roles/storage.objectAdmin`, `roles/storage.admin` |
| `cloud_scheduler` | `roles/cloudscheduler.admin` |
| `cloud_tasks` | `roles/cloudtasks.queueAdmin` |
| `authentication` | `roles/firebaseauth.admin` |
| `secret_manager` | `roles/secretmanager.admin` |
| `cloud_run` | `roles/run.admin` |

`additional_roles` で上記に積み増しできる。

### 出力

- `ci_service_account_email` — 作成された SA の email
- `ci_service_account_roles` — 実際に付与された roles のリスト

---

## 追加 Service Accounts (`service_accounts`)

CI 以外の用途 (アプリランタイム、バッチ、外部連携など) で使う SA。現状 `type = "deploy"` のみ実装されている。

### 指定方法

```hcl
service_accounts = [
  {
    account_id   = "app-runtime"
    display_name = "App Hosting Runtime SA"
    type         = "deploy"
    args = {
      hosting   = false
      functions = false
      firestore = true
      storage   = true
      scheduler = false
      tasks     = false
      blocking  = false
    }
  },
  {
    account_id = "scheduler-bot"
    type       = "deploy"
    args = {
      scheduler = true
      tasks     = true
    }
  },
]
```

### `args` で付与される roles

`true` にしたフラグごとに以下が付与される。`ci_service_account` と同じロジック。

| `args` フィールド | 付与 roles |
|------|----------|
| `hosting` | `roles/firebasehosting.admin` |
| `functions` | `roles/cloudfunctions.admin`, `roles/iam.serviceAccountUser`, `roles/artifactregistry.admin` |
| `firestore` | `roles/datastore.indexAdmin`, `roles/firebaserules.admin` |
| `storage` | `roles/firebasestorage.viewer`, `roles/storage.objectAdmin`, `roles/storage.admin` |
| `scheduler` | `roles/cloudscheduler.admin` |
| `tasks` | `roles/cloudtasks.queueAdmin` |
| `blocking` | `roles/firebaseauth.admin` |

すべての `type = "deploy"` SA に共通で `roles/runtimeconfig.admin` が付与される。

任意の追加 role が必要な場合は `roles = ["roles/..."]` を併用する。

### 出力

- `service_account_emails` — `{ account_id => email }` の map
- `service_account_roles` — `{ account_id => [roles...] }` の map

---

## App Hosting の compute SA

`app_hosting` 機能を有効化し、`app_hosting.service_account` を空文字 (= 自動作成) にした場合、以下の SA が自動的に作られる:

- account_id: `firebase-app-hosting-compute`
- 付与 role: `roles/firebaseapphosting.computeRunner`

既存の SA を使いたい場合は `app_hosting.service_account = "<email>"` を指定する (この場合は SA 作成・role 付与は行わない)。

---

## ベストプラクティス

- CI 用の SA は基本 1 個 (`ci_service_account`) に集約する
- アプリランタイム用は **CI SA を流用せず**、`service_accounts` で別 SA を用意する (権限分離 / 監査ログ追跡)
- `service_accounts[*].args` で必要最小限のフラグのみ `true` にする
- Identity Platform の blocking functions を運用する場合は `args.blocking = true` を付ける SA を用意する (`roles/firebaseauth.admin` が必要)
