# modules/hosting

Firebase Hosting の **Web App + Hosting site** を作成する submodule。

## 作成するリソース

| Resource | Provider | 役割 |
|----------|----------|------|
| `google_firebase_web_app.this` | `google-beta` | Firebase Web App (`site_id` を display name にする) |
| `google_firebase_hosting_site.this` | `google-beta` | Hosting site (Web App と紐付け) |

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |
| `site_id` | `string` | `var.project` (空文字なら project ID にフォールバック) | Hosting site ID |

## Outputs

| Name | Description |
|------|-------------|
| `site_id` | 実際に使用された site ID |
| `app_id` | Firebase Web App ID (App Hosting に渡す用) |
| `default_url` | Hosting site のデフォルト URL |

## 関連 API

- `firebasehosting.googleapis.com`

## ルートモジュールでの呼び出し条件

`var.hosting != null` の場合に呼び出される。

## 管理範囲外

- Hosting deploy (`firebase deploy --only hosting`)
- rewrites / redirects / headers
- カスタムドメイン
- GitHub Integration

これらは Firebase CLI または別途運用ツールで管理する。
