# Requirements: weather-cli-copilot

## プロジェクト概要
GitHub Copilot CLIとIssue駆動開発（AI-DLC）を体験するためのデモ用プロジェクト。
Open-Meteo APIを使った天気取得CLIツールを題材に、
「要件 → 設計 → Issue → テスト → 実装」のサイクルをCopilot CLIで回す。

---

## ユーザーストーリー

### 天気取得
- As a ユーザー, I want to 都市名を入力するだけで現在の天気を取得したい,
  So that 外出前に素早く天気を確認できる
- As a ユーザー, I want to 気温・風速・天気状態をまとめて見たい,
  So that 複数の情報を一度に把握できる
- As a ユーザー, I want to 天気を絵文字や色で視覚的に確認したい,
  So that 数値だけでなく直感的に状況がわかる

### エラー対応
- As a ユーザー, I want to 存在しない都市名を入力したとき親切なメッセージが出てほしい,
  So that 何が間違っているかすぐわかる
- As a ユーザー, I want to ネットワークエラー時にもスタックトレースではなく
  わかりやすいメッセージが出てほしい,
  So that 慌てずに対処できる

### 開発体験（このリポジトリ固有）
- As a 開発者, I want to リポジトリをcloneして3コマンド以内で動かしたい,
  So that セットアップで詰まらずにすぐ試せる
- As a 開発者, I want to gh CLIからCIを手動トリガーしたい,
  So that ローカルを汚さずUbuntu環境でテストを確認できる
- As a 開発者, I want to CIが失敗したログをCopilot CLIに投げて原因を聞きたい,
  So that エラー解析をAIに任せて素早く修正できる

---

## 機能要件

- 都市名（日本語・英語）を引数に受け取り、現在の天気を表示する
- 表示項目：都市名・気温（℃）・風速（km/h）・天気状態（絵文字付き）
- 存在しない都市名・ネットワークエラー時に人間が読めるエラーメッセージを表示する
- `--help` オプションで使い方を表示する

---

## 非機能要件

- 対応環境：macOS（Apple Silicon / Intel）、Windows WSL2（Ubuntu 22.04+）
- レスポンス：通常のネットワーク環境で3秒以内に結果を表示する
- テスト（CI）：GitHub ActionsでUbuntu上のテストが自動実行される
- テスト（ローカル）：macOS上でCopilot CLIのカスタムSkillまたはCommandを自作し、
  ソースコード修正をトリガーにpytestが自動実行される
  ※詳細な自動化方法・トリガー設計はdesign.mdで定義する

---

## 制約条件

- APIキー不要（Open-Meteo APIを使用）
- パッケージ管理はuvのみ（pipやpoetryは使わない）
- 外部サービスへの依存はOpen-Meteo APIのみ

---

## やらないこと（スコープ外）

- 週間・時間別予報の表示
- 複数都市の一括取得
- 結果のファイル保存
- GUI・Web UI

---

## 受入条件

- [ ] `git clone` → `uv sync` → `uv run weather Tokyo` の3ステップで動く
- [ ] Mac・WSL2どちらの環境でも同じ手順で動く
- [ ] `gh workflow run ci.yml` でCIがUbuntu上で通る
- [ ] 存在しない都市名を渡してもスタックトレースが出ない
- [ ] `uv run pytest` がローカルでも通る