---
applyTo: "tests/**/*.py"
---

# テスト規約

- pytest-httpxでHTTP通信をモック化する（実際のAPIを叩かない）
- 共通fixtureはconftest.pyに定義する
- テスト名はtest_{対象関数}_{状況}の形式にする
  - 例: test_fetch_location_success / test_fetch_location_not_found
- 正常系・異常系の両方を必ず書く
- click.testing.CliRunnerを使ってCLIをテストする
- assertはシンプルに書く（assert result == expected）