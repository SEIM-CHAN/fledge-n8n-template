# Facebook / Instagram DM MVP Workflow

## Goal

Facebook / Instagram の問い合わせDMを受け取り、会話を保存し、AIで一次返信案を作る。

## Recommended n8n Node Flow

1. `Webhook`
2. `Code` or `Set`
3. `Postgres`: lead upsert
4. `Postgres`: incoming message insert
5. `Postgres`: recent conversation load
6. `OpenAI Chat Model`
7. `HTTP Request`: Meta Messaging API reply
8. `Postgres`: outgoing message insert
9. `If`: high-intent lead detection
10. `Slack` or `Gmail`: notify sales owner

## Data To Extract From Webhook

- `platform`
- `dm_thread_id`
- `sender_id`
- `sender_name`
- `message_text`
- `received_at`

## OpenAI Inputs

- system prompt: `prompts/system.md`
- reply prompt template: `prompts/sales-reply.md`
- latest conversation history from `conversations`
- lead summary from `leads`

## High-Intent Examples

- 料金を聞いている
- 導入時期を聞いている
- 無料相談や打ち合わせに前向き
- 具体的な業務課題を話している

## Notes

- 最初は返信自動送信ではなく、n8n内で承認待ち分岐を入れてもよい
- Meta署名検証が必要ならWebhook直後に `Code` ノードで検証する
- 送信失敗時は `lead_notifications` に保存して再送対象にする
