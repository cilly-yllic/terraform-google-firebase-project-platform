# modules/storage

Cloud Storage for Firebase の **デフォルト bucket + 追加 bucket + 任意の Firestore backup bucket + 初期 ruleset** を作成する submodule。

## 作成するリソース

| Resource | 役割 |
|----------|------|
| `google_firebase_storage_bucket.default` | デフォルト bucket (`{project}.firebasestorage.app`) を Firebase Storage に登録 |
| `google_firebaserules_ruleset.storage` | デフォルト bucket 用の **deny-all** ruleset |
| `google_firebaserules_release.storage` | ruleset を `firebase.storage/{bucket}` に release |
| `google_storage_bucket.additional` | `buckets[]` で指定した GCS bucket |
| `google_firebase_storage_bucket.additional` | 追加 bucket を Firebase Storage に登録 |
| `google_storage_bucket_iam_member.additional` | 追加 bucket への IAM binding |
| `google_storage_bucket.firestore_backup` | (任意) Firestore export 用 bucket |
| `google_project_iam_member.firestore_backup_*` | (任意) Firestore export SA への bucket 書き込み権限 |

## 初期 ruleset (deny-all)

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

本番ルールは Firebase CLI (`firebase deploy --only storage:rules`) でデプロイする想定。

## bucket 命名規則

- `buckets[].name` は **`{project}-` prefix が自動付与** される (例: `name = "uploads"` → 実際の bucket は `{project}-uploads`)
- `buckets[].raw_name = true` を指定すると prefix を付けずに `name` をそのまま使う (グローバル一意な命名にしたい場合のみ)

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |
| `location` | `string` | (required) | bucket デフォルト location |
| `buckets` | `list(object)` | `[]` | 追加 bucket。フィールド: `name`, `raw_name`, `location`, `storage_class`, `iams[]` |
| `firestore_backup` | `object \| null` | `null` | Firestore backup bucket 設定 |

`firestore_backup` のフィールド:

| Field | Default | Description |
|-------|---------|-------------|
| `bucket_name` | `"firestore-backups"` | suffix (`{project}-<suffix>`) |
| `export_platform` | `"cloud_functions"` | `cloud_functions` / `cloud_run`。export を実行する SA への IAM 付与先を切り替え |
| `soft_delete_policy.retention_duration_seconds` | `0` | soft delete 保持秒数 |

## Outputs

| Name | Description |
|------|-------------|
| `default_bucket` | デフォルト bucket 名 |
| `additional_buckets` | `{ input_name => resolved_GCS_name }` |
| `firestore_backup_bucket` | backup bucket 名 (なければ `null`) |

## 関連 API

- `firebasestorage.googleapis.com`
- `storage.googleapis.com`
- `firebaserules.googleapis.com`

## ルートモジュールでの呼び出し条件

`var.storage != null` の場合に呼び出される。
