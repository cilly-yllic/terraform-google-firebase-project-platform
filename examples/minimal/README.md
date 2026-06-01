# examples/minimal

Firebase 化 + Firestore のみの最小構成。

## このサンプルが示すこと

- 機能変数を **`true`** で渡すだけのデフォルト構成
- 必須引数は `project_id` のみ
- API 有効化は機能 on/off から自動判定される
- `region` は `asia-northeast1`

## 期待される作成リソース

| 種別 | リソース |
|------|---------|
| API 有効化 | `cloudresourcemanager`, `serviceusage`, `firebase`, `firestore`, `firebaserules` |
| Firebase | `google_firebase_project.this` |
| Firestore | デフォルト database (`(default)`, location = `asia-northeast1`, type = `FIRESTORE_NATIVE`) + deny-all ruleset |
| IAM | なし (`users` / `ci_service_account` / `service_accounts` は未指定) |

## 使い方

### 前提

- GCP Project (`my-minimal-project`) が **既に作成済み** であること (上流の project-factory ステージなどで作成)
- `gcloud auth application-default login` などで Google credentials が設定されていること

### 実行

```bash
cd examples/minimal

# project_id を実際の値に書き換えるか、-var で渡す
terraform init
terraform plan  -var "project_id=<YOUR_PROJECT_ID>"
terraform apply -var "project_id=<YOUR_PROJECT_ID>"
```

> `main.tf` 内では `project_id = "my-minimal-project"` がハードコードされている。実利用時はそこを書き換えるか、`variable "project_id"` を定義して上記の `-var` で渡す形に変更する。

### 後片付け

```bash
terraform destroy -var "project_id=<YOUR_PROJECT_ID>"
```

> Firestore database は `delete_protection_state = "DELETE_PROTECTION_DISABLED"` で作成されるため、`destroy` で消える。本番では `delete_protection_state = "DELETE_PROTECTION_ENABLED"` を検討する。

## 次のステップ

- 機能を追加したい → [`examples/full/`](../full/) を参考に `storage`, `hosting`, `authentication` 等を追加
- カスタム設定にしたい → 各機能変数を object 形式で指定 ([docs/variables-reference.md](../../docs/variables-reference.md))
