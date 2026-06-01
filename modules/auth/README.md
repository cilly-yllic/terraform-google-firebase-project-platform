# modules/auth

Firebase Authentication / Identity Platform の設定を行う submodule。

## 作成するリソース

| Resource | Provider | 役割 |
|----------|----------|------|
| `google_identity_platform_config.this` | `google-beta` | Identity Platform config (blocking functions 付き) |

`blocking_functions.before_create` / `before_sign_in` が空文字でない場合のみ、`blocking_functions { triggers { ... } }` ブロックが追加される。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |
| `blocking_functions.before_create` | `string` | `""` | `beforeCreate` トリガー Cloud Function URI |
| `blocking_functions.before_sign_in` | `string` | `""` | `beforeSignIn` トリガー Cloud Function URI |

## Outputs

| Name | Description |
|------|-------------|
| `name` | Identity Platform config resource name (`projects/{project}/config`) |

## 関連 API

- `identitytoolkit.googleapis.com`

## ルートモジュールでの呼び出し条件

`var.authentication != null` の場合に呼び出される。

## 副作用

Identity Platform config は **GCP Project に 1 つだけ存在する singleton resource**。一度作成すると Console から削除できない点に注意。

## Firebase Console との対応

- Console: Authentication → Settings → Blocking functions
- 各プロバイダ (Google / Email / 等) の sign-in method 設定はこの module の範疇外 (Console または別途 Terraform 管理)
