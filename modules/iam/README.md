# modules/iam

Project レベル IAM (ユーザー / CI SA / 追加 SA) を一括で管理する submodule。

## 作成するリソース

| Resource | 役割 |
|----------|------|
| `google_project_iam_member.user` | `users[]` で指定したユーザーへの role 付与 (base role + 任意で deploy role) |
| `google_service_account.ci` | `ci_service_account != null` の場合に作成 |
| `google_project_iam_member.ci_role` | CI SA への role 付与 (自動判定 + `additional_roles`) |
| `google_service_account.this` | `service_accounts[]` の SA を for_each で作成 |
| `google_project_iam_member.sa_computed` | `service_accounts[].args` から計算した role を付与 |
| `google_project_iam_member.sa_explicit` | `service_accounts[].roles` で明示した role を付与 |

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |
| `users` | `list(object)` | `[]` | `email`, `role` (`viewer\|editor\|owner`), `deploy` (bool) |
| `ci_service_account` | `object \| null` | `null` | `account_id`, `display_name`, `roles` (= 既に計算済みの roles リスト) |
| `service_accounts` | `list(object)` | `[]` | `account_id`, `display_name`, `type`, `roles`, `args` |

ルートモジュールが `var.users` / `var.ci_service_account` / `var.service_accounts` を受け取り、必要な前処理 (CI SA の roles 自動計算など) を行った上で本 submodule に渡している。

## Outputs

| Name | Description |
|------|-------------|
| `user_members` | 付与された IAM member 一覧 |
| `user_roles` | 付与された role 一覧 |
| `ci_service_account_email` | CI SA email (なければ `null`) |
| `ci_service_account_roles` | CI SA に付与された roles |
| `service_account_emails` | `{ account_id => email }` |
| `service_account_ids` | `{ account_id => unique_id }` |
| `service_account_roles` | `{ account_id => [roles...] }` (自動計算 + 明示の合算) |

## ユーザー role 付与ロジック

```
viewer  → roles/viewer
editor  → roles/editor
owner   → roles/owner

deploy=true の場合は、上記に加えて
  roles/cloudfunctions.admin
  roles/artifactregistry.reader
```

## CI SA / 追加 SA の自動 role

[docs/service-accounts.md](../../docs/service-accounts.md) を参照。

## 関連 API

- `iam.googleapis.com` (SA を作成する場合のみ root module で自動有効化)
