# Facebook / Instagram DM MVP Workflow

## Goal

Facebook / Instagram の問い合わせ DM を受け取り、会話を保存し、AI で一次返信を作り、必要に応じて自動返信または営業通知につなげる。

## Workflow Units

MVP は 1 本に詰め込みすぎず、最低でも次の 3 ワークフローに分けると運用しやすい。

1. `wf_meta_webhook_entry`
2. `wf_dm_auto_reply`
3. `wf_high_intent_notify`

## 1. wf_meta_webhook_entry

Meta からの受信イベントを受け、正規化して返信ワークフローへ渡す入口。

### Recommended n8n Node Flow

1. `Webhook`
2. `If`: verification request か判定
3. `Respond to Webhook`: verification token を返す
4. `Code`: payload normalize
5. `If`: message event のみ通す
6. `Execute Workflow`: `wf_dm_auto_reply`
7. `Respond to Webhook`: `200 OK`

### Webhook Settings

- Method: `GET` と `POST` の両対応を想定
- Path: `meta/dm`
- Public URL: `https://<cloudflare-domain>/webhook/meta/dm`

### Normalize Output

`Code` ノードでは、Instagram / Facebook の差分を吸収して最低限この形にそろえる。

```json
{
  "platform": "instagram",
  "channel": "dm",
  "dm_thread_id": "thread-or-psid",
  "sender_id": "meta-user-id",
  "sender_name": "display name",
  "message_text": "こんにちは",
  "message_id": "mid.xxx",
  "received_at": "2026-06-16T13:00:00.000Z",
  "raw_payload": {}
}
```

### Filter Rules

- echo message は除外
- 自分自身が送った message は除外
- text が空のイベントは除外
- attachment-only の場合は別ルートへ送るか保留

## 2. wf_dm_auto_reply

受信 DM を保存し、会話履歴を踏まえて OpenAI で返信文を作り、Meta に返す本体。

### Recommended n8n Node Flow

1. `Execute Workflow Trigger`
2. `Postgres`: lead upsert
3. `Postgres`: incoming message insert
4. `Postgres`: recent conversation load
5. `Code`: conversation formatter
6. `Set`: prompt input build
7. `OpenAI Chat Model`
8. `Code` or `Set`: reply sanitizer
9. `If`: auto-reply allowed?
10. `HTTP Request`: Meta Messaging API reply
11. `Postgres`: outgoing message insert
12. `If`: high-intent lead?
13. `Execute Workflow`: `wf_high_intent_notify`

### Postgres Queries

#### lead upsert

```sql
INSERT INTO leads (
  platform,
  dm_thread_id,
  customer_name,
  customer_handle,
  last_message_at
)
VALUES (
  $1, $2, $3, $4, $5
)
ON CONFLICT (dm_thread_id)
DO UPDATE SET
  customer_name = COALESCE(EXCLUDED.customer_name, leads.customer_name),
  customer_handle = COALESCE(EXCLUDED.customer_handle, leads.customer_handle),
  last_message_at = EXCLUDED.last_message_at,
  updated_at = NOW()
RETURNING id, platform, dm_thread_id, customer_name, customer_handle, status;
```

#### incoming message insert

```sql
INSERT INTO conversations (
  lead_id,
  role,
  message_text,
  meta_json,
  sent_at
)
VALUES (
  $1,
  'customer',
  $2,
  $3::jsonb,
  $4
);
```

#### recent conversation load

```sql
SELECT role, message_text, sent_at
FROM conversations
WHERE lead_id = $1
ORDER BY sent_at DESC
LIMIT 12;
```

### OpenAI Inputs

- system prompt: [system.md](D:/IRAM%20SEKELLI/Documents/fb-auto-sales-n8n/prompts/system.md:1)
- reply prompt template: [sales-reply.md](D:/IRAM%20SEKELLI/Documents/fb-auto-sales-n8n/prompts/sales-reply.md:1)
- latest conversation history from `conversations`
- lead summary from `leads`

### Prompt Build Example

`Set` ノードで次の 2 変数を作ると扱いやすい。

- `conversation_history`
- `lead_profile`

`conversation_history` 例:

```text
customer: 料金感ってどれくらいですか？
assistant: 内容次第ですが、まずは状況を少し伺えれば概算の方向感はお伝えできます。
customer: Instagramの問い合わせ対応を自動化したいです。
```

`lead_profile` 例:

```text
platform: instagram
name: 山田様
status: new
interest_summary: DM自動化に関心あり
```

### Auto-Reply Guard

`If` ノードで次のどれかに当てはまる場合は自動送信せず停止する。

- 深夜帯での送信を避けたい
- `message_text` が短すぎて文脈不足
- 個人情報やクレーム系の文脈
- 商談価格や契約条件の断定が必要

### Meta Reply Request

`HTTP Request` ノードでは Meta Graph API に返信する。

- Method: `POST`
- URL: `https://graph.facebook.com/v23.0/<PAGE_OR_IG_BUSINESS_ID>/messages`
- Auth: Bearer token
- Body: recipient / messaging_type / message

最低限の body イメージ:

```json
{
  "recipient": {
    "id": "{{$json.sender_id}}"
  },
  "messaging_type": "RESPONSE",
  "message": {
    "text": "{{$json.reply_text}}"
  }
}
```

## 3. wf_high_intent_notify

商談化温度が高い DM を営業側に通知する補助ワークフロー。

### Recommended n8n Node Flow

1. `Execute Workflow Trigger`
2. `If`: high-intent score threshold
3. `Slack` or `Gmail`
4. `Postgres`: lead_notifications insert

### High-Intent Examples

- 料金を聞いている
- 導入時期を聞いている
- 無料相談や打ち合わせに前向き
- 具体的な業務課題を話している

## Data To Extract From Webhook

- `platform`
- `dm_thread_id`
- `sender_id`
- `sender_name`
- `message_id`
- `message_text`
- `received_at`
- `raw_payload`

## Recommended Credentials

- Meta Page Access Token
- OpenAI API Key
- PostgreSQL connection
- Slack または Gmail

## Rollout Plan

1. まずは `Webhook -> normalize -> DB保存` まで作る
2. 次に `OpenAI` で返信文だけ生成して送信はしない
3. 問題なければ一部条件で自動返信を有効化する
4. 最後に高温度リード通知を足す

## Notes

- 最初は返信自動送信ではなく、n8n 内で承認待ち分岐を入れてもよい
- Meta 署名検証が必要なら Webhook 直後に `Code` ノードで検証する
- 送信失敗時は `lead_notifications` に保存して再送対象にする
- `WEBHOOK_URL` は Cloudflare Tunnel の公開 URL に合わせる
