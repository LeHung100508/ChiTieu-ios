//
//  File.swift
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
        // Ở iS0-07, tạm thời trả về rỗng vì giải thuật sẽ được cài đặt từ iS0-08 đến iS0-11
        []
    }
}
