# 数独Webアプリ

PythonとFlaskを使用した数独ゲームのWebアプリケーションです。

## 機能

- 数独パズルの表示と操作
- パズル生成機能
- ソルバー機能
- レスポンシブデザイン

## セットアップ

### 仮想環境の作成と依存関係のインストール

```bash
cd sudoku_webapp
uv sync
```

### アプリケーションの実行

```bash
uv run python app.py
```

ブラウザで `http://localhost:5000` にアクセスしてください。

## 開発

### コードフォーマット

```bash
uv run black .
```

### リント

```bash
uv run flake8 .
```

### テスト

```bash
uv run pytest
```
