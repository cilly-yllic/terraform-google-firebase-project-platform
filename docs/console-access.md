# Firebase Console / GCP IAM の権限設計

本モジュールが扱う「人間 (user) のアクセス権限」は `users` 変数で表現する。

Firebase Console は GCP IAM をベースに動作するため、`roles/viewer` / `roles/editor` / `roles/owner` を付与すれば Firebase Console にも自動的に同等の権限でアクセスできる。

---

## `users` 変数の構造

```hcl
users = [
  {
    email  = "dev-lead@example.com"
    role   = "editor"   # viewer | editor | owner
    deploy = true       # オプション (default: false)
  },
  {
    email = "viewer@example.com"
    role  = "viewer"
  },
]
```

| Field | 必須 | 説明 |
|-------|:---:|------|
| `email` | yes | user email (Google アカウント) |
| `role` | no (default `"viewer"`) | `viewer` / `editor` / `owner` のいずれか |
| `deploy` | no (default `false`) | `true` で Cloud Functions / Artifact Registry のデプロイに必要な roles も追加 |

---

## 付与される roles

### `role` フィールド

| `role` 値 | 付与される roles |
|-----------|-----------------|
| `viewer` | `roles/viewer` |
| `editor` | `roles/editor` |
| `owner` | `roles/owner` |

### `deploy = true` の追加 roles

```
roles/cloudfunctions.admin
roles/artifactregistry.reader
```

`viewer` だが手動デプロイは行う、というケースで使う。

---

## member 形式

`users[].email` は Google アカウントの email を直接指定する。内部的に `user:<email>` 形式の IAM member に展開される。

`group:` や `serviceAccount:` を扱いたい場合は `service_accounts` 変数 (SA 作成 + roles 自動付与) を使うか、`additional_apis` のような追加変数経由で `google_project_iam_member` を別途呼び出す (本モジュールでは現状未対応)。

---

## Firebase Console との関係

Firebase Console のアクセス権は GCP IAM をベースに判定される (Identity Platform / Firestore / Hosting 等のリソースアクセスはすべて GCP IAM role でゲートされる)。

| GCP role | Firebase Console での挙動 |
|---------|--------------------------|
| `roles/viewer` | 全機能の閲覧のみ |
| `roles/editor` | 各機能の編集が可能。プロジェクト設定の一部は不可 |
| `roles/owner` | プロジェクト設定 / IAM 変更含むすべての操作 |

より細かい Firebase 固有 role (`roles/firebase.admin`, `roles/firebaseauth.admin` 等) を付与したい場合は、`users` ではなく `service_accounts` / 外部の IAM 管理に寄せる方が責務分離しやすい。

---

## ベストプラクティス

- 本番 Project には `owner` を 1〜2 名のみ。普段の開発者は `editor` (+ `deploy = true`)
- 非エンジニアは `viewer`
- CI/CD は **`users` ではなく `ci_service_account`** を使う ([service-accounts.md](./service-accounts.md))
- アプリのバックエンドが使う SA は **`service_accounts`** に列挙する (`users` には入れない)

---

## 例

### 開発リード (editor + deploy) + 閲覧メンバー

```hcl
users = [
  { email = "dev-lead@example.com", role = "editor", deploy = true },
  { email = "qa@example.com",       role = "viewer" },
]
```

### Owner 1 名 + editor 複数

```hcl
users = [
  { email = "tech-lead@example.com", role = "owner" },
  { email = "dev-a@example.com",     role = "editor", deploy = true },
  { email = "dev-b@example.com",     role = "editor", deploy = true },
]
```
