# modules/firestore

Cloud Firestore の **デフォルト database + 任意の追加 database + 初期 ruleset** を作成する submodule。

## 作成するリソース

| Resource | 役割 |
|----------|------|
| `google_firestore_database.default` | デフォルト database (`(default)`) を常に作成 |
| `google_firebaserules_ruleset.default` | デフォルト database 用の **deny-all** ruleset |
| `google_firebaserules_release.default` | ruleset を `cloud.firestore` に release |
| `google_firestore_database.additional` | `databases[]` で指定した追加 database 群 |

## 初期 ruleset (deny-all)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

これは「Terraform で security rules を本気で管理しない」前提のプレースホルダ。本番ルールは Firebase CLI (`firebase deploy --only firestore:rules`) でデプロイする想定。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |
| `location` | `string` | (required) | デフォルト DB の location |
| `type` | `string` | `"FIRESTORE_NATIVE"` | `FIRESTORE_NATIVE` / `DATASTORE_MODE` |
| `delete_protection_state` | `string` | `"DELETE_PROTECTION_DISABLED"` | `DELETE_PROTECTION_DISABLED` / `DELETE_PROTECTION_ENABLED` |
| `point_in_time_recovery` | `bool` | `false` | PITR を有効化 |
| `databases` | `list(object)` | `[]` | 追加 database のリスト (`database_id`, `location`, `type`, `delete_protection_state`, `point_in_time_recovery`) |

## Outputs

| Name | Description |
|------|-------------|
| `default_database_name` | デフォルト DB の resource name |
| `default_database_location` | デフォルト DB の location |
| `additional_databases` | `{ database_id => name }` の map |

## 関連 API

- `firestore.googleapis.com`
- `firebaserules.googleapis.com`

## ルートモジュールでの呼び出し条件

`var.firestore != null` の場合に呼び出される。
