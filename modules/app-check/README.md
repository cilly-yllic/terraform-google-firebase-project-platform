# modules/app-check

Firebase App Check API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。本機能の API のみを有効化するためのアタッチポイント。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |

## Outputs

なし。

## 関連 API

- `firebaseappcheck.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.app_check != null` の場合に呼び出される。

## 管理範囲外

- App Check provider (reCAPTCHA / DeviceCheck / Play Integrity) の登録
- App Check token enforce 設定 (per service)

これらは Console または App Check Admin SDK で管理する。
