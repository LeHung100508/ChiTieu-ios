//
//  AmountParser+Number.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation

/// Đọc chuỗi số và tính toán an toàn với tràn số. Mọi phép tính trả `nil` thay vì crash.
extension AmountParser {
    /// Số đã đọc: giá trị thật là `mantissa / 10^scale`. Ví dụ `1,5` là (15, 1), `45.000` là (45000, 0).
    struct DecimalNumber: Equatable {
        let mantissa: Int64
        let scale: Int
        /// Có dấu phân cách hàng nghìn (`45.000`, `1,250,000`).
        let isGrouped: Bool
    }

    /// Đọc chuỗi số của token `.number`.
    ///
    /// - Các nhóm sau dấu `.`/`,` đều có 3 chữ số thì là phân cách hàng nghìn: `45.000`, `1,250,000`.
    /// - Đúng một dấu phân cách và không phải hàng nghìn thì là số thập phân: `1,5`, `45.5`.
    /// - `preferDecimal`: với đơn vị lớn (`tr`, `củ`, `lít`), `1.250tr` được hiểu là 1,25 triệu.
    static func parseNumber(_ text: String, preferDecimal: Bool) -> DecimalNumber? {
        let groups = text.split(whereSeparator: { $0 == "." || $0 == "," }).map(String.init)
        guard let head = groups.first, let headValue = Int64(head) else { return nil }
        if groups.count == 1 {
            return DecimalNumber(mantissa: headValue, scale: 0, isGrouped: false)
        }

        let tail = groups.dropFirst()
        let looksGrouped = (1...3).contains(head.count) && tail.allSatisfy { $0.count == 3 }

        if groups.count == 2, preferDecimal || !looksGrouped {
            let fraction = groups[1]
            guard fraction.count <= 6, let fractionValue = Int64(fraction),
                let scaledHead = multiply(headValue, power10(fraction.count)),
                let mantissa = add(scaledHead, fractionValue)
            else { return nil }
            return DecimalNumber(mantissa: mantissa, scale: fraction.count, isGrouped: false)
        }

        guard looksGrouped, let joined = Int64(groups.joined()) else { return nil }
        return DecimalNumber(mantissa: joined, scale: 0, isGrouped: true)
    }

    /// `số × hệ số`, chỉ nhận kết quả nguyên đồng: `1,5` × 1.000.000 = 1.500.000.
    static func scaledAmount(_ number: DecimalNumber, multiplier: Int64) -> Int64? {
        guard let product = multiply(number.mantissa, multiplier) else { return nil }
        let divisor = power10(number.scale)
        guard product % divisor == 0 else { return nil }
        return product / divisor
    }

    /// Số nguyên thuần, không có dấu phân cách.
    static func plainInteger(_ text: String) -> Int64? {
        guard text.allSatisfy(\.isASCII) else { return nil }
        return Int64(text)
    }

    /// Phần lẻ viết sau đơn vị, tính theo **số chữ số** chứ không theo giá trị:
    /// với `unitValue` = 1.000.000 thì `2` → 200.000, `05` → 50.000, `250` → 250.000.
    static func fractionValue(_ text: String, unitValue: Int64) -> Int64? {
        guard (1...3).contains(text.count), let digits = plainInteger(text) else { return nil }
        return multiply(digits, unitValue / power10(text.count))
    }

    static func multiply(_ lhs: Int64, _ rhs: Int64) -> Int64? {
        let (result, overflow) = lhs.multipliedReportingOverflow(by: rhs)
        return overflow ? nil : result
    }

    static func add(_ lhs: Int64, _ rhs: Int64) -> Int64? {
        let (result, overflow) = lhs.addingReportingOverflow(rhs)
        return overflow ? nil : result
    }

    private static func power10(_ exponent: Int) -> Int64 {
        (0..<exponent).reduce(Int64(1)) { result, _ in result * 10 }
    }
}
