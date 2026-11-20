//
//  ParsedTransaction.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation

/// Giá trị bóc tách được kèm độ tin cậy từ 0.0 đến 1.0.
public struct ParsedField<Value: Sendable & Hashable & Codable>: Sendable, Hashable, Codable, CustomStringConvertible {
    public let value: Value
    public let confidence: Double

    public init(_ value: Value, confidence: Double = 1.0) {
        self.value = value
        // Bảo đảm độ tin cậy luôn nằm trong đoạn 0.0 đến 1.0
        self.confidence = min(max(confidence, 0.0), 1.0)
    }

    public var description: String {
        "\(value) (\(Int(confidence * 100))%)"
    }
}

/// Loại giao dịch mà parser nhận diện được.
public enum TransactionType: String, Sendable, Codable, CaseIterable {
    case expense = "EXPENSE"
    case income = "INCOME"
    case transfer = "TRANSFER"
}

/// Kết quả bóc tách từ một câu nhập liệu tự nhiên.
public struct ParsedTransaction: Sendable, Hashable, Codable {
    public let type: TransactionType
    public let amount: ParsedField<Money>?
    public let categoryKey: ParsedField<String>?
    public let datetime: ParsedField<Date>?
    public let wallet: ParsedField<String>?
    public let sourceWallet: ParsedField<String>?
    public let targetWallet: ParsedField<String>?
    public let note: ParsedField<String>?

    public init(
        type: TransactionType,
        amount: ParsedField<Money>? = nil,
        categoryKey: ParsedField<String>? = nil,
        datetime: ParsedField<Date>? = nil,
        wallet: ParsedField<String>? = nil,
        sourceWallet: ParsedField<String>? = nil,
        targetWallet: ParsedField<String>? = nil,
        note: ParsedField<String>? = nil
    ) {
        self.type = type
        self.amount = amount
        self.categoryKey = categoryKey
        self.datetime = datetime
        self.wallet = wallet
        self.sourceWallet = sourceWallet
        self.targetWallet = targetWallet
        self.note = note
    }
}
