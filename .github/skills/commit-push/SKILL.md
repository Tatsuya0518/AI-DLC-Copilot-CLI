---
name: commit-push
description: git commitとgit pushを実行するスキル
license: Apache-2.0
compatibility: Requires git to be installed and configured on the system.
metadata:
  author: org
  version: "1.0"
  tags: [git, version control, commit, push]
  description: This skill automates the process of committing changes to a git repository and pushing them to a remote server. It is designed to streamline the workflow for developers by providing a simple interface for managing git commits and pushes.
  usage: |
    1. Ensure you have git installed and configured on your system.
    2. Use the skill to stage changes, create a commit message, and push to the remote repository.
    3. The skill will guide you through the process, allowing you to review changes before committing and pushing.
  examples: |
    - Example 1: Committing and pushing changes to the main branch.
      1. Stage changes: `git add .`
      2. Create commit message: "Add new feature X"
      3. Push to remote: `git push origin main`
    - Example 2: Committing and pushing changes to a feature branch.
      1. Stage changes: `git add .`
      2. Create commit message: "Fix bug Y"
      3. Push to remote: `git push origin feature-branch`
  references: |
    - [Git Documentation](https://git-scm.com/doc)
    - [GitHub Guides](https://guides.github.com/introduction/git-handbook/) 
---