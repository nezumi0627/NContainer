# NContainer 開発ガイド

## プロジェクトの目的

NContainer は LiveContainer を基盤にした独立 fork です。LiveContainer の GNU AGPL v3 を維持し、NContainer 固有のコードは可能な限り `LiveContainerSwiftUI/NContainer/` 配下に置きます。

## 開発の優先順位

SideStore 内蔵版を標準の開発・検証・配布対象にします。

- メイン成果物: `LiveContainer+SideStore.ipa`
- 補助成果物: `LiveContainer.ipa`
- 通常版は互換性確認用として残しますが、機能追加・動作確認・README の案内は SideStore 内蔵版を優先します。

## GitHub Actions

主 workflow は `.github/workflows/build-ipa.yml` です。

この workflow は Xcode 26.2 でアーカイブを作り、Xcode DerivedData キャッシュと浅い checkout を使って待ち時間を抑えます。`.github/build_github.sh` で SideStore 内蔵 IPA と通常版 IPAを生成し、`nightly` リリースへ上書き公開します。Actions Summary と公開 prerelease に、両方のリンク、NContainer用SideStoreソース、バージョン、サイズ、SHA-256 を出力します。

SideStore source URL:

```text
https://github.com/nezumi0627/NContainer/releases/download/nightly/ncontainer_source.json
```

ソースは `.github/generate_source.py` がビルド時に生成します。`nightly` リリースの固定URLを使うため、SideStore側で一度ソースを追加すれば、次回以降は更新を確認できます。

```text
Actions → Build NContainer IPA → Run workflow
```

署名情報や証明書をリポジトリへ追加しません。生成物は unsigned なので、SideStore 等のインストーラで署名して使用します。

## コード規約

- NContainer 固有の型・ファイル名には `NC` 接頭辞を使います。
- 既存 LiveContainer の挙動を変更する場合は、変更理由と upstream への影響をコミットまたは README に残します。
- Beta 機能は `NCBetaFeatures` の個別フラグで制御します。
- App Group、署名、entitlement が取得できない場合に `nil` を Foundation API へ渡さないようにします。
- 新しい依存関係や大規模な upstream 改変を追加する前に、既存機能で再利用できる実装を確認します。

## 検証

通常の確認は GitHub Actions の `Build NContainer IPA` を実行し、次を確認します。

1. Archive unsigned app が成功する。
2. Package IPA with embedded SideStore が成功する。
3. `LiveContainer+SideStore.ipa` が公開 Release asset にある。
4. Actions Summary にダウンロードリンクと SHA-256 がある。

Windows では Xcode の実機ビルドを行えないため、ローカルでは差分・plist・workflow の静的確認を行い、最終ビルドは Actions で確認します。

## 変更時の注意

`nezu-app` は別プロジェクトです。NContainer の変更を push しません。NContainer の remote は `ncontainer` を使用します。
