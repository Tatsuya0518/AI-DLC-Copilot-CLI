# AI-DLC-Copilot-CLI

AI-DLC（AI-Driven Large-scale Coding）をGitHubのProjectとCopilot CLIで実践するデモリポジトリ

## プロジェクト概要

Open-Meteo APIを使った天気取得CLIツールの開発を通じて、GitHub Copilot CLIとIssue駆動開発（AI-DLC）を体験するためのデモプロジェクトです。

**目的**: 「要件定義 → 設計 → Issue作成 → テスト → 実装」のサイクルをCopilot CLIで回し、AI支援開発のベストプラクティスを学ぶ

## プロジェクトステータス

🚧 **現在は計画・設計段階です**

このリポジトリには実装計画とCopilot用の開発規約が含まれています。実装はこれから進めていく予定です。

## 計画中の技術スタック

- **言語**: Python 3.12+
- **パッケージ管理**: uv
- **CLI フレームワーク**: click 8.1+
- **HTTP クライアント**: httpx 0.27+
- **出力フォーマット**: rich 13.0+
- **テスト**: pytest + pytest-httpx

## 計画中のディレクトリ構造

```
AI-DLC-Copilot-CLI/
├── src/weather/          # メインロジック
│   ├── cli.py           # CLIエントリポイント
│   ├── api.py           # Open-Meteo API呼び出し
│   ├── formatter.py     # 出力フォーマット
│   └── exceptions.py    # カスタム例外
├── tests/               # テストコード
├── docs/                # ドキュメント
│   ├── requirements.md  # 要件定義
│   ├── design.md        # 設計書
│   └── tasks.md         # タスク管理
├── scripts/             # 開発支援スクリプト
└── .github/
    ├── workflows/       # CI/CD設定
    └── copilot-instructions.md  # Copilot開発規約
```

## 開発フロー

1. **要件定義** (`docs/requirements.md`) - 何を作るか
2. **設計** (`docs/design.md`) - どう作るか
3. **Issue作成** - GitHub Issuesでタスク管理
4. **テスト駆動開発** - テストを先に書く
5. **実装** - Copilot CLIで効率的に実装
6. **CI/CD** - 自動テスト・デプロイ

## 対応予定環境

- macOS（Apple Silicon / Intel）
- Windows WSL2（Ubuntu 22.04+）

## ドキュメント

- [`.github/copilot-instructions.md`](.github/copilot-instructions.md) - Copilot CLI用の開発規約とプロジェクト計画
- [`.github/instructions/`](.github/instructions/) - ファイル種別ごとの詳細規約

## ライセンス

MIT License (予定)
