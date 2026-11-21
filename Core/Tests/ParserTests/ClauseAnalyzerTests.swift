//
//  ClauseAnalyzerTests.swift
//  Core
//
//  Created by Le Hung on 21/11/26.
//

import Foundation
import Model
import Testing

@testable import Parser

/// Nạp `category_keywords.json` từ submodule `docs/` (cùng cách với `TestSuiteLoader`).
enum CategoryDictionaryLoader {
    static func load(filePath: String = #filePath) throws -> CategoryDictionary {
        let repoRoot = URL(fileURLWithPath: filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = repoRoot.appendingPathComponent("docs/shared/parser/category_keywords.json")
        return try CategoryDictionary(data: Data(contentsOf: url))
    }
}

@Suite("Kiểm thử loại giao dịch, danh mục, ví, ghi chú và tách khoản (FR-04, FR-06, FR-07)")
struct ClauseAnalyzerTests {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return calendar
    }()

    static let wallets: [WalletAlias] = [
        WalletAlias(key: "cash", aliases: ["tiền mặt", "ví tiền mặt", "tien mat"]),
        WalletAlias(key: "momo", aliases: ["momo", "ví momo"]),
        WalletAlias(key: "vcb", aliases: ["vcb", "vietcombank", "thẻ vcb"]),
        WalletAlias(key: "credit_card", aliases: ["thẻ tín dụng", "quẹt thẻ"]),
    ]

    static func analyze(_ input: String, _ dictionary: CategoryDictionary) -> [ClauseDetails] {
        analyze(input, dictionary, wallets: wallets)
    }

    static func analyze(_ input: String, _ dictionary: CategoryDictionary, wallets: [WalletAlias]) -> [ClauseDetails] {
        let sentence = Tokenizer.tokenize(input)
        let amounts = AmountParser.parse(sentence: sentence)
        let configuration = ParserConfiguration(dictionary: dictionary, wallets: wallets, calendar: calendar)
        return ClauseAnalyzer.analyze(
            sentence: sentence, amounts: amounts, configuration: configuration,
            now: Date(timeIntervalSince1970: 1_792_465_200))
    }

    /// So ghi chú theo README mục 5.7: bỏ khoảng trắng thừa, không phân biệt hoa thường.
    static func normalized(_ note: String?) -> String? {
        note.map { $0.lowercased().split(whereSeparator: \.isWhitespace).joined(separator: " ") }
    }

    @Test("Bộ mẫu dùng chung: đúng loại, danh mục, ví, ghi chú và số khoản ở cả 200 câu")
    func testSampleSet() throws {
        let suite = try TestSuiteLoader.loadTestSuite()
        let dictionary = try CategoryDictionaryLoader.load()
        let wallets = suite.mockWallets.map { WalletAlias(key: $0.key, aliases: $0.aliases) }

        var failures: [String] = []
        for testCase in suite.testCases {
            let details = Self.analyze(testCase.input, dictionary, wallets: wallets)
            guard details.count == testCase.expected.count else {
                failures.append("\(testCase.id): số khoản \(details.count)")
                continue
            }
            for (actual, expected) in zip(details, testCase.expected) {
                let fields: [(String, Bool)] = [
                    ("type", actual.type == expected.type),
                    ("category", actual.categoryKey?.value == expected.categoryKey),
                    ("wallet", actual.wallet?.value == expected.wallet),
                    ("source", actual.sourceWallet?.value == expected.sourceWallet),
                    ("target", actual.targetWallet?.value == expected.targetWallet),
                    ("note", Self.normalized(actual.note?.value) == Self.normalized(expected.note)),
                ]
                failures += fields.filter { !$0.1 }.map { "\(testCase.id): \($0.0)" }
            }
        }
        #expect(failures.isEmpty, "Sai: \(failures)")
    }

    /// Câu ngoài bộ mẫu: kết quả mong đợi của khoản đầu tiên.
    struct OutOfSampleCase: Sendable, CustomTestStringConvertible {
        let input: String
        let type: TransactionType
        let category: String?
        let wallet: String?
        let note: String?

        var testDescription: String { input }
    }

