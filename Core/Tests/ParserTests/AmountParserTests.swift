//
//  AmountParserTests.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation
import Model
import Testing
@testable import Parser

@Suite("Kiểm thử bộ phân tích số tiền (AmountParser - FR-02)")
struct AmountParserTests {
    @Test("Nhận diện đơn vị nghìn chuẩn (k, nghìn, ngàn, đ)")
    func testStandardUnits() {
        let cases: [(String, Int64)] = [
            ("phở 45k", 45_000),
            ("ăn bún bò 40 nghìn", 40_000),
            ("bánh cuốn 30 ngàn", 30_000),
            ("gửi xe 5k", 5000),
            ("vé xe buýt 7 ngàn", 7000),
        ]
        for (input, expected) in cases {
            let amounts = AmountParser.parse(raw: input)
            #expect(amounts.count == 1, "Failed for \(input)")
            #expect(amounts.first?.value == Money(expected), "Failed value for \(input)")
        }
    }

    @Test("Nhận diện tiếng lóng người Việt (củ, lít, loét, chục, nửa củ)")
    func testSlangUnits() {
        let cases: [(String, Int64)] = [
            ("mua điện thoại 4 củ", 4_000_000),
            ("tiền phòng trọ 2 củ", 2_000_000),
            ("mua vest 1 củ", 1_000_000),
            ("mua nồi chiên nửa củ", 500_000),
            ("đổ xăng 5 lít", 500_000),
            ("mua giày 3 lít", 300_000),
            ("mua balo 3 loét", 300_000),
            ("tiền sách 2 loét", 200_000),
            ("uống trà cúc năm chục", 50_000),
            ("rửa xe máy ba chục", 30_000),
            ("mua hoa quả sáu chục", 60_000),
            ("ăn sáng bốn chục", 40_000),
        ]
        for (input, expected) in cases {
            let amounts = AmountParser.parse(raw: input)
            #expect(amounts.count == 1, "Failed for \(input)")
            #expect(amounts.first?.value == Money(expected), "Failed value for \(input)")
        }
    }

    @Test("Nhận diện cấu trúc số ghép và số từ (1tr2, 85k5, củ rưỡi, hai trăm rưỡi)")
    func testCompoundUnits() {
        let cases: [(String, Int64)] = [
            ("tai nghe 1tr2", 1_200_000),
            ("mua máy ép 1tr5", 1_500_000),
            ("đóng tiền học 2tr3", 2_300_000),
            ("mua bàn phím 1 củ 2", 1_200_000),
            ("ăn hải sản 1 củ 8", 1_800_000),
            ("sữa tắm 85k5", 85_500),
            ("bảo dưỡng xe 1 củ rưỡi", 1_500_000),
            ("cắt tóc 1 lít rưỡi", 150_000),
            ("sửa điện nước 2 loét rưỡi", 250_000),
            ("vé máy bay 3 triệu rưỡi", 3_500_000),
            ("vé xem phim một trăm", 100_000),
            ("mua sạc hai trăm", 200_000),
            ("khám răng ba trăm", 300_000),
            ("quỹ lớp năm trăm", 500_000),
            ("mua thuốc một trăm rưỡi", 150_000),
            ("chuột máy tính hai trăm rưỡi", 250_000),
            ("vé xe ba trăm rưỡi", 350_000),
        ]
        for (input, expected) in cases {
            let amounts = AmountParser.parse(raw: input)
            #expect(amounts.count == 1, "Failed for \(input)")
            #expect(amounts.first?.value == Money(expected), "Failed value for \(input)")
        }
    }

    @Test("Nhận diện số thập phân (1.5tr, 1,5tr, 2,2tr)")
    func testDecimalUnits() {
        let cases: [(String, Int64)] = [
            ("mua kính 1,5tr", 1_500_000),
            ("bàn làm việc 2,2tr", 2_200_000),
            ("mua đệm 3.5tr", 3_500_000),
            ("đồng hồ 4.2tr", 4_200_000),
        ]
        for (input, expected) in cases {
            let amounts = AmountParser.parse(raw: input)
            #expect(amounts.count == 1, "Failed for \(input)")
            #expect(amounts.first?.value == Money(expected), "Failed value for \(input)")
        }
    }

    @Test("Nhận diện số có dấu chấm và số nguyên trần (450.000, 350000)")
    func testDotSeparatedAndRaw() {
        let cases: [(String, Int64)] = [
            ("tiền điện 450.000", 450_000),
            ("tiền nước 120.000", 120_000),
            ("thay nhớt xe 150.000 đ", 150_000),
            ("mua giày 1.250.000", 1_250_000),
            ("tiền nhà 3.500.000", 3_500_000),
            ("mua tủ lạnh 6.800.000 đ", 6_800_000),
            ("mua áo sơ mi 350000", 350_000),
            ("tiền mạng 220000", 220_000),
        ]
        for (input, expected) in cases {
            let amounts = AmountParser.parse(raw: input)
            #expect(amounts.count == 1, "Failed for \(input)")
            #expect(amounts.first?.value == Money(expected), "Failed value for \(input)")
        }
    }

