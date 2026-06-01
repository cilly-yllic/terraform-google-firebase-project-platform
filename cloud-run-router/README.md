# cloud-run-router

TFC (Terraform Cloud) Run completion notification を受信し、GitHub `repository_dispatch` を発火する Cloud Run service の **reference implementation**。

Phase 2 (webhook-driven) アーキテクチャの中核コンポーネント。全体アーキテクチャ上の位置づけは [`docs/architecture.md`](../docs/architecture.md) を参照。

---

## アーキテクチャ概要

```text
TFC Workspace (project-factory-{service})
  ↓ Run applied
  ↓ TFC Notification (HTTP POST + HMAC-SHA512)
  ↓
Cloud Run router (/webhook)
  ↓ HMAC verify → workspace_name routing → metadata 解析
  ↓
GitHub repository_dispatch → Project Repository
  ↓ firebase_platform_requested event
  ↓
Action B Workflow → Firebase Platform Workspace Run
```

---

## 機能

- **HMAC-SHA512 署名検証** (`X-TFE-Notification-Signature`)
- **workspace_name パターンルーティング** (regex ベース、環境変数で設定可能)
- **metadata 解析** (Option A: TFC API / Option B: run_message JSON / 両対応)
- **GitHub App 認証** + `repository_dispatch` 発火
- **Cloud Logging** 対応の構造化 JSON ログ
- **ヘルスチェック** (`GET /healthz`)

---

## エンドポイント

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/webhook` | TFC Notification 受信 |
| `GET` | `/healthz` | ヘルスチェック |

---

## 環境変数

### 必須

| Name | Description |
|------|-------------|
| `TFC_NOTIFICATION_SECRET` | TFC Notification の HMAC 共有 secret |
| `GITHUB_APP_ID` | GitHub App ID |
| `GITHUB_APP_PRIVATE_KEY` | GitHub App private key (PEM 形式) |

### オプション

| Name | Default | Description |
|------|---------|-------------|
| `PORT` | `8080` | HTTP リスニングポート |
| `TFC_API_TOKEN` | — | TFC API token (Option A / both 使用時に必要) |
| `TFC_API_BASE_URL` | `https://app.terraform.io` | TFC API base URL |
| `WORKSPACE_NAME_PATTERN` | `^project-factory-(?<service>.+)$` | project-factory stage の workspace 名 regex (named group `service` 必須) |
| `TERMINAL_WORKSPACE_PATTERN` | `^(?<service>.+)-(?<env>[^-]+)$` | terminal stage の workspace 名 regex (env = 最後のセグメント) |
| `DISPATCH_EVENT_TYPE` | `firebase_platform_requested` | repository_dispatch の event_type |
| `METADATA_SOURCE` | `both` | metadata 解析方法: `run_message` / `run_variables` / `both` |

### Secret 設計

Secret Manager に以下を格納し、Cloud Run に環境変数またはボリュームマウントで渡す:

- `TFC_NOTIFICATION_SECRET` — HMAC 共有 secret
- `GITHUB_APP_PRIVATE_KEY` — GitHub App private key (PEM)
- `TFC_API_TOKEN` — TFC API token (Option A 使用時)

---

## metadata 解析方法

### Option A: `run_variables` (TFC API)

Cloud Run が TFC API (`GET /api/v2/runs/{run_id}`) 経由で Workspace Variables を取得。
Action A 側で以下の変数を設定する規約:

- `TF_VAR_service` or `METADATA_SERVICE`
- `TF_VAR_environment` or `METADATA_ENV`
- `TF_VAR_source_repo` or `METADATA_SOURCE_REPO`

### Option B: `run_message` (JSON parse)

Action A が Run 起動時に `run_message` に JSON を埋め込む:

```json
{"service": "my-svc", "env": "dev", "source_repo": "owner/repo"}
```

### `both` (デフォルト)

`run_message` を先に試行し、パース失敗時に TFC API にフォールバック。

---

## ローカル開発

```bash
# 依存インストール
npm install

# 開発サーバー起動 (tsx)
export TFC_NOTIFICATION_SECRET=dev-secret
export GITHUB_APP_ID=123456
export GITHUB_APP_PRIVATE_KEY="$(cat /path/to/private-key.pem)"
npm run dev

# テスト実行
npm test

# 型チェック
npm run lint

# ビルド
npm run build
npm start
```

---

## デプロイ手順

`deploy/` ディレクトリは `.gitignore` で除外されており、利用者が自組織に合わせて構成する。

### 1. Dockerfile (例)

```dockerfile
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY tsconfig.json ./
COPY src/ src/
RUN npm run build

FROM node:20-slim
WORKDIR /app
COPY --from=builder /app/dist dist/
COPY --from=builder /app/package*.json ./
# No runtime dependencies — only Node.js built-ins are used
ENV NODE_ENV=production
EXPOSE 8080
CMD ["node", "dist/index.js"]
```

### 2. Cloud Run デプロイ (gcloud)

```bash
# ビルド & push
gcloud builds submit --tag gcr.io/${PROJECT_ID}/cloud-run-router

# デプロイ
gcloud run deploy cloud-run-router \
  --image gcr.io/${PROJECT_ID}/cloud-run-router \
  --region asia-northeast1 \
  --platform managed \
  --allow-unauthenticated \
  --set-secrets "TFC_NOTIFICATION_SECRET=tfc-notification-secret:latest,GITHUB_APP_PRIVATE_KEY=github-app-private-key:latest" \
  --set-env-vars "GITHUB_APP_ID=${GITHUB_APP_ID},DISPATCH_EVENT_TYPE=firebase_platform_requested"
```

### 3. TFC Notification 設定

各 `project-factory-{service}` Workspace に Notification を追加:

- **Destination URL**: Cloud Run service の HTTPS URL + `/webhook`
- **Token**: `TFC_NOTIFICATION_SECRET` と同じ値
- **Triggers**: `run:completed`

### 4. Cloud Run SA の最小権限

- Secret Manager Secret Accessor (`roles/secretmanager.secretAccessor`)
- 他の GCP 権限は不要 (GitHub API / TFC API はそれぞれのトークンで認証)

---

## セキュリティ

- **HMAC 検証必須**: `X-TFE-Notification-Signature` header と body を HMAC-SHA512 で検証。不一致の場合は `401` を返す
- **GitHub App credentials**: Secret Manager 経由で Cloud Run に提供
- **Cloud Run SA**: 最小権限 (Secret Manager accessor のみ)
- **(推奨) Cloud Armor**: TFC の outbound IP を allowlist に設定
- **構造化ログ**: 全リクエストを Cloud Logging に記録 (run_id, workspace_name, dispatch 先, 結果)

---

## Phase 1 との共存

本 router は TFC Workspace に Notification が設定されていない限り呼び出されない。
Phase 1 (polling) と Phase 2 (webhook) は service 単位で混在可能。

| 状態 | Cloud Run router | 動作 |
|------|-----------------|------|
| Phase 1 only | 未デプロイ | polling 方式 (既存) |
| 移行期 | デプロイ済 | service ごとに opt-in |
| Phase 2 only | デプロイ済 | webhook 方式 |
