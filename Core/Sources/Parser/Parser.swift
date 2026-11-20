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
    public init() {}

    /// Phân tích câu nhập liệu dựa trên thời gian tham chiếu và múi giờ.
    public func parse(
        _ input: String,
        referenceTime: Date = Date(),
        timeZone: TimeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
    ) -> [ParsedTransaction] {
        let sentence = Tokenizer.tokenize(input)
        let amounts = AmountParser.parse(sentence: sentence)

        guard !amounts.isEmpty else {
            return []
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let dates = DateParser.resolve(
            sentence: sentence,
            amounts: amounts,
            now: referenceTime,
            calendar: calendar
        )

        return amounts.enumerated().map { index, parsedAmount in
            ParsedTransaction(
                type: .expense,
                amount: ParsedField(parsedAmount.value, confidence: parsedAmount.confidence),
                categoryKey: nil,
                datetime: dates[index],
                wallet: nil,
                sourceWallet: nil,
                targetWallet: nil,
                note: nil
            )
        }
    }
}
