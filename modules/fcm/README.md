# modules/fcm

Firebase Cloud Messaging API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。本機能の API のみを有効化するためのアタッチポイント。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |

## Outputs

なし。

## 関連 API

- `fcm.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.fcm != null` の場合に呼び出される。

## 管理範囲外

- FCM Topic / device token のサーバーサイド管理
- Push 通知の送信
- Console での legacy API 切り替え

将来 FCM 周辺リソースを Terraform 化する必要が出た場合の拡張ポイントとして残している。
