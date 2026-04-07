---
name: commit-push
description: git commitとgit pushを実行するスキル
license: Apache-2.0
compatibility: gitがシステムにインストールされ、設定されている必要があります。
metadata:
  author: org
  version: "1.0"
  tags: [git, version control, commit, push]
  description: このスキルは、gitリポジトリへの変更をコミットし、リモートサーバーにプッシュするプロセスを自動化します。シンプルなインターフェースでgitのコミットとプッシュを管理し、開発者のワークフローを効率化することを目的としています。
  usage: |
    1. gitがシステムにインストールされ、設定されていることを確認してください。
    2. このスキルを使用して変更をステージし、コミットメッセージを作成し、リモートリポジトリにプッシュします。
    3. スキルがプロセスをガイドし、コミットとプッシュの前に変更内容を確認できます。
    4. **コミットメッセージには必ずタイトルと実施内容の要約を含めてください**:
       - 1行目: 簡潔なタイトル（50文字以内推奨）
       - 2行目: 空行
       - 3行目以降: 変更内容の詳細説明（何を、なぜ変更したか）
  examples: |
    - 例1: mainブランチへの変更をコミット・プッシュ
      1. 変更をステージ: `git add .`
      2. コミットメッセージを作成:
         ```
         新機能Xを追加

         - ユーザー認証機能を実装
         - ログイン画面のUI改善
         - セッション管理ロジックを追加
         ```
      3. リモートにプッシュ: `git push origin main`
    - 例2: フィーチャーブランチへの変更をコミット・プッシュ
      1. 変更をステージ: `git add .`
      2. コミットメッセージを作成:
         ```
         バグYを修正

         - NullPointerExceptionの原因を特定し修正
         - エラーハンドリングを強化
         - 該当箇所のユニットテストを追加
         ```
      3. リモートにプッシュ: `git push origin feature-branch`
  references: |
    - [Git ドキュメント](https://git-scm.com/doc)
    - [GitHub ガイド](https://guides.github.com/introduction/git-handbook/)
    - [コミットメッセージの書き方](https://www.conventionalcommits.org/ja/)
---