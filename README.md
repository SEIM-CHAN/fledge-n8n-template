# fb-auto-sales-n8n

Facebook / Instagram DMを起点に、n8nでAI営業フローを自動化するMVPプロジェクト。

## Tech Stack

- n8n
- Docker
- PostgreSQL
- Meta Graph API
- OpenAI API

## Setup

```bash
cp .env.example .env
docker compose up -d
```

`http://localhost:5678` で n8n を開き、初回セットアップを完了させる。

## MVP Scope

- Meta WebhookでFacebook / Instagram DMを受信
- 会話内容をPostgreSQLに保存
- OpenAIで営業返信文を生成
- 商談化候補をleadとして管理

## Directory

- `compose.yaml`: n8n / PostgreSQL のローカル起動
- `init-data.sh`: DBユーザー作成とMVP用テーブル初期化
- `prompts/`: OpenAI に渡す営業用プロンプト
- `workflows/`: n8nワークフロー設計メモ

## Required Environment Variables

- `POSTGRES_PASSWORD`
- `POSTGRES_NON_ROOT_PASSWORD`
- `N8N_ENCRYPTION_KEY`
- `WEBHOOK_URL`

必要に応じて以下も設定する。

- `N8N_HOST`
- `N8N_PROTOCOL`
- `GENERIC_TIMEZONE`
- `TZ`

## Next Build Steps

1. `workflows/facebook-instagram-dm-mvp.md` の流れで n8n ワークフローを作る
2. Meta Graph API の Webhook / Messaging 認証情報を n8n に登録する
3. OpenAI ノードに `prompts/system.md` と `prompts/sales-reply.md` の内容を組み込む
4. 返信前に human review を挟むか、自動送信にするかを決める
