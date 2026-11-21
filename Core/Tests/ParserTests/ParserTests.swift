//
//  ParserTests.swift
//  Core
//
//  Created by Le Hung on 14/11/26.
//

import Foundation
import Model
import Testing

@testable import Parser

@Test func testLoad200TestCases() throws {
    let suite = try TestSuiteLoader.loadTestSuite()

    // Kiểm tra nạp đủ 200 câu mẫu
    #expect(suite.totalCases == 200)
    #expect(suite.testCases.count == 200)
    #expect(!suite.mockWallets.isEmpty)
    #expect(suite.timezone == "Asia/Ho_Chi_Minh")
}

@Test func testReferenceTimeAndFirstCase() throws {
    let suite = try TestSuiteLoader.loadTestSuite()

    // 1. Kiểm tra referenceTime giải mã đúng ngày giờ theo múi giờ Asia/Ho_Chi_Minh
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = suite.parsedTimeZone

    let components = calendar.dateComponents([.year, .month, .day, .hour], from: suite.referenceTime)
    #expect(components.year == 2026)
    #expect(components.month == 10)
    #expect(components.day == 20)
    #expect(components.hour == 10)

    // 2. Kiểm tra chi tiết câu mẫu đầu tiên tc_001
    let firstCase = try #require(suite.testCases.first)
    #expect(firstCase.id == "tc_001")
    #expect(firstCase.input == "phở bò 45k")

    let expectedFirst = try #require(firstCase.expected.first)
    #expect(expectedFirst.type == .expense)
    #expect(expectedFirst.amount == 45_000)
    #expect(expectedFirst.categoryKey == "food_dining")
    #expect(expectedFirst.note == "phở bò")
}

@Test("Phân tích 200 câu mẫu", arguments: try TestSuiteLoader.loadTestSuite().testCases)
func testParameterizedAllCases(testCase: TestCase) async throws {
    let suite = try TestSuiteLoader.loadTestSuite()
    let dictionary = try CategoryDictionaryLoader.load()
    let wallets = suite.mockWallets.map { WalletAlias(key: $0.key, aliases: $0.aliases) }
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = suite.parsedTimeZone
    let config = ParserConfiguration(dictionary: dictionary, wallets: wallets, calendar: calendar)

    let parser = TransactionParser(configuration: config)
    let results = parser.parse(
        testCase.input,
        referenceTime: suite.referenceTime
    )

    // Khẳng định 100% về số lượng giao dịch, số tiền và thời gian
    #expect(results.count == testCase.expected.count)
    #expect(results.compactMap(\.amount?.value.amount) == testCase.expected.map(\.amount))
    #expect(results.compactMap(\.datetime?.value) == testCase.expected.map(\.datetime))

    // Khẳng định 100% loại, danh mục, ví và ghi chú
    for (actual, expected) in zip(results, testCase.expected) {
        #expect(actual.type == expected.type)
        #expect(actual.categoryKey?.value == expected.categoryKey)
        #expect(actual.wallet?.value == expected.wallet)
        #expect(actual.sourceWallet?.value == expected.sourceWallet)
        #expect(actual.targetWallet?.value == expected.targetWallet)
        #expect(normalizedNote(actual.note?.value) == normalizedNote(expected.note))
    }
}

private func normalizedNote(_ note: String?) -> String? {
    note.map { $0.lowercased().split(whereSeparator: \.isWhitespace).joined(separator: " ") }
}
