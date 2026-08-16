# AGENTS Router

このファイルは、for_hatenablog で GitHub Copilot が参照するルーティングガイドです。

## 基本方針
- まず共通ルールとして `.github/copilot/instructions/Repository.instructions.md` を適用する。
- 作業対象のファイル種別・タスクに応じて、次の instruction / skill を追加適用する。
- 既存ルールを優先再利用し、重複ルールを増やさない。

## Instructions（自動適用の基本）
- 全体共通: `.github/copilot/instructions/Repository.instructions.md`
- Python: `.github/copilot/instructions/Python.instructions.md`
- R: `.github/copilot/instructions/R.instructions.md`

## Skills（タスク特化）
- 可視化タスク: `.github/copilot/skills/visualization/SKILL.md`
  - 対象: 図表作成、可視化レビュー、軸・凡例・注釈の改善
- 日本語ドキュメント作成: `.github/copilot/skills/japanese-tech-writing/SKILL.md`
  - 対象: 技術記事、解説文、推敲、論証の整理、冗長削減

## 推奨ルーティング
- `.py` / `.ipynb` の実装・修正
  - `Repository.instructions.md` + `Python.instructions.md`
  - 可視化を含む場合は `visualization/SKILL.md` を追加
- `.R` / `.Rmd` / `.Qmd` の実装・修正
  - `Repository.instructions.md` + `R.instructions.md`
  - 可視化を含む場合は `visualization/SKILL.md` を追加
- `.md` の執筆・推敲
  - `Repository.instructions.md` + `japanese-tech-writing/SKILL.md`

## セキュリティ最優先ルール
- APIキー、トークン、パスワード、個人情報、顧客識別情報を出力・コミットしない。
- rawデータや外部取得データは直接改変・公開しない。
- 未確認情報は断定せず、事実と推測を分離する。
- 破壊的変更（大量削除、強制上書き）は明示指示がある場合のみ実行する。
