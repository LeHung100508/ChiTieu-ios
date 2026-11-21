//
//  DateParser.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation
import Model

/// Một cụm chỉ thời gian tìm thấy trong câu.
public struct ParsedDate: Sendable, Hashable {
    public enum Kind: Sendable, Hashable {
        /// Có ngày rõ ràng (`hôm qua`, `ngày 5`, `15/10`, `thứ 2 tuần trước`, `sáng nay`, `tối qua`).
        /// Được lan sang các khoản sau trong câu nhiều khoản.
        case day
        /// Chỉ có buổi đứng một mình ở đầu khoản (`sáng`, `trưa`, `chiều`, `tối`). Không lan.
        case period
    }

    public let date: Date
    public let kind: Kind
    /// Buổi trong ngày nếu cụm có nhắc tới (để ghép với ngày được lan từ khoản trước).
    public let hour: Int?
    /// Chỉ số token đầu tiên của cụm.
    public let tokenStartIndex: Int
    /// Chỉ số token kết thúc của cụm (exclusive).
    public let tokenEndIndex: Int
    public let confidence: Double
}

/// Bộ phân tích thời gian (FR-03) dựa trên luồng token đã chuẩn hóa ở iS0-08.
///
/// Thời điểm hiện tại (`now`) và `Calendar` (đã đặt múi giờ) được truyền vào, không tự đọc đồng hồ,
/// để test cho kết quả cố định. Giải thuật và giới hạn: `docs/hoc/iS0-10-parser-thoi-gian.md`.
public enum DateParser {
    /// Độ tin cậy theo mức độ rõ ràng của cách viết.
    enum Confidence {
        /// `hôm qua`, `ngày 5`, `ngày 15 tháng 10`, `thứ 2 tuần trước`, `sáng nay`.
        static let explicit = 0.95
        /// Buổi đứng một mình ở đầu khoản: `sáng phở 45k`.
        static let barePeriod = 0.85
        /// `15/10` không có `ngày`/`hôm` đứng trước, dễ nhầm với phân số.
        static let bareDayMonth = 0.8
        /// Câu không nhắc thời gian: lấy thời điểm hiện tại.
        static let defaultNow = 0.5
    }

    /// Tìm mọi cụm chỉ thời gian trong câu, theo thứ tự xuất hiện.
    public static func parse(sentence: NormalizedSentence, now: Date, calendar: Calendar) -> [ParsedDate] {
        let context = Context(tokens: sentence.tokens, now: now, calendar: calendar)
        var results: [ParsedDate] = []
        var index = 0
        while index < context.tokens.count {
            if let found = context.matchAny(at: index) {
                results.append(found)
                index = found.tokenEndIndex
            } else {
                index += 1
            }
        }
        return results
    }

    /// Như `parse`, bỏ các cụm chồng lên token của khoản tiền (ví dụ `thu 2tr` không phải `thứ 2`).
    static func parse(
        sentence: NormalizedSentence,
        now: Date,
        calendar: Calendar,
        excluding amounts: [ParsedAmount]
    ) -> [ParsedDate] {
        parse(sentence: sentence, now: now, calendar: calendar).filter { date in
            !amounts.contains { overlaps(date, $0) }
        }
    }

    /// Gán thời gian cho từng khoản tiền (cùng thứ tự với `amounts`), theo luật lan ngữ cảnh:
    /// - Khoản có cụm thời gian riêng thì dùng cụm đó.
    /// - Cụm loại `.day` được lan sang các khoản sau chưa có thời gian riêng.
    /// - Khoản chỉ có buổi (`.period`) mà trước đó đã có ngày được lan thì ghép buổi vào ngày đó.
    /// - Không có gì thì lấy `now` với độ tin cậy thấp.
    public static func resolve(
        sentence: NormalizedSentence,
        amounts: [ParsedAmount],
        now: Date,
        calendar: Calendar
    ) -> [ParsedField<Date>] {
        let dates = parse(sentence: sentence, now: now, calendar: calendar, excluding: amounts)
        let boundaries = ClauseSplitter.boundaries(tokens: sentence.tokens, amounts: amounts)
        let context = Context(tokens: sentence.tokens, now: now, calendar: calendar)

        var carried: ParsedDate?
        var result: [ParsedField<Date>] = []
        for clause in amounts.indices {
            let own = dates.first {
                ClauseSplitter.clauseIndex(ofToken: $0.tokenStartIndex, boundaries: boundaries) == clause
            }
            switch (own, carried) {
            case (.some(let own), _) where own.kind == .day:
                carried = own
                result.append(ParsedField(own.date, confidence: own.confidence))
            case (.some(let own), .some(let carried)):
                let combined = own.hour.flatMap { context.date(atHour: $0, onDayOf: carried.date) }
                result.append(ParsedField(combined ?? own.date, confidence: own.confidence))
            case (.some(let own), .none):
                result.append(ParsedField(own.date, confidence: own.confidence))
            case (.none, .some(let carried)):
                result.append(ParsedField(carried.date, confidence: carried.confidence))
            case (.none, .none):
                result.append(ParsedField(now, confidence: Confidence.defaultNow))
            }
        }
        return result
    }

    // MARK: - Tiện ích

    private static func overlaps(_ date: ParsedDate, _ amount: ParsedAmount) -> Bool {
        date.tokenStartIndex < amount.tokenEndIndex && amount.tokenStartIndex < date.tokenEndIndex
    }
}
