//
//  ParserBenchmarkTests.swift
//  Core
//
//  Created by Le Hung on 21/11/26.
//

import Foundation
import Model
import Testing
import XCTest

@testable import Parser

@Suite("Đo hiệu năng bộ phân tích ngôn ngữ tự nhiên (NFR-02)")
struct ParserBenchmarkTests {
    @Test("Đo độ trễ phân tích trên 200 câu mẫu (mục tiêu <= 50 ms)")
    func testBenchmark200Cases() throws {
        // 1. Chuẩn bị dữ liệu và parser ngoài vùng đo
        let suite = try TestSuiteLoader.loadTestSuite()
        let dictionary = try CategoryDictionaryLoader.load()
        let wallets = suite.mockWallets.map { WalletAlias(key: $0.key, aliases: $0.aliases) }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = suite.parsedTimeZone

        let config = ParserConfiguration(dictionary: dictionary, wallets: wallets, calendar: calendar)
        let parser = TransactionParser(configuration: config)
        let clock = ContinuousClock()

        // 2. Warmup: chạy 2 lượt trước khi bấm giờ để nạp trang bộ nhớ & regex cache
        var blackholeCount = 0
        for _ in 0..<2 {
            for testCase in suite.testCases {
                let res = parser.parse(testCase.input, referenceTime: suite.referenceTime)
                blackholeCount += res.count
            }
        }

        // 3. Vòng đo chính thức: đo từng câu một
        var durations: [Double] = []
        durations.reserveCapacity(suite.testCases.count)

        for testCase in suite.testCases {
            let elapsed = clock.measure {
                let results = parser.parse(testCase.input, referenceTime: suite.referenceTime)
                blackholeCount += results.count
            }
            durations.append(toMilliseconds(elapsed))
        }

        // Đảm bảo kết quả được tiêu thụ, chống compiler tối ưu bỏ qua (DCE)
        #expect(blackholeCount > 0)

        // 4. Tính toán các phân vị (p50, p90, p95, max, mean)
        let sorted = durations.sorted()
        let count = sorted.count
        let p50 = percentile(sorted, at: 0.50)
        let p90 = percentile(sorted, at: 0.90)
        let p95 = percentile(sorted, at: 0.95)
        let maxDuration = sorted.last ?? 0
        let mean = sorted.reduce(0, +) / Double(count)

        // In kết quả thống kê
        print(
            """
            ========== KẾT QUẢ ĐO HIỆU NĂNG PARSER (NFR-02) ==========
            Tổng số câu đo: \(count) câu
            - Trung bình (Mean): \(String(format: "%.3f", mean)) ms
            - Phân vị p50 (Median): \(String(format: "%.3f", p50)) ms
            - Phân vị p90:          \(String(format: "%.3f", p90)) ms
            - Phân vị p95:          \(String(format: "%.3f", p95)) ms
            - Chậm nhất (Max):      \(String(format: "%.3f", maxDuration)) ms
            ===========================================================
            """
        )

        // 5. Kiểm tra chỉ tiêu NFR-02 (mỗi câu <= 50 ms và p95 <= 50 ms)
        #expect(p95 <= 50.0, "p95 (\(p95) ms) vượt ngưỡng NFR-02 (50 ms)")
        #expect(maxDuration <= 50.0, "Câu chậm nhất (\(maxDuration) ms) vượt ngưỡng NFR-02 (50 ms)")
    }

    // MARK: - Tiện ích tính toán

    private func toMilliseconds(_ duration: Duration) -> Double {
        Double(duration.components.attoseconds) / 1e15 + Double(duration.components.seconds) * 1_000.0
    }

    /// Tính phân vị theo công thức Nearest-Rank chuẩn
    private func percentile(_ sorted: [Double], at fraction: Double) -> Double {
        guard !sorted.isEmpty else { return 0 }
        let index = Int(ceil(Double(sorted.count) * fraction)) - 1
        return sorted[max(0, min(sorted.count - 1, index))]
    }
}

// MARK: - XCTest Measure Benchmark (Đáp ứng yêu cầu học API measure của task)

final class ParserXCTestBenchmarks: XCTestCase {
    func testMeasureAll200CasesBlock() throws {
        let suite = try TestSuiteLoader.loadTestSuite()
        let dictionary = try CategoryDictionaryLoader.load()
        let wallets = suite.mockWallets.map { WalletAlias(key: $0.key, aliases: $0.aliases) }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = suite.parsedTimeZone
        let config = ParserConfiguration(dictionary: dictionary, wallets: wallets, calendar: calendar)
        let parser = TransactionParser(configuration: config)

        measure(metrics: [XCTClockMetric()]) {
            var count = 0
            for testCase in suite.testCases {
                count += parser.parse(testCase.input, referenceTime: suite.referenceTime).count
            }
            XCTAssertGreaterThan(count, 0)
        }
    }
}
