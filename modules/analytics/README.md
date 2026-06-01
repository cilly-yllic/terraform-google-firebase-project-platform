# modules/analytics

Google Analytics for Firebase API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。本機能の API のみを有効化するためのアタッチポイント。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |

## Outputs

なし。

## 関連 API

- `analyticsadmin.googleapis.com` (root module で自動有効化)
- `firebase.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.analytics != null` の場合に呼び出される。

## 管理範囲外

- GA4 property との link 作成 (Console / Analytics Admin API で実施)
- Event / Conversion 設定
- BigQuery export 設定

これらは別途運用ツールで管理する。
