//
//  ClauseAnalyzer.swift
//  Core
//
//  Created by Le Hung on 21/11/26.
//

import Foundation
import Model

/// Những gì parser cần biết ngoài câu nhập: từ điển danh mục, ví của người dùng, lịch (đã đặt múi giờ).
/// App tạo một lần (đọc từ điển từ bundle, lấy ví từ dữ liệu) rồi truyền vào parser.
public struct ParserConfiguration: Sendable {
    public let dictionary: CategoryDictionary
    public let wallets: [WalletAlias]
    public let calendar: Calendar

    public init(dictionary: CategoryDictionary, wallets: [WalletAlias], calendar: Calendar) {
        self.dictionary = dictionary
        self.wallets = wallets
        self.calendar = calendar
    }
}

/// Các trường của một khoản, ngoài số tiền và thời gian.
struct ClauseDetails: Sendable, Equatable {
    let type: TransactionType
    let categoryKey: ParsedField<String>?
    let wallet: ParsedField<String>?
    let sourceWallet: ParsedField<String>?
    let targetWallet: ParsedField<String>?
    let note: ParsedField<String>?
}

/// Phân tích từng khoản (FR-04, FR-06, FR-07): loại giao dịch, danh mục, ví, ghi chú.
///
/// Mỗi khoản là một khoảng token (xem `ClauseSplitter`). Trong khoảng đó, các token đã "thuộc về"
/// trường khác (số tiền, thời gian, ví và từ dẫn ví, dấu câu) bị loại; phần còn lại là ghi chú
/// và là chỗ tìm từ khóa danh mục. Quy tắc ghi chú: README mục 5.
enum ClauseAnalyzer {
    /// Từ dẫn ví đứng ngay trước bí danh: `bằng momo`, `qua vcb`, `chuyển khoản vcb`, `trừ ví momo`.
    static let walletMarkers: Set<String> = [
        "bang", "qua", "tru", "quet", "thanh", "toan", "chuyen", "khoan", "tu", "sang", "vao", "atm",
        "vi", "the", "ngan", "hang",
    ]
    /// Hư từ tiêu hao đứng ngay trước số tiền, bỏ khỏi ghi chú: `tiêu 200k`, `bán đồ cũ được 350k`.
    static let spendingFillers: Set<String> = ["tieu", "het", "mat", "duoc"]
    /// Từ chỉ hành vi chuyển tiền, bỏ khỏi ghi chú của khoản chuyển khoản.
    static let transferWords: Set<String> = ["chuyen", "khoan", "rut", "nap", "tien"]

    static let noteConfidence = 0.8
    static let fallbackCategoryConfidence = 0.3

    static func analyze(
        sentence: NormalizedSentence,
        amounts: [ParsedAmount],
        configuration: ParserConfiguration,
        now: Date
    ) -> [ClauseDetails] {
        let tokens = sentence.tokens
        let ranges = ClauseSplitter.ranges(tokens: tokens, amounts: amounts)
        let dates = DateParser.parse(
            sentence: sentence, now: now, calendar: configuration.calendar, excluding: amounts)
        let walletMatches = WalletMatcher.matches(in: tokens, wallets: configuration.wallets)

        var claimed = Set<Int>()
        for amount in amounts { claimed.formUnion(amount.tokenStartIndex..<amount.tokenEndIndex) }
        for date in dates { claimed.formUnion(date.tokenStartIndex..<date.tokenEndIndex) }
        for index in tokens.indices where tokens[index].type != .word && tokens[index].type != .number {
            claimed.insert(index)
        }
        // `và`/`với` làm ranh giới giữa hai khoản thì bỏ; nằm trong một khoản (`mua rau và thịt`) thì giữ.
        for index in ClauseSplitter.boundaries(tokens: tokens, amounts: amounts)
        where index < tokens.count && ClauseSplitter.isSeparator(tokens[index]) {
            claimed.insert(index)
        }

        return zip(ranges, amounts).map { range, amount in
            analyzeClause(
                Clause(tokens: tokens, range: range, amount: amount, claimed: claimed),
                walletMatches: walletMatches.filter { range.contains($0.range.lowerBound) },
                dictionary: configuration.dictionary,
                raw: sentence.raw
            )
        }
    }

    // MARK: - Một khoản

    struct Clause {
        let tokens: [Token]
        let range: Range<Int>
        let amount: ParsedAmount
        var claimed: Set<Int>

        func plain(_ index: Int) -> String { tokens[index].unaccented }
        var content: [Int] { range.filter { !claimed.contains($0) } }
    }

