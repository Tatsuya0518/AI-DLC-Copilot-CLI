# AI-DLC-Copilot-CLI

> このドキュメントは**実装計画および開発規約**を記載したものです。
> 記載されている機能やディレクトリ構造は実装予定のものであり、現在はまだ存在しない場合があります。

## プロジェクト概要

Open-Meteo APIを使った天気取得CLIツール。
GitHub Copilot CLIとIssue駆動開発（AI-DLC）を体験するためのデモ用リポジトリ。
「要件 → 設計 → Issue → テスト → 実装」のサイクルをCopilot CLIで回すことが目的。

## 技術スタック

- Python 3.12+
- uv（パッケージ管理・実行）
- click 8.1+（CLIフレームワーク）
- httpx 0.27+（HTTP通信）
- rich 13.0+（ターミナル出力）
- pytest + pytest-httpx（テスト）

## 実装予定のディレクトリ構造

- `src/weather/` - メインロジック
  - `cli.py` - CLIエントリポイント（clickのみ）
  - `api.py` - 外部API呼び出し（fetch_location / fetch_weather）
  - `formatter.py` - rich出力フォーマット
  - `exceptions.py` - カスタム例外クラス
- `tests/` - pytestテスト群
- `docs/` - requirements.md / design.md / tasks.md
- `scripts/` - ローカル自動テストスクリプト
- `.github/workflows/` - CI設定

## 開発フロー

タスクはdocs/tasks.mdおよびGitHub Issueで管理する。
実装順序: 例外定義 → API → フォーマッター → CLI → エラーハンドリング

## コーディング規約（概要）

詳細は `.github/instructions/` 配下の各ファイルを参照。

**基本方針:**
- 型ヒントを全ての関数に付ける
- docstringはGoogle形式で書く
- 外部API呼び出しはapi.pyに集約し、cli.pyには書かない
- 例外は握り潰さずraiseする（WeatherCliErrorの派生クラスを使う）

**Python規約の詳細**: `.github/instructions/python.instructions.md`
**テスト規約の詳細**: `.github/instructions/tests.instructions.md`
**ドキュメント規約の詳細**: `.github/instructions/docs.instructions.md`

## 実装後に使用可能になるコマンド

以下のコマンドは実装完了後に使用可能になります。

```bash
uv sync                                                   # 依存関係インストール
uv run weather <都市名>                                    # CLI実行
uv run pytest tests/ -v | copilot -p "テストの成否を判断して、失敗している場合は原因と修正案を教えて"  # テスト実行
bash scripts/watch_and_test.sh                            # ファイル監視＋自動テスト（macOS/WSL）
gh workflow run ci.yml                                    # CI手動トリガー
gh run view [id] --log-failed | copilot -p "このエラーを説明して修正案を出して"  # 失敗ログ解析
```

## 対応環境

- macOS（Apple Silicon / Intel）
- Windows WSL2（Ubuntu 22.04+）
