# Dashboard package

このフォルダには、バージョン番号を含むファイル名でSimHubダッシュボードを1つ配置します。

命名規則：

`ZipFormula-RacingDash_<major>.<minor>.<patch>.simhubdash`

例：`ZipFormula-RacingDash_0.1.0.simhubdash`

GitHub Actionsはファイル名からバージョンを抽出し、インストーラーの製品バージョンに設定します。タグからビルドする場合は、Gitタグ（例：`v0.1.0`）とファイル名のバージョンが一致している必要があります。

ビルド時には、ファイルを `build/dashboard/ZipFormula-RacingDash.simhubdash` という固定名にコピーしてからインストーラーへ格納します。リポジトリ内の元ファイル名は変更しません。
