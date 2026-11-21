//
//  ClauseSplitter.swift
//  Core
//
//  Created by Le Hung on 21/11/26.
//

import Foundation

/// Tách câu thành các khoản (FR-07): mỗi khoản tiền là một khoản, theo README mục 6.
///
/// Ranh giới giữa khoản `k` và `k + 1` là token phân cách đầu tiên nằm **giữa hai khoản tiền**
/// (`,` `;` xuống dòng `và` `với`). Không có phân cách thì ranh giới là ngay sau khoản tiền `k`.
/// Vì chỉ xét phân cách nằm giữa hai khoản tiền, `mua rau và thịt 80k` (một khoản tiền) không bị tách.
enum ClauseSplitter {
    static func boundaries(tokens: [Token], amounts: [ParsedAmount]) -> [Int] {
        guard amounts.count > 1 else { return [] }
        return (0..<(amounts.count - 1)).map { clause in
            let start = amounts[clause].tokenEndIndex
            let end = max(start, amounts[clause + 1].tokenStartIndex)
            return (start..<end).first { isSeparator(tokens[$0]) } ?? start
        }
    }

    /// Khoảng token của từng khoản, cùng thứ tự với `amounts`.
    static func ranges(tokens: [Token], amounts: [ParsedAmount]) -> [Range<Int>] {
        let cuts = boundaries(tokens: tokens, amounts: amounts)
        let starts = [0] + cuts
        let ends = cuts + [tokens.count]
        return zip(starts, ends).map { $0..<max($0, $1) }
    }

    static func clauseIndex(ofToken index: Int, boundaries: [Int]) -> Int {
        boundaries.filter { index >= $0 }.count
    }

    static func isSeparator(_ token: Token) -> Bool {
        token.type == .newline || [",", ";"].contains(token.text) || ["và", "với"].contains(token.text)
    }
}