    private static func analyzeClause(
        _ clause: Clause,
        walletMatches: [WalletMatch],
        dictionary: CategoryDictionary,
        raw: String
    ) -> ClauseDetails {
        var clause = clause
        var markersByWallet: [Set<String>] = []
        for match in walletMatches {
            clause.claimed.formUnion(match.range)
            markersByWallet.append(claimMarkers(before: match.range.lowerBound, in: &clause))
        }
        claimFiller(in: &clause)

        let roles = TransferRoles(matches: walletMatches, markers: markersByWallet, clause: clause)
        if let source = roles.source, let target = roles.target {
            clause.claimed.formUnion(clause.content.filter { transferWords.contains(clause.plain($0)) })
            return ClauseDetails(
                type: .transfer, categoryKey: nil, wallet: nil,
                sourceWallet: ParsedField(source.key, confidence: source.confidence),
                targetWallet: ParsedField(target.key, confidence: target.confidence),
                note: note(of: clause, raw: raw))
        }

        let contentTokens = clause.content.map { clause.tokens[$0] }
        let category = dictionary.bestMatch(in: contentTokens)
        let isIncome = category.map { CategoryDictionary.isIncome($0.key) } ?? false
        return ClauseDetails(
            type: isIncome ? .income : .expense,
            categoryKey: category.map { ParsedField($0.key, confidence: $0.confidence) }
                ?? ParsedField(CategoryDictionary.expenseFallback, confidence: fallbackCategoryConfidence),
            wallet: walletMatches.first.map { ParsedField($0.key, confidence: $0.confidence) },
            sourceWallet: nil,
            targetWallet: nil,
            note: note(of: clause, raw: raw))
    }

    /// Bỏ dãy từ dẫn ví liền trước bí danh; trả về các từ đã bỏ để xác định vai trò ví.
    private static func claimMarkers(before start: Int, in clause: inout Clause) -> Set<String> {
        var markers = Set<String>()
        var index = start - 1
        while index >= clause.range.lowerBound, isUnclaimedMarker(index, in: clause) {
            markers.insert(clause.plain(index))
            clause.claimed.insert(index)
            index -= 1
        }
        return markers
    }

    private static func isUnclaimedMarker(_ index: Int, in clause: Clause) -> Bool {
        !clause.claimed.contains(index) && walletMarkers.contains(clause.plain(index))
    }

    /// Bỏ hư từ tiêu hao liền trước số tiền, nếu ghi chú vẫn còn nội dung khác.
    private static func claimFiller(in clause: inout Clause) {
        let index = clause.amount.tokenStartIndex - 1
        guard clause.range.contains(index), !clause.claimed.contains(index),
            spendingFillers.contains(clause.plain(index))
        else { return }
        clause.claimed.insert(index)
        if clause.content.isEmpty { clause.claimed.remove(index) }
    }

    /// Ghi chú: các đoạn token liền nhau còn lại, cắt nguyên văn từ `raw` (giữ chữ hoa và cách viết
    /// như `4g`), nối bằng một dấu cách. Không còn gì thì `nil` (câu chỉ có số tiền).
    private static func note(of clause: Clause, raw: String) -> ParsedField<String>? {
        var runs: [[Int]] = []
        for index in clause.content {
            if let last = runs.last?.last, last == index - 1 {
                runs[runs.count - 1].append(index)
            } else {
                runs.append([index])
            }
        }
        let pieces = runs.compactMap { run -> String? in
            guard let first = run.first, let last = run.last else { return nil }
            let start = raw.index(raw.startIndex, offsetBy: clause.tokens[first].startIndex)
            let end = raw.index(raw.startIndex, offsetBy: clause.tokens[last].endIndex)
            return String(raw[start..<end])
        }
        let text = pieces.joined(separator: " ").split(whereSeparator: \.isWhitespace).joined(separator: " ")
        return text.isEmpty ? nil : ParsedField(text, confidence: noteConfidence)
    }
}

/// Vai trò ví trong khoản chuyển khoản (README mục 2, 5):
/// - Ví nguồn: có `từ` đứng trước (`từ vcb`, `từ atm vcb`).
/// - Ví đích: có `sang` hoặc `vào` đứng trước; với `rút tiền`, ví đích là ví còn lại (`tiền mặt`).
struct TransferRoles {
    let source: WalletMatch?
    let target: WalletMatch?

    init(matches: [WalletMatch], markers: [Set<String>], clause: ClauseAnalyzer.Clause) {
        let pairs = Array(zip(matches, markers))
        let source = pairs.first { $0.1.contains("tu") }?.0
        let marked = pairs.first { !$0.1.isDisjoint(with: ["sang", "vao"]) }?.0
        let isWithdrawal = clause.range.contains { clause.plain($0) == "rut" }
        let other = isWithdrawal ? matches.first { $0 != source } : nil
        self.source = source
        self.target = marked ?? other
    }
}
