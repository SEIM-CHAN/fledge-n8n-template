# Architecture

## 概要

Facebook / InstagramのDM問い合わせを起点に、n8nでAI営業フローを自動化する。

## MVP範囲

- DM受信
- 会話内容の保存
- AI返信生成
- リード情報の保存
- 商談化候補の通知

## 全体構成

```mermaid
flowchart TD
    A[Facebook / Instagram DM] --> B[Meta Webhook]
    B --> C[n8n]
    C --> D[OpenAI]
    C --> E[(PostgreSQL)]
    D --> F[返信生成]
    F --> G[Meta Messaging API]