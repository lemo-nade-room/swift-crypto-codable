@preconcurrency import Crypto
import Foundation

/// 暗号鍵等の設定を保持するための名前空間
public struct CryptoConfigContainer: Sendable {
    /// CryptoFieldのエンコード/デコード時に使用する暗号鍵
    ///
    /// 暗号化・復号時に事前にセットする必要がある
    ///
    /// ```swift
    /// import Crypto
    /// import CryptoCodable
    /// import Foundation
    ///
    /// let key = SymmetricKey(size: .bits256)
    /// CryptoKeyContainer.$key.withValue(key) {
    ///   // エンコード
    ///   let encoder = JSONEncoder()
    ///   let encryptedJSONData = try encoder.encode(content)
    ///
    ///   // デコード
    ///   let decoder = JSONDecoder()
    ///   let decodedContent = try decoder.decode(Content.self, from: encryptedJSONData)
    /// }
    /// ```
    @TaskLocal public static var key: SymmetricKey?

    /// CryptoFieldのエンコード/デコード時に使用するJSONEncoder
    ///
    /// カスタマイズしたい場合のみ設定が必要
    @TaskLocal public static var encoder: JSONEncoder = .init()

    /// CryptoFieldのエンコード/デコード時に使用するJSONDecoder
    ///
    /// カスタマイズしたい場合のみ設定が必要
    @TaskLocal public static var decoder: JSONDecoder = .init()
}
