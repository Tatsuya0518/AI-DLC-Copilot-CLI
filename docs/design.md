# Design: weather-cli-copilot

> このドキュメントは設計観点のみを記載する。要件の詳細は requirements.md を参照。

---

## 1. アーキテクチャ概要

### レイヤー構成
3層アーキテクチャを採用し、関心の分離を徹底する。

```
┌─────────────────────────────────────┐
│      CLI層 (cli.py)                 │  ← ユーザー入力・エラー表示
│  - click による引数パース             │
│  - エラーハンドリング                 │
│  - ヘルプメッセージ                   │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  ビジネスロジック層 (api.py)         │  ← 外部API呼び出し
│  - Geocoding API 呼び出し            │
│  - Weather API 呼び出し              │
│  - dataclass へのマッピング          │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│    表示層 (formatter.py)             │  ← 整形・色付け・絵文字
│  - rich による整形                   │
│  - 天気状態に応じた絵文字選択         │
│  - 色付け・スタイリング               │
└─────────────────────────────────────┘
```

### 責務分離の原則
- **CLI層**: API呼び出しを含めない（api.pyに委譲）
- **API層**: 表示ロジックを含めない（dataclassのみ返す）
- **表示層**: ビジネスロジックを含めない（dataclassを受け取るだけ）

---

## 2. ディレクトリ構造

```
AI-DLC-Copilot-CLI/
├── src/
│   └── weather/
│       ├── __init__.py
│       ├── cli.py           # CLIエントリポイント（clickのみ）
│       ├── api.py           # Open-Meteo API呼び出し
│       ├── formatter.py     # rich による出力整形
│       └── exceptions.py    # カスタム例外クラス
├── tests/
│   ├── conftest.py          # 共通fixture（httpx mock設定）
│   ├── test_api.py          # API層のユニットテスト
│   ├── test_formatter.py    # 表示層のユニットテスト
│   └── test_cli.py          # CLI統合テスト（CliRunner使用）
├── scripts/
│   └── watch_and_test.sh    # ローカル自動テストスクリプト
├── .github/
│   ├── workflows/
│   │   └── ci.yml           # GitHub Actions CI設定
│   └── instructions/        # Copilot CLI用カスタムインストラクション
│       ├── python.instructions.md
│       ├── tests.instructions.md
│       └── docs.instructions.md
├── docs/
│   ├── requirements.md      # 要件定義
│   ├── design.md            # 本ドキュメント
│   └── tasks.md             # タスク一覧（GitHub Issueと対応）
├── pyproject.toml           # uv設定・依存関係
├── uv.lock
└── README.md
```

---

## 3. モジュール設計

### 3.1 dataclass設計

```python
# src/weather/api.py
from dataclasses import dataclass

@dataclass
class Location:
    """緯度経度情報"""
    name: str        # 都市名（APIが返した正式名称）
    latitude: float
    longitude: float

@dataclass
class Weather:
    """天気情報"""
    location: Location
    temperature: float      # 気温（℃）
    wind_speed: float       # 風速（km/h）
    weather_code: int       # WMO天気コード（0=快晴, 1-3=晴れ〜曇り, 45-48=霧, 51-99=雨雪など）
```

### 3.2 例外クラス設計

```python
# src/weather/exceptions.py

class WeatherCliError(Exception):
    """全例外の基底クラス"""
    def __init__(self, message: str) -> None:
        self.message = message
        super().__init__(message)

class LocationNotFoundError(WeatherCliError):
    """都市が見つからない"""
    pass

class ApiConnectionError(WeatherCliError):
    """ネットワークエラー・タイムアウト"""
    pass

class ApiResponseError(WeatherCliError):
    """APIレスポンスが不正"""
    pass
```

### 3.3 関数シグネチャ設計

#### api.py

```python
import httpx
from .exceptions import LocationNotFoundError, ApiConnectionError, ApiResponseError

def fetch_location(city_name: str, timeout: float = 10.0) -> Location:
    """
    Geocoding APIで都市の緯度経度を取得する
    
    Args:
        city_name: 都市名（日本語・英語）
        timeout: タイムアウト秒数
    
    Returns:
        Location: 緯度経度情報
    
    Raises:
        LocationNotFoundError: 都市が見つからない
        ApiConnectionError: ネットワークエラー
        ApiResponseError: APIレスポンスが不正
    """
    ...

def fetch_weather(location: Location, timeout: float = 10.0) -> Weather:
    """
    Weather APIで現在の天気を取得する
    
    Args:
        location: 緯度経度情報
        timeout: タイムアウト秒数
    
    Returns:
        Weather: 天気情報
    
    Raises:
        ApiConnectionError: ネットワークエラー
        ApiResponseError: APIレスポンスが不正
    """
    ...
```

