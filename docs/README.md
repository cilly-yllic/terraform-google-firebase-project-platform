# docs/

Detailed documentation for this repository. These pages expand on topics that branch out from the top-level [`README.md`](../README.md).

| Document | Content |
|----------|---------|
| [architecture.md](./architecture.md) | Overall architecture, this module's position, responsibility split with the reference implementations |
| [variables-reference.md](./variables-reference.md) | Nested structures and defaults for feature variables (`firestore`, `storage`, `data_connect`, etc.) |
| [api-auto-enablement.md](./api-auto-enablement.md) | Feature → auto-enabled GCP API mapping |
| [console-access.md](./console-access.md) | Firebase Console / GCP IAM access design and the `users` variable |
| [service-accounts.md](./service-accounts.md) | CI Service Account auto-role logic and additional SA operations |
| [upgrade-guide.md](./upgrade-guide.md) | Breaking changes per Registry version, in chronological order |
| [upstream-spec-links.md](./upstream-spec-links.md) | Index of upstream design specs (`terraform-gcp-project-factory`) that underpin this repo |

Per-submodule behavior is documented in `modules/<name>/README.md`. Deploy steps for the reference implementations live in [`cloud-run-router/README.md`](../cloud-run-router/README.md) and [`actions/dispatch/README.md`](../actions/dispatch/README.md).

<details><summary>Ja</summary>

本リポジトリの詳細ドキュメント。トップレベルの [`README.md`](../README.md) から枝分かれする深掘り資料を置く。

- [architecture.md](./architecture.md) — 全体アーキテクチャ / 本モジュールの位置づけ / reference 実装との責務分離
- [variables-reference.md](./variables-reference.md) — 機能変数 (`firestore`, `storage`, `data_connect` 等) のネスト構造とデフォルト値
- [api-auto-enablement.md](./api-auto-enablement.md) — 機能 on/off から自動有効化される GCP API の対応表
- [console-access.md](./console-access.md) — Firebase Console / GCP IAM の権限設計と `users` の使い方
- [service-accounts.md](./service-accounts.md) — CI Service Account の自動 role 決定ロジックと追加 SA の運用
- [upgrade-guide.md](./upgrade-guide.md) — Registry バージョン間の breaking change を時系列で記録
- [upstream-spec-links.md](./upstream-spec-links.md) — 本リポジトリの設計根拠となる上流 spec へのリンク集

submodule 個別の挙動は `modules/<name>/README.md` に置いている。reference 実装の deploy 手順は [`cloud-run-router/README.md`](../cloud-run-router/README.md) と [`actions/dispatch/README.md`](../actions/dispatch/README.md) を参照。

</details>
