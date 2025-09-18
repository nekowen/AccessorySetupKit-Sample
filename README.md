# AccessorySetupKit-Sample

## 概要
- Apple が提供する AccessorySetupKit API を使って BLE 周辺機器をペアリングするサンプルアプリです。
- M5Stack を BLE HID キーボードとして動かす Arduino スケッチも収録しており、開発中でも手軽に周辺機器をエミュレートできます。

## プロジェクト構成
- `AccessorySetupKitSample/` : Xcode プロジェクト。アクセサリの移行を試すときは、`AccessorySetupKitViewModel.swift` のダミー UUID を差し替えてください。Bluetooth を有効にした iOS 実機でのみ動作します。
- `M5_BLE_Keyboard/` : M5StickC Plus 向け Arduino スケッチ。サンプルアプリからペアリングできる BLE キーボードとしてアドバタイズします。

## クイックスタート
1. `AccessorySetupKitSample/AccessorySetupKitSample.xcodeproj` を Xcode 15 以降で開きます。
2. シミュレータでは動作しないため、物理 iOS デバイスをターゲットに選んでビルド & 実行します。
3. M5StickC Plus（または任意の BLE 周辺機器）にスケッチを書き込み、電源を入れてスキャン・ペアリング・移行・削除の各フローを試します。

