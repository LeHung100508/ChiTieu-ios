//
//  ParserTestSuiteModel.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation
import Model
import Testing

/// Thông tin ví giả lập trong bộ câu mẫu.
struct MockWallet: Decodable, Sendable {
    let key: String
    let name: String
    let aliases: [String]
}

/// Kết quả giao dịch kỳ vọng của một ca kiểm thử.
struct ExpectedTransaction: Decodable, Sendable {
    let type: TransactionType
    let amount: Int64?
    let categoryKey: String?
    let datetime: Date?
    let wallet: String?
    let sourceWallet: String?
    let targetWallet: String?
    let note: String?
}

/// Một câu mẫu kiểm thử parser.
struct TestCase: Decodable, Sendable, CustomTestStringConvertible {
    let id: String
    let input: String
    let tags: [String]
    let expected: [ExpectedTransaction]

    var testDescription: String {
        "\(id): \(input)"
    }
}

/// Cấu trúc toàn bộ file test_cases.json.
struct TestSuite: Decodable, Sendable {
    let version: Int
    let referenceTime: Date
    let timezone: String
    let description: String
    let totalCases: Int
    let mockWallets: [MockWallet]
    let testCases: [TestCase]

    var parsedTimeZone: TimeZone {
        TimeZone(identifier: timezone) ?? .current
    }
}

/// Tiện ích nạp file test_cases.json từ submodule docs/
enum TestSuiteLoader {
    static func loadTestSuite(filePath: String = #filePath) throws -> TestSuite {
        let currentFileURL = URL(fileURLWithPath: filePath)
        let repoRootURL =
            currentFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        let jsonURL = repoRootURL.appendingPathComponent("docs/shared/parser/test_cases.json")
        let data = try Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(TestSuite.self, from: data)
    }
}
