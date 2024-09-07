# CryptoCodable

`CryptoCodable`は、Appleの`swift-crypto`を使用してJSONエンコード時にAES-GCMでプロパティを暗号化するためのSwiftライブラリです。このライブラリは、`Sendable`対応であると同時に、`Codable`、`Hashable`にも準拠したプロパティを保護し、復号もシンプルに行えるように設計されています。

## 特徴
- AES-GCMでJSONプロパティを暗号化・復号
- 暗号化対象のプロパティは`Sendable`、`Codable`、および`Hashable`に準拠
- 暗号化対象プロパティは`Optional`型である必要がある

## インストール

このライブラリはSwift Package Managerを使用してインストールできます。

```swift
let package = Package(
    ...
    dependencies: [
        ...
        .package(url: "https://github.com/lemo-nade-room/swift-crypto-codable.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "YourApp",
            dependencies: [
                .product(name: "CryptoCodable", package: "crypto-codable"),
            ]
        ),
        ...
    ]
    ...
)
```

## ドキュメンテーション

[DocCによるAPIドキュメント](https://lemo-nade-room.github.io/swift-crypto-codable/documentation/cryptocodable)があります

## 使用方法

### 1. CryptoFieldプロパティラッパーを使った型を定義

まず、暗号化対象のプロパティを持つ`Codable`な型を定義します。

```swift
import CryptoCodable
import Foundation

struct Event: Hashable, Codable, Sendable {
    var id: UUID
    @CryptoField var 個人情報: Self.個人情報?
    struct 個人情報: Hashable, Codable, Sendable {
        var 氏名: String
        var 誕生日: Date
        var 年齢: Int
    }
}
```

### 2. 暗号化

次に、暗号鍵を設定して暗号化を行います。暗号鍵が設定されていない場合、`fatalError`が発生します。

```swift
import CryptoCodable
import Foundation

let jsonData: Data = CryptoConfigContainer.$key.withValue(.init(size: .bits256)) {
    JSONEncoder().encode(event)
}
```

### 3. 復号

暗号化されたデータを復号します。復号時にも暗号鍵を設定します。

```swift
import CryptoCodable
import Foundation

let event: Event = CryptoConfigContainer.$key.withValue(key) {
    JSONDecoder().decode(Event.self, from: encrypted)
}
```

## 暗号化可能なプロパティの条件
- プロパティの型は`Sendable`、`Codable`、`Hashable`に準拠している必要があります。
- プロパティは`Optional`型である必要があります。

## 暗号鍵が設定されていない場合
暗号鍵が設定されていない場合、プロパティには`nil`が設定されますが、デコード自体は成功します。

- 暗号鍵が異なる場合には、`DecryptAuthenticationFailure`エラーが発生します。

## ライセンス
このライブラリはMITライセンスで提供されています。詳細は[LICENSE](./LICENSE)ファイルをご覧ください。

なお、このプロジェクトは`apple/swift-crypto`に依存しています。`apple/swift-crypto`はApache 2.0ライセンスに基づいて提供されています。詳しくは[こちら](https://raw.githubusercontent.com/apple/swift-crypto/main/LICENSE.txt)をご確認ください。