//
//  TextNormalizer.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation

/// Bộ tiện ích chuẩn hóa chuỗi phục vụ cho tầng phân tích ngôn ngữ tự nhiên.
public enum TextNormalizer {
    private static let vietnameseLocale = Locale(identifier: "vi_VN")

    /// Bỏ dấu tiếng Việt và đưa về chữ thường, bảo đảm xử lý đúng chữ 'đ' và 'Đ'.
    public static func stripDiacritics(_ text: String) -> String {
        let lower = text.lowercased(with: vietnameseLocale)
        let replacedD = lower.replacingOccurrences(of: "đ", with: "d")
        return replacedD.folding(options: .diacriticInsensitive, locale: vietnameseLocale)
    }

    /// Tách cụm số và chữ dính nhau (ví dụ: 45k -> 45 k, 1tr2 -> 1 tr 2),
    /// nhưng bảo toàn số thập phân và dấu phân cách hàng nghìn (1.5tr, 45.000).
    public static func separateNumberAndUnits(_ text: String) -> String {
        let numFollowedByUnit = #/(?<num>\d)(?<unit>[^\d\s.,])/#
        let unitFollowedByNum = #/(?<unit>[^\d\s.,])(?<num>\d)/#

        var result = text.replacing(numFollowedByUnit) { match in
            "\(match.output.num) \(match.output.unit)"
        }
        result = result.replacing(unitFollowedByNum) { match in
            "\(match.output.unit) \(match.output.num)"
        }
        return result
    }

    /// Thu gọn các khoảng trắng và tab liên tiếp thành một dấu cách đơn, cắt khoảng trắng 2 đầu.
    public static func normalizeWhitespace(_ text: String) -> String {
        let whitespacePattern = #/\s+/#
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacing(whitespacePattern, with: " ")
    }

    /// Chuẩn hóa toàn bộ câu đầu vào qua `Tokenizer`, bảo đảm tính nhất quán 100%
    /// giữa chuỗi chuẩn hóa và danh sách token.
    public static func normalize(_ raw: String) -> (text: String, unaccentedText: String) {
        let sentence = Tokenizer.tokenize(raw)
        return (text: sentence.text, unaccentedText: sentence.unaccentedText)
    }
}
