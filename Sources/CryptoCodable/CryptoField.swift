import Crypto
import Foundation

/// JSONエンコード時にAES-GCMで暗号化を行うプロパティラッパー
///
/// ## 使用方法
///
/// 1. CryptoFieldプロパティラッパーを使ったCodableな型を定義する
///
/// ```swift
/// import CryptoCodable
/// import Foundation
///
/// struct Event: Hashable, Codable, Sendable {
///   var id: UUID
///   @CryptoField var 個人情報: Self.個人情報?
///   struct 個人情報: Hashable, Codable, Sendable {
///       var 氏名: String
///       var 誕生日: Date
///       var 年齢: Int
///   }
/// }
/// ```
///
/// 2. 暗号鍵を設定し、暗号化する
///
/// 暗号鍵が設定されていない場合、fatalErrorが発生します
///
/// ```swift
/// import CryptoCodable
/// import Foundation
///
/// let jsonData: Data = CryptoConfigContainer.$key.withValue(.init(size: .bits256)) {
///  JSONEncoder().encode(event)
/// }
/// ```
///
/// 3. 復号する
///
/// ```swift
/// import CryptoCodable
/// import Foundation
///
/// let event: Event = CryptoConfigContainer.$key.withValue(key) {
///  JSONDecoder().decode(Event.self, from: encrypted)
/// }
/// ```
///
/// ## 暗号化可能なプロパティの条件
///
/// - プロパティの型はSendable, Codable, Hashbleに準拠している
/// - プロパティはOptional型である
///
/// ## 暗号鍵が設定されていない場合
///
/// 暗号鍵が存在しない場合、プロパティにnilが設定され、デコード自体は成功します。
///
/// - throws: `DecryptAuthenticationFailure` 暗号鍵が異なる場合
///
@propertyWrapper
public struct CryptoField<T>: Codable, Sendable, Hashable where T: Sendable & Codable & Hashable {
    public var wrappedValue: T?

    public init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(encrypted)
    }

    public init(from decoder: any Decoder) throws {
        guard let key = CryptoConfigContainer.key else {
            wrappedValue = nil
            return
        }
        let container = try decoder.singleValueContainer()
        let cipherData = try container.decode(Data.self)
        let plainData: Data
        do {
            plainData = try AES.GCM.open(.init(combined: cipherData), using: key)
        } catch CryptoKitError.authenticationFailure, CryptoKitError.underlyingCoreCryptoError(error: _) {
            throw DecryptAuthenticationFailure()
        }
        wrappedValue = try CryptoConfigContainer.decoder.decode(T.self, from: plainData)
    }

    private var encrypted: Data {
        get throws {
            let json = try CryptoConfigContainer.encoder.encode(wrappedValue)
            guard let key = CryptoConfigContainer.key else {
                fatalError("暗号鍵が設定されていません。CryptoFieldKey.keyに暗号鍵を設定してください。")
            }
            let sealedBox = try AES.GCM.seal(json, using: key)
            guard let combined = sealedBox.combined else {
                throw EncryptIllegalSizeNounceError()
            }
            return combined
        }
    }
}

/// エンコード（暗号化）時にNounceのサイズが異なる場合のエラー
///
/// 基本的に投げられることはないため、エラー処理は不要
public struct EncryptIllegalSizeNounceError: Error, Hashable, Codable, Sendable {}

/// デコード（復号）時にCryptoFieldプロパティが復号に失敗した際に投げられるエラー
///
/// 暗号鍵が誤っている場合に投げられる
public struct DecryptAuthenticationFailure: Error, Hashable, Codable, Sendable {}
