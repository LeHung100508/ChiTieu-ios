//
//  Parser.swift
//  Core
//
//  Created by Le Hung on 14/11/26.
//

import Foundation
import Model

/// Bộ phân tích ngôn ngữ tự nhiên bóc tách câu nhập liệu thành các giao dịch.
public struct TransactionParser: Sendable {
    public let configuration: ParserConfiguration

    public init(configuration: ParserConfiguration) {
        self.configuration = configuration
    }

    /// Phân tích câu nhập liệu dựa trên cấu hình và thời gian tham chiếu.
    public func parse(
        _ input: String,
        referenceTime: Date = Date()
    ) -> [ParsedTransaction] {
        let sentence = Tokenizer.tokenize(input)
        let amounts = AmountParser.parse(sentence: sentence)

        guard !amounts.isEmpty else {
            return []
        }

        let dates = DateParser.resolve(
            sentence: sentence,
            amounts: amounts,
            now: referenceTime,
            calendar: configuration.calendar
        )

        let details = ClauseAnalyzer.analyze(
            sentence: sentence,
            amounts: amounts,
            configuration: configuration,
            now: referenceTime
        )

        return zip(amounts, zip(dates, details)).map { amount, pair in
            let (date, detail) = pair
            return ParsedTransaction(
                type: detail.type,
                amount: ParsedField(amount.value, confidence: amount.confidence),
                categoryKey: detail.categoryKey,
                datetime: date,
                wallet: detail.wallet,
                sourceWallet: detail.sourceWallet,
                targetWallet: detail.targetWallet,
                note: detail.note
            )
        }
    }
}
