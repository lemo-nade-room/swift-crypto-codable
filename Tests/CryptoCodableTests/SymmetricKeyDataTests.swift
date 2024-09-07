import Crypto
import CryptoCodable
import Foundation
import Testing

@Suite struct SymmetricKeyDataTests {
    struct Content: Hashable, Codable, Sendable {
        @CryptoField var value: String?
    }

    @Test func Dataに一度変換したもので復号可能() throws {
        // Arrange
        let key = SymmetricKey(size: .bits256)
        let content = Content(value: "Hello, World!")
        let encrypted = try CryptoConfigContainer.$key.withValue(key) {
            try JSONEncoder().encode(content)
        }
        let keyData = key.data

        // Act
        let decrypted = try CryptoConfigContainer.$key.withValue(SymmetricKey(data: keyData)) {
            try JSONDecoder().decode(Content.self, from: encrypted)
        }

        // Assert
        #expect(decrypted == content)
    }
}
