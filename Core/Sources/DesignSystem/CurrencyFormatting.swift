//
//  CurrencyFormatting.swift
//  Core
//
//  Created by Le Hung on 19/11/26.
//

import Foundation

extension Int64 {
    /// Định dạng số tiền đơn vị VND theo Locale truyền vào (mặc định lấy theo môi trường).
    nonisolated public func formattedVND(locale: Locale = .current) -> String {
        self.formatted(.currency(code: "VND").locale(locale))
    }
}
