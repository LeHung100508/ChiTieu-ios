//
//  DateParserTests.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation
import Model
import Testing

@testable import Parser

@Suite("Kiểm thử bộ phân tích thời gian (DateParser - FR-03)")
struct DateParserTests {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
        return calendar
    }()

    /// Mốc của bộ mẫu: thứ Ba 2026-10-20 10:00 (+07:00).
    static let reference = date(2026, 10, 20, 10, 0)

    static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)
        return calendar.date(from: components) ?? .distantPast
    }

    static func resolve(_ input: String, now: Date = reference) -> [Date] {
        resolveFields(input, now: now).map(\.value)
    }

    static func resolveFields(_ input: String, now: Date) -> [ParsedField<Date>] {
        let sentence = Tokenizer.tokenize(input)
        let amounts = AmountParser.parse(sentence: sentence)
        return DateParser.resolve(sentence: sentence, amounts: amounts, now: now, calendar: calendar)
    }

    @Test("Bộ mẫu dùng chung: đúng thời gian ở cả 200 câu")
    func testSampleSet() throws {
        let suite = try TestSuiteLoader.loadTestSuite()
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = suite.parsedTimeZone

        var failures: [String] = []
        for testCase in suite.testCases {
            let sentence = Tokenizer.tokenize(testCase.input)
            let amounts = AmountParser.parse(sentence: sentence)
            let dates = DateParser.resolve(
                sentence: sentence, amounts: amounts, now: suite.referenceTime, calendar: calendar
            ).map(\.value)
            if dates != testCase.expected.map(\.datetime) {
                failures.append(testCase.id)
            }
        }
        #expect(failures.isEmpty, "Sai thời gian: \(failures)")
    }

    /// Câu ngoài bộ mẫu, mốc thứ Ba 2026-10-20 10:00.
    static let outOfSampleCases: [(String, [Date])] = [
        ("sáng hôm qua cafe 30k", [date(2026, 10, 19, 8, 0)]),
        ("tối thứ 6 tuần trước nhậu 300k", [date(2026, 10, 16, 20, 0)]),
        ("thứ 2 ăn bún 40k", [date(2026, 10, 19, 10, 0)]),
        ("thứ 3 ăn bún 40k", [date(2026, 10, 20, 10, 0)]),
        ("chủ nhật tuần trước đi chơi 500k", [date(2026, 10, 18, 10, 0)]),
        ("ngày 25 đóng học 2tr", [date(2026, 9, 25, 10, 0)]),
        ("25/12 mua quà 300k", [date(2025, 12, 25, 10, 0)]),
        ("hôm qua ăn sáng 35k, tối xem phim 100k", [date(2026, 10, 19, 10, 0), date(2026, 10, 19, 20, 0)]),
        ("ngày 31 tháng 9 mua áo 200k", [reference]),
        ("15/10/2027 mua vé 200k", [reference]),
        ("chuyển 2tr từ VCB sang ví tiền mặt", [reference]),
        ("thu 2tr tiền nhà", [reference]),
        ("tôi ăn phở 45k", [reference]),
        ("đếm tiền lẻ 20k", [reference]),
    ]

    @Test("Câu ngoài bộ mẫu: buổi ghép ngày, thứ, chống tương lai, ngày sai, từ dễ nhầm", arguments: outOfSampleCases)
    func testOutOfSample(input: String, expected: [Date]) {
        #expect(Self.resolve(input) == expected)
    }

    @Test("Qua nửa đêm và sang tháng mới: hiện tại là Chủ nhật 2026-11-01 00:30")
    func testAfterMidnightAtMonthStart() {
        let now = Self.date(2026, 11, 1, 0, 30)
        #expect(Self.resolve("hôm qua mua thuốc 60k", now: now) == [Self.date(2026, 10, 31, 0, 30)])
        #expect(Self.resolve("tối qua nhậu 250k", now: now) == [Self.date(2026, 10, 31, 20, 0)])
        #expect(Self.resolve("hôm kia cắt tóc 80k", now: now) == [Self.date(2026, 10, 30, 0, 30)])
        #expect(Self.resolve("ngày 5 đóng tiền nhà 3tr", now: now) == [Self.date(2026, 10, 5, 0, 30)])
        #expect(Self.resolve("ngày 31 ăn lẩu 300k", now: now) == [Self.date(2026, 10, 31, 0, 30)])
        #expect(Self.resolve("thứ 2 tuần trước sửa xe 120k", now: now) == [Self.date(2026, 10, 19, 0, 30)])
    }

    @Test("Ngày không tồn tại thì bỏ, không ném lỗi: 2026-03-01, nói 'ngày 30'")
    func testInvalidDayInShortMonth() {
        let now = Self.date(2026, 3, 1, 9, 0)
        let fields = Self.resolveFields("ngày 30 mua sách 100k", now: now)
        #expect(fields.map(\.value) == [now])
        #expect(fields.first?.confidence == DateParser.Confidence.defaultNow)
    }

    @Test("Sang năm mới: hiện tại là 2027-01-02, nói '15/12' và 'ngày 20'")
    func testAcrossNewYear() {
        let now = Self.date(2027, 1, 2, 10, 0)
        #expect(Self.resolve("15/12 mua quà 300k", now: now) == [Self.date(2026, 12, 15, 10, 0)])
        #expect(Self.resolve("ngày 20 ăn cưới 500k", now: now) == [Self.date(2026, 12, 20, 10, 0)])
    }

    @Test("Độ tin cậy theo mức độ rõ ràng")
    func testConfidence() {
        let cases: [(String, Double)] = [
            ("hôm qua ăn ốc 150k", DateParser.Confidence.explicit),
            ("sáng phở 45k", DateParser.Confidence.barePeriod),
            ("15/10 đi ăn cưới 500k", DateParser.Confidence.bareDayMonth),
            ("phở bò 45k", DateParser.Confidence.defaultNow),
        ]
        for (input, expected) in cases {
            #expect(Self.resolveFields(input, now: Self.reference).first?.confidence == expected, "\(input)")
        }
    }
}
