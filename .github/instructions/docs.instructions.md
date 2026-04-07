---
applyTo: "docs/**/*.md"
---

# ドキュメント規約

## 実装予定のドキュメント構造

プロジェクトが進行すると、以下のドキュメントを作成します：

- `docs/requirements.md` → 要件のみ記載（設計観点を含めない）
- `docs/design.md` → 設計のみ記載（要件の繰り返しをしない）
- `docs/tasks.md` → GitHub Issueと1対1で対応させる

## ドキュメント作成時のルール

- 変更時はrequirements → design → tasksの順で整合性を確認する
- 各ドキュメントは役割を明確に分離し、重複を避ける