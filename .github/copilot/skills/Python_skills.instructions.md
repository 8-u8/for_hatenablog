---
name: Python-skills-agent
description: for_hatenablog内のPythonに関するルールを定めたファイルです。
applyTo: '**/*.py, **/*.ipynb'
---

## Pythonの利用目的とコーディング技術について

### Pythonの利用目的
- 私はPythonを、主にデータ分析や機械学習モデルの構築、数理最適化モデルの実装に使用します。
- Pythonコードを生成する際には、これらの利用目的に適したライブラリやフレームワークを活用してください。
  - データ分析には、Pandas、NumPy、Matplotlib、Seabornなどを使用します。
  - 機械学習には、Scikit-learn、TensorFlow、Keras、LightGBMなどを使用します。
    - 統計的なモデリングのために、Statsmodelsも使用します。
  - 数理最適化には、PuLP、SciPyのoptimizeモジュール、ORToolsなどを使用します。

#### 仮想環境について
- 私はPythonの仮想環境を使用して、プロジェクトごとに依存関係を管理します。
- Pythonコードを生成する際には、仮想環境でのパッケージ管理を考慮してください。
  - パッケージ管理には`uv`を用います。`uv`を通して`venv`を構築します。
  - 依存関係の管理には、`requirements.txt`を使用します。

### Pythonの技術レベルについて
#### 現在のスキルセット
- 私はPythonに関して中級程度の知識と実装スキルをもっています。
  - 基本的なPythonの文法を把握しています。
    - 例えばリスト、辞書などのデータ構造を把握しており、内包表記も使用できます。
    - 関数定義を理解しており、引数や戻り値の型アノテーションも使用できます。
  - データ分析や機械学習のライブラリを使用した経験があります。
    - Pandasを用いたデータの前処理や集計、可視化ができます。
    - Scikit-learn、Statsmodelsを用いた基本的な機械学習モデルの構築と評価ができます。
    - 数理最適化の基本的な概念を理解しており、PuLPやSciPyのoptimizeモジュールを使用した簡単な最適化問題の定式化と解法ができます。
- 一方で、Pythonの高度な機能や最適化手法についてはまだ学習中です。
  - クラスやオブジェクト指向プログラミングの理解は限定的です。
  - デコレータやジェネレータなどの高度なPython機能の使用経験は浅いです。
  - 大規模なプロジェクトでのPythonの設計パターンやベストプラクティスについても理解は限定的です。

#### コード生成に関する指示
- Copilotには、私の技術レベルに合わせたコード生成を行ってほしいです。
  - 基本的な文法やライブラリの使用方法については、明確でわかりやすいコードを生成してください。
  - 高度な機能を使った実装や、複雑なシステムのベストプラクティスについては、チャットやMarkdown形式での解説を提供してください。

## Pythonの基本文法について

### コーディングスタイル
- Pythonのコードを生成する際は、PEP 8のスタイルガイドに準拠したスタイルで書いてください。
- Pythonでの関数やクラスの命名には、PEP 8に従ってください。
  - 関数名や変数名は小文字の単語をアンダースコアでつなげた形式（snake_case）を使用してください。
  - クラス名は各単語の先頭を大文字にした形式（PascalCase）を使用してください。
  - 必ず型アノテーションを使用してください。型アノテーションのチェックには、`Ty`を使用することを想定してください。
    - https://docs.astral.sh/ty/type-checking/ を適宜参照してください
- Pythonのコードで関数やクラスを定義するときは、`'''`でドキュメンテーション文字列を使用し、関数やクラスの目的や引数、戻り値について簡潔に説明してください。

コードの例（適切）
```python
# LightGBMを用いた売上予測モデルの構築
import pandas as pd
import lightgbm as lgb
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error


def load_sales_data(path: str) -> pd.DataFrame:
  """売上予測用のデータを読み込む
  
  Args:
    path: CSVファイルのパス
    
  Returns:
    読み込んだデータフレーム
  """
  return pd.read_csv(path)


def split_features_target(
  data: pd.DataFrame,
  target_column: str = "sales"
) -> tuple[pd.DataFrame, pd.Series]:
  """特徴量と目的変数に分割
  
  Args:
    data: 入力データフレーム
    target_column: 目的変数のカラム名
    
  Returns:
    特徴量データフレームと目的変数シリーズのタプル
  """
  X: pd.DataFrame = data.drop(columns=[target_column])
  y: pd.Series = data[target_column]
  return X, y


def train_lightgbm_model(
  X_train: pd.DataFrame,
  y_train: pd.Series
) -> lgb.LGBMRegressor:
  """LightGBMモデルを学習
  
  Args:
    X_train: 学習用特徴量データ
    y_train: 学習用目的変数データ
    
  Returns:
    学習済みのLightGBMモデル
  """
  model: lgb.LGBMRegressor = lgb.LGBMRegressor(
    objective="regression",
    n_estimators=300,
    learning_rate=0.05,
    max_depth=6,
    random_state=42
  )
  model.fit(X_train, y_train)
  return model


def evaluate_model(
  model: lgb.LGBMRegressor,
  X_valid: pd.DataFrame,
  y_valid: pd.Series
) -> float:
  """MAEでモデル性能を評価
  
  Args:
    model: 学習済みモデル
    X_valid: 検証用特徴量データ
    y_valid: 検証用目的変数データ
    
  Returns:
    平均絶対誤差(MAE)
  """
  predictions: pd.Series = model.predict(X_valid)
  mae: float = mean_absolute_error(y_valid, predictions)
  return mae


def main() -> None:
  """メイン処理"""
  data: pd.DataFrame = load_sales_data("sales_data.csv")

  X: pd.DataFrame
  y: pd.Series
  X, y = split_features_target(data)

  X_train: pd.DataFrame
  X_valid: pd.DataFrame
  y_train: pd.Series
  y_valid: pd.Series
  X_train, X_valid, y_train, y_valid = train_test_split(
    X, y, test_size=0.2, random_state=42
  )

  model: lgb.LGBMRegressor = train_lightgbm_model(X_train, y_train)

  mae: float = evaluate_model(model, X_valid, y_valid)
  print(f"Validation MAE: {mae:.2f}")


if __name__ == "__main__":
  main()
```