---
name: n8n-json-template
description: Create or update importable n8n workflow JSON files in this repository. Use when implementing an n8n workflow from a request in docs/agent-requests, modifying a generated workflow, or preparing a workflow for n8n import.
---

# n8n JSON Template

## Purpose

このリポジトリでエージェントが n8n ワークフローを作るときの共通ルールです。

## Required Behavior

1. 最初に対象の `docs/agent-requests/<request>.md` を確認し、依頼の完了条件を把握する
2. 次に `docs/architecture.md` と関連する `workflows/*.md` を確認して、既存設計と矛盾しないようにする
3. 生成物は原則 `workflows/n8n/wf_<purpose>.json` に保存する
4. 既存 JSON を更新する場合は、対象ファイルと変更理由を明示し、無関係なノードを変更しない
5. 秘密情報は JSON に直書きせず、n8n Credentials または環境変数参照に寄せる

## Output Rules

- n8n import 可能な JSON を出力する
- ファイル名は小文字の kebab-case を使い、`wf_<purpose>.json` とする。例: `wf_instagram-dm-auto-reply.json`
- ワークフロー名は役割が分かる日本語または英語にする。例: `Instagram DM Auto Reply`
- ノード名は役割を表す動詞から始め、同じ役割のノードには連番を付ける。例: `Receive Meta Webhook`, `Save Conversation`, `Send DM Reply`
- `Webhook`, `Set`, `Code`, `If`, `Postgres`, `HTTP Request`, `OpenAI` など標準ノード中心で組む
- `Code` ノードは必要最小限にし、複雑な分岐はコメントまたは docs で補足する
- 人手確認が必要な箇所は `If` や停止ノードを使って安全側に倒す
- JSON の `meta` には `templateRequest`, `purpose`, `version` を記録する。値は依頼書パス、用途、`1.0.0` 形式の版番号とする
- 実際の n8n 接続情報、credential ID、アクセストークンは export JSON に含めない

## Repository Conventions

- `docs/agent-requests/`: 人間の依頼書
- `workflows/`: 設計メモ
- `workflows/n8n/`: 生成済み JSON
- `prompts/`: LLM に渡す文章素材
- `local-files/`: ファイル入出力確認用

## Before Finishing

1. JSON の保存先が `workflows/n8n/` になっているか確認する
2. ファイル名・ワークフロー名・`meta.templateRequest` が対象の依頼書と対応しているか確認する
3. JSON が有効な JSON であり、n8n UI へ import できる構造か確認する
4. 依頼書に対して、どの JSON を追加・更新したかを明確にする
5. 必要なら import 手順や前提 credentials を README か docs に追記する
