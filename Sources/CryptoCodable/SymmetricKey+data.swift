import Crypto
import Foundation

extension SymmetricKey {
    /// `SymmetricKey`を`Data`に変換する
    ///
    /// この`Data`を保存することで後から再度デコード・復号することが可能
    ///
    /// ```swift
    /// import Crypto
    /// import CryptoCodable
    ///
    /// let key = SymmetricKey(size: .bits256)
    /// let data = key.data // このデータを永続化する
    /// ```
    ///
    /// dataは標準イニシャライザで`SymmetricKey`に戻すことができる
    ///
    /// ```swift
    /// import Crypto
    /// import Foundation
    ///
    /// let key = SymmetricKey(data: data)
    /// let event: Event = CryptoConfigContainer.$key.withValue(key) {
    ///  JSONDecoder().decode(Event.self, from: encrypted)
    /// }
    /// ```
    public var data: Data {
        withUnsafeBytes({ Data($0) })
    }
}
