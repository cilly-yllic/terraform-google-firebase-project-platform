# modules/performance

Firebase Performance Monitoring API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。本機能の API のみを有効化するためのアタッチポイント。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |

## Outputs

なし。

## 関連 API

- `firebaseperformance.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.performance != null` の場合に呼び出される。

## 管理範囲外

カスタムトレース / 計測設定は SDK 側で行う。
