# Instagram DM Auto Reply

## Background

Instagram の DM 問い合わせに、営業時間中だけ一次返信を送り、会話履歴を残したい。

## Goal

Meta Webhook で受け取った Instagram DM を保存し、OpenAI で作成した短い返信案を送信する。
返信できない内容は人間の確認へ回す。

## Trigger

- Meta Webhook

## Inputs

- 送信者 ID
- メッセージ本文
- 受信日時
- メッセージ ID

## External Services

- Meta Graph API
- OpenAI
- PostgreSQL

## Data Storage

- `leads`: 送信者 ID と初回接触日時
- `conversations`: 受信メッセージ、返信内容、処理状態
- `lead_notifications`: 人手確認が必要な通知

## Expected Output

- `workflows/n8n/wf_instagram-dm-auto-reply.json`
- 必要な n8n Credentials と環境変数の一覧

## Constraints

- アクセストークンや API キーを JSON に保存しない
- 営業時間外は自動送信せず、翌営業時間に処理する
- 価格交渉、クレーム、個人情報を含む内容は人手確認へ回す
- 同じメッセージ ID への重複返信を防ぐ

## Definition of Done

- Meta Webhook を受け、署名検証後にメッセージを保存できる
- 安全な内容だけ返信を送信できる
- 人手確認が必要な内容を `lead_notifications` に記録できる
- n8n UI へ import できる JSON が生成されている
