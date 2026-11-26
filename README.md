# Zip Formula iRacing Dash Phone

SimHub向けZip Formula iRacingダッシュボードです。

## インストール

1. GitHub Releasesから `ZipFormula-SimHub-Setup.exe` をダウンロードします。
2. SimHubを終了し、EXEを実行します。
3. インストール完了後にSimHubを起動します。
4. Dash Studioの **Import Dashboard** から、ドキュメントの `Zip Formula/SimHub Dashboard` にある `.simhubdash` ファイルをインポートします。

インストーラーはSimHubのインストール先を検出し、PostItNoteRacingのDLLとJavaScript拡張を配置します。既存の同名プラグインファイルがあれば、初回インストール時のファイルをバックアップし、アンインストール時に復元します。

## 開発者向けビルド

- ダッシュボードファイル（`.simhubdash`）を `dashboard/` に1つ配置します。
- `v*.*.*` 形式のタグをpushすると、GitHub ActionsがEXEをビルドしGitHub Releaseに添付します。
- Actionsの **Build Zip Formula SimHub Installer** を手動実行すると、ビルド成果物をActions artifactとして取得できます。

## 同梱プラグイン

- PostItNoteRacing v1.0.7.8
- https://github.com/derrickmoeller/PostItNoteRacing

PostItNoteRacingのMITライセンスはインストーラーに同梱します。Zip Formulaのライセンスはリポジトリ直下の `LICENSE` を参照してください。
