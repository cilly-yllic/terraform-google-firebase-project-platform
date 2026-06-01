# modules/crashlytics

Firebase Crashlytics API 有効化のためのプレースホルダ submodule。

## 作成するリソース

なし。本機能の API のみを有効化するためのアタッチポイント。

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project` | `string` | (required) | GCP project ID |

## Outputs

なし。

## 関連 API

- `firebasecrashlytics.googleapis.com` (root module で自動有効化)

## ルートモジュールでの呼び出し条件

`var.crashlytics != null` の場合に呼び出される。

## 管理範囲外

Crashlytics は SDK 側のセットアップとイベント送信が中心で、サーバー側で管理する設定は基本的にない。
