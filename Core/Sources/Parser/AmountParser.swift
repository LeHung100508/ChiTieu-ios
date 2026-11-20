//
//  AmountParser.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation
import Model

/// Kết quả bóc tách một khoản tiền trong câu.
public struct ParsedAmount: Sendable, Hashable {
    /// Số tiền được đóng gói kiểu Money (Int64 đồng).
    public let value: Money
    /// Vị trí ký tự bắt đầu trong chuỗi raw gốc.
    public let startIndex: Int
    /// Vị trí ký tự kết thúc trong chuỗi raw gốc.
    public let endIndex: Int
    /// Chỉ số token đầu tiên bị tiêu thụ trong mảng tokens.
    public let tokenStartIndex: Int
    /// Chỉ số token kết thúc bị tiêu thụ trong mảng tokens (exclusive).
    public let tokenEndIndex: Int
    /// Độ tin cậy của việc nhận diện (0.0 đến 1.0), xem `AmountParser.Confidence`.
    public let confidence: Double

    public init(
        value: Money,
        startIndex: Int,
        endIndex: Int,
        tokenStartIndex: Int,
        tokenEndIndex: Int,
        confidence: Double = 1.0
    ) {
        self.value = value
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.tokenStartIndex = tokenStartIndex
        self.tokenEndIndex = tokenEndIndex
        self.confidence = confidence
    }
}

/// Bộ phân tích số tiền (FR-02) dựa trên luồng token đã chuẩn hóa ở iS0-08.
///
/// Duyệt token từ trái sang phải. Tại mỗi vị trí, thử lần lượt các mẫu trong `matchAny`
/// theo thứ tự ưu tiên; mẫu nào khớp thì tiêu thụ các token của nó rồi đi tiếp.
/// Giải thuật và các giới hạn đã biết: `docs/hoc/iS0-09-parser-so-tien.md`.
public enum AmountParser {
    /// Độ tin cậy theo mức độ rõ ràng của cách viết.
    enum Confidence {
        /// Có đơn vị chuẩn hoặc ký hiệu tiền tệ: `45k`, `2 triệu`, `50000đ`.
        static let explicitUnit = 0.95
        /// Số có phân cách hàng nghìn, không có đơn vị: `450.000`.
        static let groupedNumber = 0.9
        /// Tiếng lóng và cách nói tắt: `2 củ`, `5 lít`, `năm chục`, `1tr2`, `rưỡi`.
        static let slang = 0.8
        /// Số trần không đơn vị: `350000`.
        static let bareNumber = 0.6
        /// Tiếng lóng dễ nhầm với nghĩa đen: `5 lít xăng`.
        static let ambiguousSlang = 0.4
    }

    /// Trần của một khoản tiền (dưới 1.000 tỷ đồng). Lớn hơn thì coi như không phải số tiền.
    static let maxAmount: Int64 = 999_999_999_999

    /// Đơn vị nhân 1.000.
    static let thousandUnits: Set<String> = ["k", "nghin", "ngan"]
    /// Đơn vị nhân 1.000.000 (`củ` là tiếng lóng của triệu).
    static let millionUnits: Set<String> = ["tr", "trieu", "cu"]
    /// Tiếng lóng nhân 100.000.
    static let hundredThousandUnits: Set<String> = ["lit", "loet"]
    /// Ký hiệu tiền tệ chỉ đứng sau số, **không** nhân thêm: `50000đ` là 50.000 đồng.
    static let currencySuffixes: Set<String> = ["d", "vnd", "dong"]
    /// Từ đếm đi sau số lượng (so trên bản có dấu để tránh trùng nghĩa khi bỏ dấu).
    /// Dùng để không ghép nhầm `3tr 2 người` thành 3.200.000.
    static let countingWords: Set<String> = [
        "cái", "chiếc", "ly", "cốc", "hộp", "gói", "bát", "tô", "đĩa", "đôi", "bộ", "con",
        "quyển", "cuốn", "vé", "người", "lần", "tháng", "ngày", "chai", "lon", "kg", "quả",
        "suất", "phần",
    ]
    /// Từ chỉ chất lỏng: `5 lít xăng` nhiều khả năng là 5 lít thật, không phải 500.000 đ.
    static let liquidWords: Set<String> = ["xang", "dau", "nuoc", "sua", "bia"]

    static let vnNumberWords: [String: Int64] = [
        "mot": 1,
        "hai": 2,
        "ba": 3,
        "bon": 4,
        "nam": 5,
        "sau": 6,
        "bay": 7,
        "tam": 8,
        "chin": 9,
        "muoi": 10,
    ]

    /// Phân tích danh sách các khoản tiền xuất hiện trong câu đã được chuẩn hóa.
    public static func parse(sentence: NormalizedSentence) -> [ParsedAmount] {
        let tokens = sentence.tokens
        var results: [ParsedAmount] = []
        var index = 0

        while index < tokens.count {
            if isDateNumber(tokens: tokens, at: index) {
                index += 1
                continue
            }

            if let match = matchAny(tokens: tokens, at: index) {
                results.append(match.amount)
                index += match.consumed
            } else {
                index += 1
            }
        }

        return results
    }

    /// Tiện ích parse số tiền trực tiếp từ chuỗi thô.
    public static func parse(raw: String) -> [ParsedAmount] {
        parse(sentence: Tokenizer.tokenize(raw))
    }

    /// Số đứng ngay sau `ngày`/`mùng` là ngày trong tháng, không phải số tiền.
    private static func isDateNumber(tokens: [Token], at index: Int) -> Bool {
        index > 0 && ["ngay", "mung"].contains(tokens[index - 1].unaccented) && tokens[index].type == .number
    }
}
