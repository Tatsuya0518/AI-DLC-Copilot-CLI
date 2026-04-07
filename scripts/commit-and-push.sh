#!/bin/bash
# Commit and Push スクリプト
# Usage: bash scripts/commit-and-push.sh "commit message"

set -e

if [ -z "$1" ]; then
    echo "Error: コミットメッセージを指定してください"
    echo "Usage: bash scripts/commit-and-push.sh \"commit message\""
    exit 1
fi

COMMIT_MESSAGE="$1"

echo "📝 変更をステージング..."
git add -A

echo "📊 変更内容を確認..."
git status --short

echo ""
echo "💾 コミット中..."
git commit -m "$COMMIT_MESSAGE

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"

echo "🚀 リモートにプッシュ中..."
git push

echo "✅ 完了しました！"
