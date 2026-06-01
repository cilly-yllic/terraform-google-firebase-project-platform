# examples/full

全機能 on の構成例。Firebase core / extensions / GCP services / IAM (users + ci_service_account + service_accounts) をすべて使う。

## このサンプルが示すこと

- 機能変数の **3 パターン** (`true` / `{ ... }` / リスト構造) すべてを利用
- `additional_apis` で自動判定外の API (`iap.googleapis.com`) を追加
- `users` に複数ユーザー (editor + deploy / viewer)
- `ci_service_account` を `additional_roles` 付きで明示指定
- `service_accounts` で deploy 用追加 SA を作成
- `firestore.databases` で複数 DB を作成
- `storage.buckets` + `firestore_backup` で追加 bucket と backup bucket を作成
- `data_connect.cloud_sql` で Cloud SQL も含めて作成

## 期待される作成リソース (抜粋)

| 種別 | リソース |
|------|---------|
| API 有効化 | 30+ API (機能 on/off + `iap.googleapis.com`) |
| Firebase core | Firebase project / Identity Platform / Firestore default + 2 databases (`analytics-db`, `logs-db`) / RTDB / Hosting site + Web App / Storage default + 2 buckets (`uploads`, `icons`) + Firestore backup bucket / Data Connect service + Cloud SQL instance |
| Firebase extensions | FCM / Remote Config / App Check / Crashlytics / Performance / Analytics / Extensions すべて API 有効化 |
| GCP services | Secret Manager / Cloud Tasks / Cloud Scheduler / Pub/Sub / Eventarc / Cloud Run / Cloud Functions すべて API 有効化 |
| IAM | 2 user binding + CI SA (`ci-deploy` + 自動 roles + `roles/viewer`) + 追加 SA (`app-runtime`) |

詳細は [`main.tf`](./main.tf) を参照。

## 使い方

### 前提

- GCP Project (`my-full-project`) が作成済み
- Billing Account ID (`XXXXXX-XXXXXX-XXXXXX`) を実際の値に書き換え (もしくは `-var` で渡す形に修正)
- Terraform 実行 SA に十分な権限 (`roles/owner` 相当、または各機能の `*.admin` を網羅)

### 実行

```bash
cd examples/full
terraform init
terraform plan
terraform apply
```

`apply` は 30+ API 有効化と数十リソースの作成を伴うため、5〜15 分程度かかる。

### 注意

- **Cloud SQL instance** が作成される。料金が発生する点に注意 (`db-f1-micro`)
- **deletion_protection = false** で作成されるため、`destroy` で消える
- **Identity Platform config** は **GCP Project に 1 つの singleton**。一度作成すると Console から削除できない
- Storage / Firestore は **deny-all 初期 rules** で作成される。本番ルールは Firebase CLI でデプロイする

### 後片付け

```bash
terraform destroy
```

Cloud SQL や Firestore に **データを書き込んだ後の destroy** は実用上避けるべき。試用後すぐに destroy する想定。

## 値の書き換えポイント

`main.tf` の以下を実利用時に書き換える:

- `project_id` (`"my-full-project"` → 実 project ID)
- `billing_account` (`"XXXXXX-XXXXXX-XXXXXX"` → 実 billing account ID)
- `users[*].email` (テンプレートの `example.com` を実 email に)
- `hosting.site_id` / `data_connect.service_id` (グローバル一意である必要のあるもの)

## 関連ドキュメント

- [docs/variables-reference.md](../../docs/variables-reference.md) — 各機能変数の完全リファレンス
- [docs/api-auto-enablement.md](../../docs/api-auto-enablement.md) — 機能 → 自動有効化 API
- [docs/service-accounts.md](../../docs/service-accounts.md) — CI SA / 追加 SA の運用
