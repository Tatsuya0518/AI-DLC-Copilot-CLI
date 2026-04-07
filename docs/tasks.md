# Tasks: weather-cli-copilot

> このドキュメントは実装タスクを管理する。各タスクはGitHub Issueと1対1で対応する。

---

## タスク一覧

| ID | タスク | Issue | Status | 依存 |
|----|--------|-------|--------|------|
| T1 | 例外クラス定義 | #4 | Open | - |
| T2 | API層実装 | #5 | Open | T1 |
| T3 | API層テスト | #6 | Open | T2 |
| T4 | 表示層実装 | #7 | Open | T1 |
| T5 | 表示層テスト | #8 | Open | T4 |
| T6 | CLI層実装 | #9 | Open | T2, T4 |
| T7 | CLI統合テスト | #10 | Open | T6 |
| T8 | エラーハンドリング強化 | #11 | Open | T6 |
| T9 | CI設定 | #12 | Open | T3, T5, T7 |
| T10 | ローカル自動テストスクリプト | #13 | Open | T9 |

---

## T1: 例外クラス定義

**Issue**: #4  
**ファイル**: `src/weather/exceptions.py`

### 説明
全例外の基底クラス`WeatherCliError`と、派生クラス（`LocationNotFoundError`, `ApiConnectionError`, `ApiResponseError`）を定義する。

### 実装内容
- [ ] `WeatherCliError(Exception)` 基底クラス
  - `message: str` 属性
- [ ] `LocationNotFoundError(WeatherCliError)` - 都市が見つからない
- [ ] `ApiConnectionError(WeatherCliError)` - ネットワークエラー
- [ ] `ApiResponseError(WeatherCliError)` - APIレスポンス不正

### 受入条件
- [ ] 4つの例外クラスが定義されている
- [ ] 全例外に型ヒントとdocstringがある
- [ ] 例外メッセージが人間が読めるテキストである

### 依存関係
なし

---

## T2: API層実装

**Issue**: #5  
**ファイル**: `src/weather/api.py`

### 説明
Open-Meteo APIを使って、都市名から緯度経度を取得し（Geocoding API）、現在の天気を取得する（Weather API）機能を実装する。

### 実装内容
- [ ] `Location` dataclass（name, latitude, longitude）
- [ ] `Weather` dataclass（location, temperature, wind_speed, weather_code）
- [ ] `fetch_location(city_name: str, timeout: float) -> Location`
  - Geocoding API呼び出し
  - 都市が見つからない場合は`LocationNotFoundError`
  - ネットワークエラーは`ApiConnectionError`
  - レスポンス不正は`ApiResponseError`
- [ ] `fetch_weather(location: Location, timeout: float) -> Weather`
  - Weather API呼び出し
  - エラー時は適切な例外をraise

### 受入条件
- [ ] httpxを使ってAPIを呼び出している
- [ ] タイムアウト設定が可能
- [ ] 全関数に型ヒント・docstring（Google形式）がある
- [ ] 例外を握り潰さずraiseしている

### 依存関係
- T1（例外クラス定義）

---

## T3: API層テスト

**Issue**: #6  
**ファイル**: `tests/test_api.py`

### 説明
pytest-httpxでHTTP通信をモック化し、API層の正常系・異常系をテストする。

### 実装内容
- [ ] test_fetch_location_success (Tokyo, London)
- [ ] test_fetch_location_not_found (存在しない都市)
- [ ] test_fetch_location_network_error (タイムアウト)
- [ ] test_fetch_location_response_error (不正JSON)
- [ ] test_fetch_weather_success
- [ ] test_fetch_weather_network_error
- [ ] test_fetch_weather_response_error

### 受入条件
- [ ] pytest-httpxでHTTP通信をモック化している
- [ ] 実際のAPIを叩いていない
- [ ] 正常系・異常系の両方をカバーしている
- [ ] `pytest tests/test_api.py -v` が全て通る

### 依存関係
- T2（API層実装）

---

## T4: 表示層実装

**Issue**: #7  
**ファイル**: `src/weather/formatter.py`

