@preconcurrency import Crypto
import CryptoCodable
import Foundation
import Testing

@Suite struct CryptoFieldTests {
    struct Event: Hashable, Codable, Sendable {
        var id: UUID
        var 職業: String
        @CryptoField var 氏名: String
        @CryptoField var LINEやってる: Bool
        @CryptoField var 誕生日: Date
        @CryptoField var 年齢: Int
        @CryptoField var 身長: Double
        @CryptoField var 体重: Double?
    }

    @Test func 暗号化・復号できる() throws {
        // Arrange
        let event = Event(
            id: UUID(),
            職業: "暗号専門家",
            氏名: "佐藤",
            LINEやってる: true,
            誕生日: ISO8601DateFormatter().date(from: "2001-06-01T00:00:00Z")!,
            年齢: 24,
            身長: 168.3,
            体重: 32.5
        )

        try CryptoConfigContainer.$key.withValue(.init(size: .bits256)) {
            // Act
            let encrypted = try JSONEncoder().encode(event)
            let decrypted = try JSONDecoder().decode(Event.self, from: encrypted)

            // Assert
            #expect(decrypted == event)
        }
    }

    @Test func 鍵が存在しない場合にデコードするとonLostKeyValue値が入る() throws {
        // Arrange
        let event = Event(
            id: UUID(),
            職業: "暗号専門家",
            氏名: "佐藤",
            LINEやってる: true,
            誕生日: ISO8601DateFormatter().date(from: "2001-06-01T00:00:00Z")!,
            年齢: 24,
            身長: 168.3,
            体重: 32.5
        )

        let encrypted = try CryptoConfigContainer.$key.withValue(.init(size: .bits256)) {
            try JSONEncoder().encode(event)
        }

        // Act
        let decrypted = try JSONDecoder().decode(Event.self, from: encrypted)

        // Assert
        #expect(
            decrypted
                == Event(
                    id: event.id,
                    職業: "暗号専門家",
                    氏名: "Lost",
                    LINEやってる: false,
                    誕生日: Date(timeIntervalSince1970: 0),
                    年齢: 1,
                    身長: 1,
                    体重: nil
                )
        )
    }

    @Test func 異なる鍵でデコードするとエラーが投げられる() throws {
        // Arrange
        let event = Event(
            id: UUID(),
            職業: "暗号専門家",
            氏名: "佐藤",
            LINEやってる: true,
            誕生日: ISO8601DateFormatter().date(from: "2001-06-01T00:00:00Z")!,
            年齢: 24,
            身長: 168.3,
            体重: 32.5
        )

        let encrypted = try CryptoConfigContainer.$key.withValue(.init(size: .bits256)) {
            try JSONEncoder().encode(event)
        }

        // Act & Assert
        #expect(throws: DecryptFailure.self) {
            try CryptoConfigContainer.$key.withValue(.init(size: .bits256)) {
                try JSONDecoder().decode(Event.self, from: encrypted)
            }
        }
    }
}
