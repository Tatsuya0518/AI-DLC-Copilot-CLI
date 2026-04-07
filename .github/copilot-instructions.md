# weather-cli-copilot

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

## ディレクトリ構造
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

## コーディング規約
- 型ヒントを全ての関数に付ける
- docstringはGoogle形式で書く
- 外部API呼び出しはapi.pyに集約し、cli.pyには書かない
- 例外は握り潰さずraiseする（WeatherCliErrorの派生クラスを使う）
- f-stringを使う（.format()や%は使わない）
- pathlib.Pathを使う（os.pathは使わない）

## テスト規約
- pytest-httpxでHTTP通信をモック化し、外部API依存をなくす
- 共通fixtureはtests/conftest.pyに定義する
- テストファイルはモジュールと1対1で対応させる

## 実行コマンド
```bash
uv sync                          # 依存関係インストール
uv run weather <都市名>           # CLI実行
uv run pytest tests/ -v          # テスト実行
bash scripts/watch_and_test.sh   # ファイル監視＋自動テスト（macOS/WSL）
gh workflow run ci.yml           # CI手動トリガー
gh run view [id] --log-failed | copilot explain  # 失敗ログ解析
```

## 対応環境
- macOS（Apple Silicon / Intel）
- Windows WSL2（Ubuntu 22.04+）