### 説明
richライブラリを使って、天気情報を視覚的に整形して表示する機能を実装する。

### 実装内容
- [ ] `get_weather_emoji(weather_code: int) -> str`
  - WMO天気コードに応じた絵文字を返す
  - 0: ☀️, 1-3: 🌤️☁️, 45-48: 🌫️, 51-67: 🌧️, 71-77: 🌨️, 80-99: ⛈️
- [ ] `format_weather(weather: Weather) -> str`
  - richマークアップを含む整形済みテキストを生成
- [ ] `print_weather(weather: Weather, console: Console | None) -> None`
  - rich.Consoleで色付き出力

### 受入条件
- [ ] richライブラリを使用している
- [ ] 絵文字・色付けが適用されている
- [ ] 全関数に型ヒント・docstringがある
- [ ] consoleをテスト用に注入可能（デフォルト引数）

### 依存関係
- T1（例外クラス定義） - Weatherデータクラスが必要

---

## T5: 表示層テスト

**Issue**: #8  
**ファイル**: `tests/test_formatter.py`

### 説明
表示層の各関数をテストする。

### 実装内容
- [ ] test_get_weather_emoji_clear (code=0 → ☀️)
- [ ] test_get_weather_emoji_cloudy (code=3 → ☁️)
- [ ] test_get_weather_emoji_rain (code=61 → 🌧️)
- [ ] test_format_weather (正常データ → richマークアップ文字列)
- [ ] test_print_weather (Console注入でテスト)

### 受入条件
- [ ] 絵文字の対応が正しい
- [ ] format_weatherがrichマークアップを含む文字列を返す
- [ ] `pytest tests/test_formatter.py -v` が全て通る

### 依存関係
- T4（表示層実装）

---

## T6: CLI層実装

**Issue**: #9  
**ファイル**: `src/weather/cli.py`

### 説明
clickライブラリを使って、CLIエントリポイントを実装する。

### 実装内容
- [ ] `@click.command()`デコレータ
- [ ] `@click.argument("city")` で都市名を受け取る
- [ ] `@click.option("--timeout", default=10.0)` でタイムアウト設定
- [ ] try-exceptでWeatherCliErrorをキャッチ
- [ ] エラー時は人間が読めるメッセージを表示
- [ ] click.Abort()でexit code 1

### 受入条件
- [ ] `uv run weather Tokyo` で動作する
- [ ] `uv run weather --help` でヘルプが表示される
- [ ] 存在しない都市名でもスタックトレースが出ない
- [ ] エラーメッセージが日本語で親切

### 依存関係
- T2（API層実装）
- T4（表示層実装）

---

## T7: CLI統合テスト

**Issue**: #10  
**ファイル**: `tests/test_cli.py`

### 説明
click.testing.CliRunnerを使って、CLIの統合テストを行う。

### 実装内容
- [ ] test_cli_success (weather Tokyo → exit code 0)
- [ ] test_cli_not_found (存在しない都市 → exit code 1)
- [ ] test_cli_network_error (ネットワークエラー → exit code 1)
- [ ] test_cli_help (--help → ヘルプ表示)

### 受入条件
- [ ] CliRunnerを使用している
- [ ] API呼び出しをモック化している
- [ ] `pytest tests/test_cli.py -v` が全て通る

### 依存関係
- T6（CLI層実装）

---

## T8: エラーハンドリング強化

**Issue**: #11  
**ファイル**: 全層

### 説明
全層でWeatherCliError派生クラスを使用し、ユーザーフレンドリーなエラーメッセージを表示する。

### 実装内容
- [ ] API層: 全例外でWeatherCliError派生クラスをraise
- [ ] CLI層: WeatherCliErrorをキャッチして親切なメッセージ表示
- [ ] エラーメッセージの日本語化
- [ ] スタックトレースを表示しない

### 受入条件
- [ ] 存在しない都市名でスタックトレースが出ない
- [ ] ネットワークエラー時に「ネットワーク接続を確認してください」等のメッセージが出る
- [ ] 全テストが通る

