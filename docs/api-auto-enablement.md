# API 自動判定

機能変数の状態から有効化する GCP API を自動決定する。利用者が `google_project_service` を個別に列挙する必要はない。

実装は [`main.tf`](../main.tf) の `locals.conditional_apis` ブロック。

---

## 設計判断

- **「機能 on/off ↔ 必要な API」の対応は本モジュールが知っている前提**にする
- 利用側で `enable_api_xxx = true` のような flag を別途持たない (機能 on/off と二重管理になるため)
- 利用者が追加で必要とする API は `additional_apis` で拡張可能
- `disable_on_destroy = false` で運用する。Project 削除時に API を一括 disable すると他リソースに副作用が出るため
- `disable_dependent_services = true` を指定。意図しない依存 API 残留を防ぐ

---

## 常に有効化される API

```
cloudresourcemanager.googleapis.com
serviceusage.googleapis.com
```

`iam.googleapis.com` は `service_accounts` / `ci_service_account` / `app_hosting` のいずれかが有効な場合に追加で有効化される。

---

## 機能変数別の対応表

| 機能変数 | 有効化される API |
|---------|----------------|
| `firebase` | `firebase.googleapis.com` |
| `authentication` | `identitytoolkit.googleapis.com` |
| `firestore` | `firestore.googleapis.com`, `firebaserules.googleapis.com` |
| `rtdb` | `firebasedatabase.googleapis.com` |
| `storage` | `firebasestorage.googleapis.com`, `storage.googleapis.com`, `firebaserules.googleapis.com` |
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

`distinct()` で重複排除されるため、複数機能で同じ API を要求しても 1 回しか有効化されない。

---

## `additional_apis` の使い分け

自動判定外の API を有効化したい場合に使う。要素は `.googleapis.com` で終わるバリデーションが入っている。

```hcl
additional_apis = [
  "iap.googleapis.com",
  "cloudkms.googleapis.com",
]
```

利用ケース例:

- IAP (Identity-Aware Proxy) を別途使う
- KMS で envelope encryption する
- Cloud Build trigger を別管理ツールから使うが、本モジュール側でも API は有効化しておきたい

---

## 削除挙動

`disable_on_destroy = false` のため、機能変数を `null` に変えても **対応する API は disable されない**。リソース (Firestore database, Storage bucket, etc.) は destroy されるが、API 自体は有効のまま残る。

これは「同じ Project 内の他リソースを破壊しない」ことを優先した設計判断。API を明示的に無効化したい場合は手動 (gcloud) で行う。
