//
//  CategoryDictionary.swift
//  Core
//
//  Created by Le Hung on 21/11/26.
//

import Foundation

/// Từ điển từ khóa danh mục (FR-04), đọc từ `category_keywords.json` dùng chung với Android.
///
/// Parser không tự tìm file: app (hoặc test) đọc `Data` rồi truyền vào `init(data:)`,
/// để `Parser` không phụ thuộc `Bundle` và chạy được ở mọi nơi.
public struct CategoryDictionary: Sendable {
    /// Danh mục mặc định của khoản chi không khớp từ khóa nào.
    public static let expenseFallback = "other_expense"

    public let version: Int
    let phrases: [Phrase]

    /// Một cụm từ khóa đã tách token sẵn để so khớp nhanh.
    struct Phrase: Sendable {
        let key: String
        let text: [String]
        let plain: [String]
        /// Có cho khớp bản không dấu không. Từ đơn ngắn (`chợ`→`cho`, `cá`→`ca`, `táo`→`tao`)
        /// trùng nghĩa khi bỏ dấu nên chỉ khớp bản có dấu (README mục 7).
        let allowsPlain: Bool
    }

    public init(data: Data) throws {
        let file = try JSONDecoder().decode(File.self, from: data)
        self.init(version: file.version, categories: file.categories)
    }

    public init(version: Int, categories: [String: [String]]) {
        self.version = version
        self.phrases = categories.keys.sorted().flatMap { key in
            (categories[key] ?? []).compactMap { Self.compile($0, key: key) }
        }
    }

    /// `income_*` và `other_income` là danh mục thu.
    static func isIncome(_ key: String) -> Bool {
        key.hasPrefix("income_") || key == "other_income"
    }

    /// Cụm khớp tốt nhất trong dãy token: nhiều token hơn thắng, rồi bản có dấu thắng,
    /// rồi cụm đứng trước thắng. Ví dụ `thu tiền phòng trọ` (thu) thắng `tiền phòng trọ` (nhà ở).
    func bestMatch(in tokens: [Token]) -> CategoryMatch? {
        var best: CategoryMatch?
        for start in tokens.indices {
            for phrase in phrases {
                guard let candidate = match(phrase, in: tokens, at: start) else { continue }
                if best.map({ candidate.isBetter(than: $0) }) ?? true {
                    best = candidate
                }
            }
        }
        return best
    }

    private func match(_ phrase: Phrase, in tokens: [Token], at start: Int) -> CategoryMatch? {
        let end = start + phrase.text.count
        guard end <= tokens.count else { return nil }
        let slice = tokens[start..<end]
        if slice.map(\.text) == phrase.text {
            return CategoryMatch(key: phrase.key, confidence: 1.0, tokenCount: phrase.text.count, start: start)
        }
        if phrase.allowsPlain, slice.map(\.unaccented) == phrase.plain {
            return CategoryMatch(key: phrase.key, confidence: 0.8, tokenCount: phrase.text.count, start: start)
        }
        return nil
    }

    private static func compile(_ phrase: String, key: String) -> Phrase? {
        let tokens = Tokenizer.tokenize(phrase).tokens.filter { $0.type != .punctuation }
        guard !tokens.isEmpty else { return nil }
        let plain = tokens.map(\.unaccented)
        let allowsPlain = tokens.count >= 2 || plain[0].count >= 4
        return Phrase(key: key, text: tokens.map(\.text), plain: plain, allowsPlain: allowsPlain)
    }

    private struct File: Decodable {
        let version: Int
        let categories: [String: [String]]
    }
}

/// Kết quả khớp danh mục trong một khoản.
struct CategoryMatch: Sendable, Equatable {
    let key: String
    /// 1.0 khi khớp bản có dấu, 0.8 khi khớp bản không dấu.
    let confidence: Double
    let tokenCount: Int
    let start: Int

    func isBetter(than other: CategoryMatch) -> Bool {
        if tokenCount != other.tokenCount { return tokenCount > other.tokenCount }
        if confidence != other.confidence { return confidence > other.confidence }
        if start != other.start { return start < other.start }
        return key < other.key
    }
}
