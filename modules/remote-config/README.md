# modules/remote-config

Firebase Remote Config API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。本機能の API のみを有効化するためのアタッチポイント。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |

## Outputs

なし。

## 関連 API

- `firebaseremoteconfig.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.remote_config != null` の場合に呼び出される。

## 管理範囲外

Remote Config パラメータ / Condition / A/B test 設定はすべて Console / Firebase CLI / Admin SDK で管理する。