### 依存関係
- T6（CLI層実装）

---

## T9: CI設定

**Issue**: #12  
**ファイル**: `.github/workflows/ci.yml`

### 説明
GitHub Actionsでテストを自動実行するCI設定を作成する。

### 実装内容
- [ ] Ubuntu latest環境
- [ ] Python 3.12
- [ ] uvインストール（astral-sh/setup-uv@v4）
- [ ] uv syncで依存関係インストール
- [ ] uv run pytest tests/ -v でテスト実行
- [ ] カバレッジ表示（--cov=src/weather）
- [ ] workflow_dispatch対応（手動トリガー）

### 受入条件
- [ ] `gh workflow run ci.yml` で手動トリガーできる
- [ ] テスト失敗時にGitHub Actions上でエラーが見える
- [ ] `gh run view [id] --log-failed` で失敗ログが取得できる

### 依存関係
- T3（API層テスト）
- T5（表示層テスト）
- T7（CLI統合テスト）

---

## T10: ローカル自動テストスクリプト

**Issue**: #13  
**ファイル**: `scripts/watch_and_test.sh`

### 説明
ソースコード変更を検知して自動的にpytestを実行し、結果をCopilot CLIにパイプして成否判定・修正案提示を行う。

### 実装内容
- [ ] Mac（fswatch）/WSL（inotifywait）の環境判定
- [ ] src/, tests/ の監視
- [ ] 変更検知時に`uv run pytest tests/ -v`を実行
- [ ] 結果を`copilot -p "テストの成否を判断して、失敗している場合は原因と修正案を教えて"`にパイプ
- [ ] 初回実行＋監視ループ
- [ ] デバウンス処理（連続変更対策）

### 受入条件
- [ ] macOSで動作する（fswatch）
- [ ] WSL2で動作する（inotifywait）
- [ ] ファイル変更時に自動的にpytestが実行される
- [ ] Copilot CLIが成否判定・修正案を提示する
- [ ] `bash scripts/watch_and_test.sh` で起動できる

### 依存関係
- T9（CI設定） - テストが全て完成している必要がある

---

## 進捗管理

### Phase 1: 基盤実装
- [ ] T1: 例外クラス定義
- [ ] T2: API層実装
- [ ] T3: API層テスト

### Phase 2: UI実装
- [ ] T4: 表示層実装
- [ ] T5: 表示層テスト

### Phase 3: CLI統合
- [ ] T6: CLI層実装
- [ ] T7: CLI統合テスト
- [ ] T8: エラーハンドリング強化

### Phase 4: 自動化
- [ ] T9: CI設定
- [ ] T10: ローカル自動テストスクリプト

---

## 補足情報

### pyproject.toml設定
プロジェクトルートに以下を作成する必要がある：
```toml
[project]
name = "weather-cli-copilot"
version = "0.1.0"
requires-python = ">=3.12"
dependencies = [
    "click>=8.1",
    "httpx>=0.27",
    "rich>=13.0",
]

[project.scripts]
weather = "weather.cli:weather"

[tool.uv]
dev-dependencies = [
    "pytest>=8.0",
    "pytest-httpx>=0.30",
    "pytest-cov>=4.1",
]
```

### src/weather/__init__.py
各モジュールをインポート可能にするため、`src/weather/__init__.py`を作成する。

### conftest.py
`tests/conftest.py`に共通fixtureを定義する（httpx mockの設定等）。

---

## GitHub Issue作成コマンド

```bash
# ラベル作成
gh label create "enhancement" --color 0E8A16 --description "新機能"
gh label create "test" --color 1D76DB --description "テスト"
gh label create "ci" --color 5319E7 --description "CI/CD"
gh label create "docs" --color 0075CA --description "ドキュメント"
gh label create "dependencies" --color D93F0B --description "依存関係"

# Issue作成（例: T1）
gh issue create \
  --title "[T1] 例外クラス定義" \
  --body "本文はtasks.mdのT1セクションを参照" \
  --label "enhancement"
```

Issue作成後、このドキュメントの`#TBD`をIssue番号に置換する。