    static let outOfSampleCases: [OutOfSampleCase] = [
        OutOfSampleCase(
            input: "Grab về nhà 62k",
            type: .expense,
            category: "transportation",
            wallet: nil,
            note: "Grab về nhà"
        ),
        OutOfSampleCase(
            input: "mua rau và thịt 80k",
            type: .expense,
            category: "groceries",
            wallet: nil,
            note: "mua rau và thịt"
        ),
        OutOfSampleCase(
            input: "cà phê với bạn 30k",
            type: .expense,
            category: "food_dining",
            wallet: nil,
            note: "cà phê với bạn"
        ),
        OutOfSampleCase(
            input: "chuyển 500k cho vợ",
            type: .expense,
            category: CategoryDictionary.expenseFallback,
            wallet: nil,
            note: "chuyển cho vợ"
        ),
        OutOfSampleCase(
            input: "đi chợ 200k bằng tiền mặt",
            type: .expense,
            category: "groceries",
            wallet: "cash",
            note: "đi chợ"
        ),
        OutOfSampleCase(
            input: "cho bé đi học 50k",
            type: .expense,
            category: "family",
            wallet: nil,
            note: "cho bé đi học"
        ),
        OutOfSampleCase(
            input: "mua thẻ điện thoại 100k quẹt thẻ tín dụng",
            type: .expense,
            category: "bills",
            wallet: "credit_card",
            note: "mua thẻ điện thoại"
        ),
        OutOfSampleCase(
            input: "bánh tráng trộn 25k",
            type: .expense,
            category: "food_dining",
            wallet: nil,
            note: "bánh tráng trộn"
        ),
        OutOfSampleCase(
            input: "hết 200k",
            type: .expense,
            category: CategoryDictionary.expenseFallback,
            wallet: nil,
            note: "hết"
        ),
    ]

    @Test("Câu ngoài bộ mẫu: giữ chữ hoa, 'và'/'với' trong một khoản", arguments: outOfSampleCases)
    func testOutOfSample(testCase: OutOfSampleCase) throws {
        let dictionary = try CategoryDictionaryLoader.load()
        let first = try #require(Self.analyze(testCase.input, dictionary).first)
        #expect(first.type == testCase.type)
        #expect(first.categoryKey?.value == testCase.category)
        #expect(first.wallet?.value == testCase.wallet)
        #expect(first.note?.value == testCase.note)
    }

    /// README mục 7: từ đơn ngắn phải có dấu, **hoặc** đi kèm từ bổ trợ (`di cho` = `đi chợ` vẫn khớp).
    @Test("Từ đơn ngắn đứng một mình chỉ khớp khi có dấu: 'cho', 'ca', 'tao'")
    func testShortWordsNeedAccents() throws {
        let dictionary = try CategoryDictionaryLoader.load()
        let fallback = CategoryDictionary.expenseFallback
        #expect(Self.analyze("cho 100k", dictionary).first?.categoryKey?.value == fallback)
        #expect(Self.analyze("ca 60k", dictionary).first?.categoryKey?.value == fallback)
        #expect(Self.analyze("tao 30k", dictionary).first?.categoryKey?.value == fallback)
        #expect(Self.analyze("di cho 100k", dictionary).first?.categoryKey?.value == "groceries")
        #expect(Self.analyze("do xang 50k", dictionary).first?.categoryKey?.value == "transportation")
        #expect(Self.analyze("do xang 50k", dictionary).first?.categoryKey?.confidence == 0.8)
    }

    @Test("Tách khoản: dấu phẩy, 'và', xuống dòng; 'và' trong một khoản tiền thì không tách")
    func testClauseSplitting() throws {
        let dictionary = try CategoryDictionaryLoader.load()
        #expect(Self.analyze("phở 40k, cafe 25k và gửi xe 5k", dictionary).count == 3)
        #expect(Self.analyze("phở 40k\r\ncafe 25k", dictionary).count == 2)
        #expect(Self.analyze("mua rau và thịt 80k", dictionary).count == 1)
        #expect(Self.analyze("uống cà phê với bạn", dictionary).isEmpty)
    }
}
