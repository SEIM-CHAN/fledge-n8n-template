# n8n Workflows

このフォルダは、エージェントが生成した n8n ワークフロー JSON の保存先です。

## Rules

- 1 ワークフロー 1 JSON を基本にする
- ファイル名は小文字の kebab-case で `wf_<purpose>.json` とする
- 生成前に `docs/agent-requests/` の依頼書を確認する
- import 後に必要な credentials は別途 n8n 側で設定する

## Metadata

各 JSON の `meta` に、生成元と用途を残します。n8n の標準フィールドだけを使い、秘密値は含めません。

```json
{
  "meta": {
    "templateRequest": "docs/agent-requests/example-instagram-dm-auto-reply.md",
    "purpose": "instagram-dm-auto-reply",
    "version": "1.0.0"
  }
}
```

更新時は、内容に応じて `version` を上げ、`templateRequest` は元の依頼書を維持します。