    @Test("Bóc tách câu có nhiều khoản tiền (multi-amount)")
    func testMultiAmounts() {
        let input = "sáng phở 45k, trưa cơm 35k, cafe 29k"
        let amounts = AmountParser.parse(raw: input)
        #expect(amounts.count == 3)
        #expect(amounts.map(\.value) == [Money(45_000), Money(35_000), Money(29_000)])
    }

    @Test("Chống nhận nhầm số nhà và số lượng")
    func testAvoidNonAmountNumbers() {
        let input = "mua 2 cốc trà sữa 60k ở 123 Lê Lợi"
        let amounts = AmountParser.parse(raw: input)
        #expect(amounts.count == 1)
        #expect(amounts.first?.value == Money(60_000))
    }

    @Test("Xử lý an toàn câu không chứa số tiền")
    func testNoAmount() {
        let input = "uống cà phê với bạn"
        let amounts = AmountParser.parse(raw: input)
        #expect(amounts.isEmpty)
    }

    /// Các câu ngoài bộ mẫu dùng chung, thêm sau rà soát 2026-11-20 để chặn hồi quy.
    static let outOfSampleCases: [(String, [Int64])] = [
        ("cafe 50000đ", [50_000]),
        ("ăn trưa 35000 đồng", [35_000]),
        ("nạp thẻ 200000 vnd", [200_000]),
        ("ăn phở 45 nghìn đồng", [45_000]),
        ("trà sữa 45k 2 ly", [45_000]),
        ("sữa tắm 85k05", [85_050]),
        ("tiền nhà 1tr05", [1_050_000]),
        ("tai nghe 1tr250", [1_250_000]),
        ("tiền nhà 3tr 2 người", [3_000_000]),
        ("lương 15tr 2tr thưởng", [15_000_000, 2_000_000]),
        ("2tr500k", [2_500_000]),
        ("mua 5m vải 200k", [200_000]),
        ("xăng 70 nghìn rưỡi", [70_500]),
        ("mua ổ cứng 1,250,000", [1_250_000]),
        ("bánh 45.5k", [45_500]),
        ("gọi 0912345678 hỏi giá", []),
        ("9999999999999999k", []),
        ("99999999999999999999", []),
        ("mua 2 cốc trà sữa 60k ở 123 Lê Lợi", [60_000]),
    ]

    @Test("Câu ngoài bộ mẫu: ký hiệu tiền tệ, số lượng, phần lẻ, tràn số", arguments: outOfSampleCases)
    func testOutOfSample(input: String, expected: [Int64]) {
        let amounts = AmountParser.parse(raw: input).map(\.value.amount)
        #expect(amounts == expected)
    }

    @Test("Độ tin cậy theo mức độ rõ ràng của cách viết")
    func testConfidence() {
        let cases: [(String, Double)] = [
            ("phở 45k", AmountParser.Confidence.explicitUnit),
            ("cafe 50000đ", AmountParser.Confidence.explicitUnit),
            ("tiền điện 450.000", AmountParser.Confidence.groupedNumber),
            ("mua điện thoại 4 củ", AmountParser.Confidence.slang),
            ("tiền mạng 220000", AmountParser.Confidence.bareNumber),
            ("đổ 5 lít xăng", AmountParser.Confidence.ambiguousSlang),
        ]
        for (input, expected) in cases {
            #expect(AmountParser.parse(raw: input).first?.confidence == expected, "\(input)")
        }
    }

    @Test("Đọc chuỗi số: phân cách hàng nghìn và số thập phân")
    func testParseNumber() {
        typealias Number = AmountParser.DecimalNumber
        func parse(_ text: String, decimal: Bool) -> Number? {
            AmountParser.parseNumber(text, preferDecimal: decimal)
        }
        #expect(parse("45.000", decimal: false) == Number(mantissa: 45_000, scale: 0, isGrouped: true))
        #expect(parse("1,5", decimal: true) == Number(mantissa: 15, scale: 1, isGrouped: false))
        #expect(parse("1.250", decimal: true) == Number(mantissa: 1250, scale: 3, isGrouped: false))
        #expect(parse("1.250", decimal: false) == Number(mantissa: 1250, scale: 0, isGrouped: true))
        #expect(parse("1.2.3", decimal: false) == nil)
    }

    @Test("Đạt ngưỡng Cổng 1: đúng số tiền trên >= 95% câu mẫu (thực tế 100%)")
    func testAccuracyOn200CasesThreshold() throws {
        let suite = try TestSuiteLoader.loadTestSuite()
        var correctCount = 0

        for testCase in suite.testCases {
            let amounts = AmountParser.parse(raw: testCase.input)
            let actualValues = amounts.map(\.value.amount)
            let expectedValues = testCase.expected.map(\.amount)

            if actualValues == expectedValues {
                correctCount += 1
            }
        }

        let accuracy = Double(correctCount) / Double(suite.testCases.count)
        #expect(accuracy >= 0.95, "Độ chính xác số tiền \(accuracy * 100)% chưa đạt Cổng 1 (95%)")
        #expect(correctCount == 200, "Đạt đúng \(correctCount)/200 câu mẫu")
    }
}
