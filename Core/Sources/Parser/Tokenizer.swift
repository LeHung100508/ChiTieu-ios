//
//  Tokenizer.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation

/// Bộ phân tích tách từ và chuẩn hóa câu thành các token.
public enum Tokenizer {
    private static let vietnameseLocale = Locale(identifier: "vi_VN")

    /// Phân rã câu thô ban đầu thành cấu trúc `NormalizedSentence` chứa mảng token và chuỗi chuẩn hóa.
    public static func tokenize(_ raw: String) -> NormalizedSentence {
        guard !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return NormalizedSentence(raw: raw, text: "", unaccentedText: "", tokens: [])
        }

        let tokenPattern =
            #/
            (?<newline>\R)
            | (?<number>\d+(?:[.,]\d+)*)
            | (?<word>\p{L}+)
            | (?<punct>[^\s\p{L}\d])
            /#

        var tokens: [Token] = []

        for match in raw.matches(of: tokenPattern) {
            let range = match.range
            let rawToken = String(raw[range])
            let startIndex = raw.distance(from: raw.startIndex, to: range.lowerBound)
            let endIndex = raw.distance(from: raw.startIndex, to: range.upperBound)

            let type: TokenType
            let text: String
            let unaccented: String

            if match.output.newline != nil {
                type = .newline
                text = "\n"
                unaccented = "\n"
            } else if match.output.number != nil {
                type = .number
                text = rawToken
                unaccented = rawToken
            } else if match.output.word != nil {
                type = .word
                text = rawToken.lowercased(with: vietnameseLocale)
                unaccented = TextNormalizer.stripDiacritics(rawToken)
            } else {
                type = .punctuation
                text = rawToken
                unaccented = rawToken
            }

            tokens.append(
                Token(
                    text: text,
                    unaccented: unaccented,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    type: type
                )
            )
        }

        let normalizedText = tokens.map(\.text).joined(separator: " ")
        let unaccentedText = tokens.map(\.unaccented).joined(separator: " ")

        return NormalizedSentence(
            raw: raw,
            text: normalizedText,
            unaccentedText: unaccentedText,
            tokens: tokens
        )
    }
}
