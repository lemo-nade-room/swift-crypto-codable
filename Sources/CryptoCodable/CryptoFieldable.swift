import Foundation

/// 鍵が無い場合のデフォルト値を持つことができるプロトコル
public protocol CryptoFieldable: Hashable, Codable {
    static var onLostKeyValue: Self { get }
}
extension Int: CryptoFieldable {
    /// 鍵が紛失した場合のデフォルト値
    @TaskLocal public static var onLostKeyValue = 1
}
extension String: CryptoFieldable {
    /// 鍵が紛失した場合のデフォルト値
    @TaskLocal public static var onLostKeyValue = "Lost"
}
extension Double: CryptoFieldable {
    /// 鍵が紛失した場合のデフォルト値
    @TaskLocal public static var onLostKeyValue = 1.0
}
extension Bool: CryptoFieldable {
    /// 鍵が紛失した場合のデフォルト値
    @TaskLocal public static var onLostKeyValue = false
}
extension Date: CryptoFieldable {
    /// 鍵が紛失した場合のデフォルト値
    @TaskLocal public static var onLostKeyValue = Date(timeIntervalSince1970: 0)
}
extension Optional: CryptoFieldable where Wrapped: Hashable & Codable {
    /// 鍵が紛失した場合のデフォルト値
    public static var onLostKeyValue: Self { nil }
}
