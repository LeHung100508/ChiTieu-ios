//
//  Money.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation

/// Đóng gói số tiền nguyên (đơn vị đồng), chống sai số dấu phẩy động.
public struct Money: Sendable, Hashable, Codable, Comparable, CustomStringConvertible {
    public let amount: Int64

    public init(_ amount: Int64) {
        self.amount = amount
    }

    public var description: String {
        "\(amount)"
    }

    // Triển khai Comparable: so sánh theo giá trị amount
    public static func < (lhs: Money, rhs: Money) -> Bool {
        lhs.amount < rhs.amount
    }

    // Phép cộng hai số tiền
    public static func + (lhs: Money, rhs: Money) -> Money {
        Money(lhs.amount + rhs.amount)
    }

    // Phép trừ hai số tiền
    public static func - (lhs: Money, rhs: Money) -> Money {
        Money(lhs.amount - rhs.amount)
    }
}

extension Money: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int64) {
        self.init(value)
    }
}

extension Money {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.amount = try container.decode(Int64.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(amount)
    }
}
