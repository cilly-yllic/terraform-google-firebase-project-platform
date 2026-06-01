# modules/pubsub

Pub/Sub API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。Topic / Subscription 自体は本モジュールでは作成しない。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |

## Outputs

なし。

## 関連 API

- `pubsub.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.pubsub != null` の場合に呼び出される。

## 設計意図

Pub/Sub は Eventarc / Cloud Functions / Cloud Run と組み合わせて service 固有のドメイン用途に使われることが多く、本モジュールでは API 有効化のみに留めている。
