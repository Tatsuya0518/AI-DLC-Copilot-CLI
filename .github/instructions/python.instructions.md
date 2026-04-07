---
applyTo: "src/**/*.py"
---

# Python コーディング規約

- Python 3.12+の機能を積極的に使う
- dataclassを使う（Pydanticは使わない）
- 型ヒントは必須（引数・戻り値すべてに付ける）
- docstringはGoogle形式で書く
- f-stringを使う
- pathlib.Pathを使う（os.pathは使わない）
- 例外はWeatherCliError派生クラスをraiseする
- 外部API呼び出しはhttpxを使い、api.pyに集約する