#### formatter.py

```python
from rich.console import Console
from .api import Weather

def format_weather(weather: Weather) -> str:
    """
    天気情報を整形してrichテキストを生成する
    
    Args:
        weather: 天気情報
    
    Returns:
        str: rich markupを含む整形済みテキスト
    """
    ...

def get_weather_emoji(weather_code: int) -> str:
    """
    WMO天気コードに応じた絵文字を返す
    
    Args:
        weather_code: WMO天気コード
    
    Returns:
        str: 絵文字（☀️ 🌤️ ☁️ 🌧️ ⛈️ 🌨️ 🌫️ など）
    """
    ...

def print_weather(weather: Weather, console: Console | None = None) -> None:
    """
    天気情報をターミナルに出力する
    
    Args:
        weather: 天気情報
        console: rich Console（テスト用に注入可能）
    """
    ...
```

#### cli.py

```python
import click
from .api import fetch_location, fetch_weather
from .formatter import print_weather
from .exceptions import WeatherCliError

@click.command()
@click.argument("city")
@click.option("--timeout", default=10.0, help="API timeout in seconds")
def weather(city: str, timeout: float) -> None:
    """
    指定された都市の現在の天気を表示する
    
    CITY: 都市名（日本語・英語対応）
    
    例:
        weather Tokyo
        weather London
        weather 東京
    """
    try:
        location = fetch_location(city, timeout=timeout)
        weather_data = fetch_weather(location, timeout=timeout)
        print_weather(weather_data)
    except WeatherCliError as e:
        click.echo(f"[bold red]エラー:[/bold red] {e.message}", err=True)
        raise click.Abort()
```

---

## 4. データフロー

```
┌──────────────┐
│ ユーザー入力  │  $ uv run weather Tokyo
└──────┬───────┘
       ↓
┌──────────────────────────────────────┐
│ CLI層 (cli.py)                       │
│  - click.argument でパース            │
│  - try-except でエラーハンドリング     │
└──────┬───────────────────────────────┘
       ↓
┌──────────────────────────────────────┐
│ API層 (api.py)                       │
│  1. fetch_location("Tokyo")          │
│     → GET geocoding API              │
│     → Location(name="Tokyo",         │
│                lat=35.6895,          │
│                lon=139.6917)         │
│                                      │
│  2. fetch_weather(location)          │
│     → GET weather API                │
│     → Weather(location=...,          │
│               temperature=15.2,      │
│               wind_speed=12.5,       │
│               weather_code=2)        │
└──────┬───────────────────────────────┘
       ↓
┌──────────────────────────────────────┐
│ 表示層 (formatter.py)                │
│  - format_weather(weather)           │
│    → richマークアップ生成             │
│  - get_weather_emoji(2) → "🌤️"      │
│  - print_weather(weather)            │
│    → rich.Console で色付き出力       │
└──────┬───────────────────────────────┘
       ↓
┌──────────────┐
│ ターミナル出力│  🌤️ Tokyo: 15.2℃, 風速 12.5km/h
└──────────────┘
```

### エラーフロー

```
API呼び出し失敗
    ↓
例外raise (LocationNotFoundError / ApiConnectionError / ApiResponseError)
    ↓
CLI層でcatch (WeatherCliError)
    ↓
ユーザーフレンドリーなメッセージ表示
    ↓
click.Abort() でexit code 1
```

---

## 5. テスト設計

### 5.1 テストケース一覧

#### API層（test_api.py）

| ID | 関数 | テストケース | モック内容 | 期待結果 |
|----|------|-------------|-----------|---------|
| A1 | fetch_location | 正常系: Tokyo | geocoding APIが正常レスポンス | Location返却 |
| A2 | fetch_location | 正常系: London | geocoding APIが正常レスポンス | Location返却 |
| A3 | fetch_location | 異常系: 存在しない都市 | geocoding APIが空配列返却 | LocationNotFoundError |
| A4 | fetch_location | 異常系: ネットワークエラー | httpx.TimeoutException | ApiConnectionError |
| A5 | fetch_location | 異常系: APIレスポンス不正 | 不正なJSON | ApiResponseError |
| W1 | fetch_weather | 正常系: 東京の天気 | weather APIが正常レスポンス | Weather返却 |
| W2 | fetch_weather | 異常系: ネットワークエラー | httpx.TimeoutException | ApiConnectionError |
| W3 | fetch_weather | 異常系: APIレスポンス不正 | 不正なJSON | ApiResponseError |

