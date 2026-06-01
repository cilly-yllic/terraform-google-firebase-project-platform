# modules/extensions

Firebase Extensions API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。本機能の API のみを有効化するためのアタッチポイント。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |

## Outputs

なし。

## 関連 API

- `firebaseextensions.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.extensions != null` の場合に呼び出される。

## 管理範囲外

各 Extension の install / config (`firebase ext:install ...`) は Firebase CLI で実施する。
