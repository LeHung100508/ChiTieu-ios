//
//  WalletMatcher.swift
//  Core
//
//  Created by Le Hung on 21/11/26.
//

import Foundation

/// Ví và các bí danh người dùng đặt (FR-06). App truyền danh sách ví thật vào parser;
/// test dùng `mockWallets` trong bộ mẫu.
public struct WalletAlias: Sendable, Hashable, Decodable {
    public let key: String
    public let aliases: [String]

    public init(key: String, aliases: [String]) {
        self.key = key
        self.aliases = aliases
    }
}

/// Một chỗ nhắc tới ví trong câu.
struct WalletMatch: Sendable, Equatable {
    let key: String
    let range: Range<Int>
    /// 0.95 khi khớp đúng cả dấu, 0.85 khi chỉ khớp bản không dấu.
    let confidence: Double
}

/// Tìm ví theo bí danh. So trên bản không dấu để nhận cả `tien mat`; bí danh dài thắng bí danh ngắn
/// khi chồng lên nhau (`thẻ tín dụng` thắng `quẹt thẻ`, `thẻ vcb` thắng `vcb`). README mục 2.
enum WalletMatcher {
    static func matches(in tokens: [Token], wallets: [WalletAlias]) -> [WalletMatch] {
        let aliases = wallets.flatMap { wallet in
            wallet.aliases.map { (key: wallet.key, tokens: Tokenizer.tokenize($0).tokens) }
        }
        .filter { !$0.tokens.isEmpty }

        var candidates: [WalletMatch] = []
        for start in tokens.indices {
            for alias in aliases {
                let end = start + alias.tokens.count
                guard end <= tokens.count,
                    tokens[start..<end].map(\.unaccented) == alias.tokens.map(\.unaccented)
                else { continue }
                let exact = tokens[start..<end].map(\.text) == alias.tokens.map(\.text)
                candidates.append(WalletMatch(key: alias.key, range: start..<end, confidence: exact ? 0.95 : 0.85))
            }
        }

        var chosen: [WalletMatch] = []
        let longestFirst = candidates.sorted {
            ($0.range.count, -$0.range.lowerBound) > ($1.range.count, -$1.range.lowerBound)
        }
        for candidate in longestFirst
        where !chosen.contains(where: { $0.range.overlaps(candidate.range) }) {
            chosen.append(candidate)
        }
        return chosen.sorted { $0.range.lowerBound < $1.range.lowerBound }
    }
}