#### 表示層（test_formatter.py）

| ID | 関数 | テストケース | 入力 | 期待結果 |
|----|------|-------------|------|---------|
| F1 | get_weather_emoji | 晴れ (code=0) | 0 | "☀️" |
| F2 | get_weather_emoji | 曇り (code=3) | 3 | "☁️" |
| F3 | get_weather_emoji | 雨 (code=61) | 61 | "🌧️" |
| F4 | format_weather | 正常データ | Weather(...) | richマークアップ文字列 |
| F5 | print_weather | 正常出力 | Weather(...) | rich.Console出力確認 |

#### CLI統合テスト（test_cli.py）

| ID | テストケース | モック内容 | 期待結果 |
|----|-------------|-----------|---------|
| C1 | 正常系: weather Tokyo | API正常レスポンス | exit code 0, 出力あり |
| C2 | 異常系: 存在しない都市 | LocationNotFoundError | exit code 1, エラーメッセージ |
| C3 | 異常系: ネットワークエラー | ApiConnectionError | exit code 1, エラーメッセージ |
| C4 | --help オプション | - | exit code 0, ヘルプ表示 |

### 5.2 テストフレームワーク・ツール

- **pytest**: テストランナー
- **pytest-httpx**: HTTP通信のモック化（実際のAPIを叩かない）
- **click.testing.CliRunner**: CLIテスト用ランナー
- **conftest.py**: 共通fixture（httpx mockの設定、再利用可能なテストデータ）

### 5.3 テスト実行コマンド

```bash
# 全テスト実行
uv run pytest tests/ -v

# 特定ファイルのみ
uv run pytest tests/test_api.py -v

# カバレッジ付き実行
uv run pytest tests/ --cov=src/weather --cov-report=html
```

---

## 6. CI設計（GitHub Actions）

### 6.1 CI設定ファイル

**ファイルパス**: `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:  # 手動トリガー対応

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.12"]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Install uv
        uses: astral-sh/setup-uv@v4
        with:
          enable-cache: true
      
      - name: Set up Python
        run: uv python install ${{ matrix.python-version }}
      
      - name: Install dependencies
        run: uv sync
      
      - name: Run tests
        run: uv run pytest tests/ -v
      
      - name: Run tests with coverage
        run: uv run pytest tests/ --cov=src/weather --cov-report=term
```

### 6.2 CI失敗時のログ解析フロー

```bash
# 1. 失敗したワークフローのIDを確認
gh run list --limit 5

# 2. 失敗ログを取得してCopilot CLIに投げる
gh run view [run-id] --log-failed | copilot -p "このエラーを説明して修正案を出して"

# 例:
# gh run view 123456789 --log-failed | copilot -p "このエラーを説明して修正案を出して"
```

---

## 7. ローカル自動テスト設計

### 7.1 概要

ソースコード変更を検知して自動的にpytestを実行し、結果をCopilot CLIにパイプして成否判定・修正案提示を行う。

### 7.2 監視対象

- `src/**/*.py`
- `tests/**/*.py`

### 7.3 自動テストスクリプト

**ファイルパス**: `scripts/watch_and_test.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# 環境判定
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  if ! command -v fswatch &> /dev/null; then
    echo "fswatch が見つかりません。インストールしてください: brew install fswatch"
    exit 1
  fi
  WATCH_CMD="fswatch -o src/ tests/"
elif [[ -f /proc/version ]] && grep -qi microsoft /proc/version; then
  # WSL
  if ! command -v inotifywait &> /dev/null; then
    echo "inotify-tools が見つかりません。インストールしてください: sudo apt install inotify-tools"
    exit 1
  fi
  WATCH_CMD="inotifywait -e modify,create,delete -m -r src/ tests/"
else
  echo "対応していない環境です（macOS または WSL2 のみ対応）"
  exit 1
fi

echo "📦 ファイル監視を開始します（src/, tests/）..."
echo "🔄 変更を検知すると自動的にpytestを実行し、Copilot CLIで解析します"
echo "終了: Ctrl+C"
echo ""

# 初回実行
uv run pytest tests/ -v | copilot -p "テストの成否を判断して、失敗している場合は原因と修正案を教えて"

# 監視ループ
$WATCH_CMD | while read -r _; do
  echo ""
  echo "🔄 変更を検知しました。pytestを実行します..."
  sleep 1  # 連続変更のデバウンス
  uv run pytest tests/ -v | copilot -p "テストの成否を判断して、失敗している場合は原因と修正案を教えて"
done
```

