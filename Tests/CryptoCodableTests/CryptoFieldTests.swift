import Crypto
import CryptoCodable
import Foundation
import Testing

@Suite struct CryptoFieldTests {
    struct Event: Hashable, Codable, Sendable {
        var id: UUID
        var 職業: String
        @CryptoField var 個人情報: Self.個人情報?
        struct 個人情報: Hashable, Codable, Sendable {
            var 氏名: String
            var 誕生日: Date
            var 年齢: Int
        }
    }

    @Test func 暗号化・復号できる() throws {
        // Arrange
        let event = Event(
            id: UUID(),
            職業: "暗号専門家",
            個人情報: .init(
                氏名: "アリス",
                誕生日: Date(timeIntervalSince1970: 54),
                年齢: 777
            )
        )

        try CryptoConfigContainer.$key.withValue(.init(size: .bits256)) {
            // Act
            let encrypted = try JSONEncoder().encode(event)
            let decrypted = try JSONDecoder().decode(Event.self, from: encrypted)

            // Assert
            #expect(decrypted == event)
        }
    }

    @Test func 鍵が存在しない場合にデコードするとnilが入る() throws {
        // Arrange
        let event = Event(
            id: UUID(uuidString: "C09B74E3-1BEF-4F34-994C-FAE04390FBA8")!,
            職業: "暗号専門家",
            個人情報: .init(
                氏名: "アリス",
                誕生日: Date(timeIntervalSince1970: 54),
                年齢: 777
            )
        )

        let encrypted = try CryptoConfigContainer.$key.withValue(.init(size: .bits256)) {
            try JSONEncoder().encode(event)
        }

        // Act
        let decrypted = try JSONDecoder().decode(Event.self, from: encrypted)

        // Assert
        #expect(decrypted == .init(
            id: UUID(uuidString: "C09B74E3-1BEF-4F34-994C-FAE04390FBA8")!,
            職業: "暗号専門家",
            個人情報: nil
        ))
    }

    @Test func 異なる鍵でデコードするとエラーが投げられる() throws {
        // Arrange
        let event = Event(
            id: UUID(uuidString: "C09B74E3-1BEF-4F34-994C-FAE04390FBA8")!,
            職業: "暗号専門家",
            個人情報: .init(
                氏名: "アリス",
                誕生日: Date(timeIntervalSince1970: 54),
                年齢: 777
            )
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
