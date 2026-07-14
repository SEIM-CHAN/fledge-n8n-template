# fb-auto-sales-n8n

n8n を使って AI 営業フローを組むための、ローカル開発用テンプレートリポジトリです。

このテンプレートは次の 2 つを前提に整理しています。

- 人間が要件や構想を `docs/agent-requests/` に書く
- エージェントがその指示を読んで `workflows/n8n/` に n8n の JSON を生成する

## What This Template Includes

- `compose.yaml`: n8n と PostgreSQL の最小ローカル起動
- `init-data.sh`: DM 自動化向けの基本テーブル初期化
- `prompts/`: 営業返信向けのプロンプト
- `docs/`: 構想・設計・エージェント依頼メモ
- `.agents/skills/`: エージェントに守ってほしい作業ルール
- `workflows/`: 設計メモと生成済み n8n JSON の置き場

## Directory

- `docs/architecture.md`: システム全体像
- `docs/agent-requests/`: 人間がエージェントへ渡す依頼ドキュメント
- `docs/agent-requests/example-instagram-dm-auto-reply.md`: 依頼書の完成例
- `prompts/system.md`: OpenAI system prompt
- `prompts/sales-reply.md`: 返信生成用テンプレート
- `workflows/facebook-instagram-dm-mvp.md`: DM フローの設計メモ
- `workflows/n8n/`: エージェントが生成した n8n JSON
- `.agents/skills/n8n-json-template/SKILL.md`: この repo 向けエージェントスキル

## Setup

```bash
cp .env.example .env
docker compose up -d
```

起動後に `http://localhost:5678` で n8n を開き、初回セットアップを完了します。

## First 5 Minutes

最短で 1 本のワークフローを作る流れです。

1. `.env.example` を `.env` にコピーし、空の 3 つの秘密値をランダムな値で埋める
2. `docker compose up -d` を実行し、`http://localhost:5678` で n8n の初回セットアップを完了する
3. `docs/agent-requests/example-instagram-dm-auto-reply.md` を複製して、作りたい内容へ書き換える
4. エージェントに依頼書を読ませ、`workflows/n8n/wf_<purpose>.json` を生成させる
5. n8n UI で JSON を import し、Credentials を設定してテストする

`.env` の秘密値は次のように生成できます。

```bash
openssl rand -hex 32
```

## Basic Workflow

1. `docs/agent-requests/` にやりたいことを書く
2. エージェントにそのファイルを読ませて、n8n JSON を作らせる
3. 生成結果を `workflows/n8n/` に保存する
4. n8n UI から JSON を import して確認する

## Environment Variables

必須:

- `POSTGRES_PASSWORD`
- `POSTGRES_NON_ROOT_PASSWORD`
- `N8N_ENCRYPTION_KEY`
- `WEBHOOK_URL`

通常は変更不要:

- `POSTGRES_USER`
- `POSTGRES_DB`
- `POSTGRES_NON_ROOT_USER`
- `N8N_HOST`
- `N8N_PROTOCOL`
- `GENERIC_TIMEZONE`
- `TZ`

## Notes

- API キー類は基本的に n8n Credentials で管理する想定です
- `workflows/n8n/` はテンプレートの出力先であり、最初は空で問題ありません
- `local-files/` は n8n のファイル入出力確認用です