### 7.4 使用方法

```bash
# 実行権限付与（初回のみ）
chmod +x scripts/watch_and_test.sh

# 監視開始
bash scripts/watch_and_test.sh
```

### 7.5 Copilot CLI統合の動作フロー

```
ソースコード変更
    ↓
fswatch/inotifywait が検知
    ↓
pytest実行（`uv run pytest tests/ -v`）
    ↓
結果をパイプ → copilot -p "テストの成否を判断して、失敗している場合は原因と修正案を教えて"
    ↓
【成功時】Copilot: "全てのテストがパスしました ✅"
【失敗時】Copilot: "テストが失敗しました。原因は... 修正案: ..."
    ↓
開発者が修正案を参考にコード修正
    ↓
（ループ）自動再実行
```

### 7.6 Copilot CLIプロンプト設計

#### テスト結果解析用プロンプト

```
テストの成否を判断して、失敗している場合は原因と修正案を教えて
```

#### CI失敗ログ解析用プロンプト

```
このエラーを説明して修正案を出して
```

---

## 8. 実装順序

以下の順序で実装することで、依存関係を保ちながら段階的に機能を完成させる：

1. **例外クラス定義** (`exceptions.py`)
2. **API層** (`api.py`) - dataclass + 関数実装
3. **API層テスト** (`test_api.py`) - pytest-httpxでモック化
4. **表示層** (`formatter.py`) - rich による整形
5. **表示層テスト** (`test_formatter.py`)
6. **CLI層** (`cli.py`) - click によるエントリポイント
7. **CLI統合テスト** (`test_cli.py`)
8. **エラーハンドリング強化** - 全層でWeatherCliError派生クラスを使用
9. **CI設定** (`.github/workflows/ci.yml`)
10. **ローカル自動テストスクリプト** (`scripts/watch_and_test.sh`)

---

## 9. 外部API仕様

### Open-Meteo API

#### Geocoding API
- **URL**: `https://geocoding-api.open-meteo.com/v1/search`
- **パラメータ**: `?name={city_name}&count=1&language=en&format=json`
- **レスポンス例**:
  ```json
  {
    "results": [
      {
        "name": "Tokyo",
        "latitude": 35.6895,
        "longitude": 139.6917
      }
    ]
  }
  ```

#### Weather API
- **URL**: `https://api.open-meteo.com/v1/forecast`
- **パラメータ**: `?latitude={lat}&longitude={lon}&current_weather=true`
- **レスポンス例**:
  ```json
  {
    "current_weather": {
      "temperature": 15.2,
      "windspeed": 12.5,
      "weathercode": 2
    }
  }
  ```

### WMO天気コード（抜粋）
- `0`: 快晴 ☀️
- `1-3`: 晴れ〜曇り 🌤️ ☁️
- `45-48`: 霧 🌫️
- `51-67`: 雨 🌧️
- `71-77`: 雪 🌨️
- `80-99`: 雷雨・豪雨 ⛈️

---

## 10. パッケージ依存関係（pyproject.toml）

```toml
[project]
name = "weather-cli-copilot"
version = "0.1.0"
description = "天気取得CLI（AI-DLC Copilot CLI デモ）"
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

---

## 11. 開発者向けコマンド一覧

```bash
# 依存関係インストール
uv sync

# CLI実行
uv run weather Tokyo

# テスト実行
uv run pytest tests/ -v

# Copilot CLIでテスト結果解析
uv run pytest tests/ -v | copilot -p "テストの成否を判断して、失敗している場合は原因と修正案を教えて"

# ローカル自動テスト
bash scripts/watch_and_test.sh

# CI手動トリガー
gh workflow run ci.yml

# CI失敗ログ解析
gh run view [id] --log-failed | copilot -p "このエラーを説明して修正案を出して"
```

---

## まとめ

本設計では以下を重視した：

1. **3層アーキテクチャ**による関心の分離
2. **dataclass**による型安全性
3. **pytest-httpx**による外部APIのモック化
4. **rich**による視覚的な出力
5. **WeatherCliError**階層によるユーザーフレンドリーなエラーハンドリング
6. **Copilot CLI統合**によるテスト自動解析・修正案提示
7. **Mac/WSL両対応**のローカル自動テスト

これにより、「要件 → 設計 → Issue → テスト → 実装」のサイクルを効率的に回せるデモ環境を実現する。
