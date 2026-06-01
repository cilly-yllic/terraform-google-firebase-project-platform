# Upstream spec links

An index of the upstream design specs that underpin this repository.

The upstream specs are maintained in the [`cilly-yllic/terraform-gcp-project-factory`](https://github.com/cilly-yllic/terraform-gcp-project-factory) repository.

<details><summary>Ja</summary>

本リポジトリの設計・実装の根拠となる上流 spec へのリンク集。

上流 spec は [`cilly-yllic/terraform-gcp-project-factory`](https://github.com/cilly-yllic/terraform-gcp-project-factory) リポジトリで管理されている。

</details>

---

## Spec list

### 03 — terraform-google-firebase-project-platform spec v2

[`03-terraform-google-firebase-project-platform-spec-v2.md`](https://github.com/cilly-yllic/terraform-gcp-project-factory/blob/main/03-terraform-google-firebase-project-platform-spec-v2.md)

The foundational spec for this module. Covers the feature variable design (`null/true/object`), API auto-enablement rules, submodule structure, and the IAM model (`users` / `ci_service_account` / `service_accounts`).

| Mapping in this repo |
|---|
| `main.tf`, `variables.tf`, `outputs.tf`, `modules/*` |

<details><summary>Ja</summary>

本モジュールの基礎 spec。機能変数の設計 (`null/true/object`)、API 自動判定ルール、submodule 構成、IAM モデル (`users` / `ci_service_account` / `service_accounts`) を定義している。

対応するコード: `main.tf`, `variables.tf`, `outputs.tf`, `modules/*`

</details>

---

### 05 — Phase 2 webhook-driven architecture spec v1

[`05-phase2-webhook-architecture-spec-v1.md`](https://github.com/cilly-yllic/terraform-gcp-project-factory/blob/main/05-phase2-webhook-architecture-spec-v1.md)

Defines the Phase 2 (webhook-driven) architecture in which a TFC `run:completed` notification is relayed through Cloud Run → GitHub `repository_dispatch` → the firebase-platform workspace.

| Mapping in this repo |
|---|
| `cloud-run-router/` |

<details><summary>Ja</summary>

Phase 2 (webhook-driven) アーキテクチャの spec。TFC `run:completed` notification を Cloud Run → GitHub `repository_dispatch` → firebase-platform workspace とリレーする仕組みを定義する。

対応するコード: `cloud-run-router/`

</details>

---

### 06 — Public reusable GitHub Actions spec v1

[`06-public-actions-spec-v1.md`](https://github.com/cilly-yllic/terraform-gcp-project-factory/blob/main/06-public-actions-spec-v1.md)

Defines the public reusable GitHub Actions. In particular, **Action B** (`dispatch-tfc-firebase-platform`) reads the caller's `settings.yml`, references project-factory outputs, upserts the workspace, syncs variables, and starts a Run.

| Mapping in this repo |
|---|
| `actions/dispatch/` |

<details><summary>Ja</summary>

Public reusable GitHub Actions の spec。特に **Action B** (`dispatch-tfc-firebase-platform`) は、利用側リポジトリの `settings.yml` を読み、project-factory outputs を参照し、workspace を upsert して変数を同期し Run を起動する。

対応するコード: `actions/dispatch/`

</details>

---

### terraform-firebase-platform-architecture

[`terraform-firebase-platform-architecture.md`](https://github.com/cilly-yllic/terraform-gcp-project-factory/blob/main/terraform-firebase-platform-architecture.md)

An overarching architecture document describing the full Terraform execution platform (bootstrap → project-factory → firebase-project-platform → service workspaces) and how each layer splits responsibility.

| Mapping in this repo |
|---|
| Referenced throughout; see [architecture.md](./architecture.md) |

<details><summary>Ja</summary>

全体アーキテクチャドキュメント。Terraform 実行基盤の全レイヤー (bootstrap → project-factory → firebase-project-platform → service workspaces) と各レイヤーの責務分離を記述している。

対応: リポジトリ全体で参照; [architecture.md](./architecture.md) を参照

</details>

---

## Internal documentation

| Document | Content |
|----------|---------|
| [architecture.md](./architecture.md) | Position of this module, layer separation, bundled reference implementations |
| [variables-reference.md](./variables-reference.md) | Nested structures and defaults for feature variables |
| [api-auto-enablement.md](./api-auto-enablement.md) | Feature → auto-enabled GCP API mapping |
| [console-access.md](./console-access.md) | Firebase Console / GCP IAM access design |
| [service-accounts.md](./service-accounts.md) | CI SA auto-role logic and additional SA operations |
| [upgrade-guide.md](./upgrade-guide.md) | Breaking changes per Registry version |

<details><summary>Ja</summary>

| ドキュメント | 内容 |
|----------|---------|
| [architecture.md](./architecture.md) | 本モジュールの位置づけ / レイヤー分離 / reference 実装との責務分離 |
| [variables-reference.md](./variables-reference.md) | 機能変数のネスト構造とデフォルト値 |
| [api-auto-enablement.md](./api-auto-enablement.md) | 機能 → 自動有効化 GCP API の対応表 |
| [console-access.md](./console-access.md) | Firebase Console / GCP IAM の権限設計 |
| [service-accounts.md](./service-accounts.md) | CI SA の自動 role 決定ロジックと追加 SA の運用 |
| [upgrade-guide.md](./upgrade-guide.md) | Registry バージョン間の breaking change |

</details>
