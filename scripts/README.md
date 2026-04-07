# スクリプト集

このディレクトリには、開発を効率化するための各種スクリプトが含まれています。

## commit-and-push.sh

変更のステージング、コミット、プッシュを一括で実行します。

### 使用方法

```bash
bash scripts/commit-and-push.sh "コミットメッセージ"
```

### 例

```bash
bash scripts/commit-and-push.sh "feat: 新機能を追加"
bash scripts/commit-and-push.sh "fix: バグ修正"
bash scripts/commit-and-push.sh "docs: ドキュメント更新"
```

### 動作

1. すべての変更をステージング (`git add -A`)
2. 変更内容を表示 (`git status --short`)
3. コミット（Co-authored-by トレーラー自動付与）
4. リモートにプッシュ (`git push`)

### 注意事項

- コミットメッセージは必須です
- すべての変更が自動的にステージングされます
- Co-authored-by トレーラーが自動的に追加されます
