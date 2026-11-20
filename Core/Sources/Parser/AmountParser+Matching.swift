//
//  AmountParser+Matching.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation
import Model

/// Các mẫu số tiền. Thứ tự trong `matchAny` là thứ tự ưu tiên: mẫu dài, cụ thể đứng trước
/// mẫu ngắn, chung chung, để `1tr2` không bị đọc thành `1tr` rồi bỏ rơi `2`.
extension AmountParser {
    typealias Match = (amount: ParsedAmount, consumed: Int)

    static func matchAny(tokens: [Token], at index: Int) -> Match? {
        matchCompoundK(tokens: tokens, at: index)
            ?? matchCompoundMillion(tokens: tokens, at: index)
            ?? matchWordHundred(tokens: tokens, at: index)
            ?? matchSlangRuoi(tokens: tokens, at: index)
            ?? matchHalfMillion(tokens: tokens, at: index)
            ?? matchSlangChuc(tokens: tokens, at: index)
            ?? matchNumberWithUnit(tokens: tokens, at: index)
            ?? matchRawNumber(tokens: tokens, at: index)
    }

    /// `85k5` = 85.500. Chỉ ghép khi số phụ viết **liền** sau `k`, để `45k 2 ly` vẫn là 45.000.
    private static func matchCompoundK(tokens: [Token], at index: Int) -> Match? {
        guard index + 2 < tokens.count else { return nil }
        let first = tokens[index]
        let unit = tokens[index + 1]
        let second = tokens[index + 2]

        guard first.type == .number, unit.unaccented == "k", second.type == .number,
            unit.endIndex == second.startIndex,
            let thousands = plainInteger(first.text),
            let base = multiply(thousands, 1000),
            let fraction = fractionValue(second.text, unitValue: 1000),
            let total = add(base, fraction)
        else { return nil }

        return makeMatch(tokens, from: index, count: 3, value: total, confidence: Confidence.slang)
    }

    /// `1tr2` = 1.200.000, `1 củ 8` = 1.800.000, `một triệu hai`, `2tr500k` = 2.500.000.
    private static func matchCompoundMillion(tokens: [Token], at index: Int) -> Match? {
        guard index + 2 < tokens.count else { return nil }
        let unit = tokens[index + 1]
        let second = tokens[index + 2]

        guard millionUnits.contains(unit.unaccented),
            let millions = integerOrWord(tokens[index]),
            let base = multiply(millions, 1_000_000),
            !isCountedQuantity(tokens, unitAt: index + 1)
        else { return nil }

        if let total = millionPlusThousands(tokens, at: index, base: base) {
            return makeMatch(tokens, from: index, count: 4, value: total, confidence: Confidence.explicitUnit)
        }

        let fraction: Int64?
        if second.type == .number {
            fraction = fractionValue(second.text, unitValue: 1_000_000)
        } else if let digit = vnNumberWords[second.unaccented], digit < 10 {
            fraction = digit * 100_000
        } else {
            fraction = nil
        }

        guard let fraction, let total = add(base, fraction) else { return nil }
        return makeMatch(tokens, from: index, count: 3, value: total, confidence: Confidence.slang)
    }

    /// `hai trăm` = 200.000, `hai trăm rưỡi` = 250.000 (`trăm` nói tắt của trăm nghìn).
    private static func matchWordHundred(tokens: [Token], at index: Int) -> Match? {
        guard index + 1 < tokens.count,
            let hundreds = vnNumberWords[tokens[index].unaccented],
            tokens[index + 1].unaccented == "tram"
        else { return nil }

        let base = hundreds * 100_000
        if index + 2 < tokens.count, tokens[index + 2].unaccented == "ruoi" {
            return makeMatch(tokens, from: index, count: 3, value: base + 50_000, confidence: Confidence.slang)
        }
        return makeMatch(tokens, from: index, count: 2, value: base, confidence: Confidence.slang)
    }

    /// `<số> <đơn vị> rưỡi`: cộng thêm nửa đơn vị. `1 củ rưỡi`, `1 lít rưỡi`, `70 nghìn rưỡi`.
    private static func matchSlangRuoi(tokens: [Token], at index: Int) -> Match? {
        guard index + 2 < tokens.count, tokens[index + 2].unaccented == "ruoi",
            let count = integerOrWord(tokens[index]),
            let unitValue = unitMultiplier(tokens[index + 1].unaccented),
            let base = multiply(count, unitValue),
            let total = add(base, unitValue / 2)
        else { return nil }

        return makeMatch(tokens, from: index, count: 3, value: total, confidence: Confidence.slang)
    }

    /// `nửa củ`, `nửa triệu` = 500.000.
    private static func matchHalfMillion(tokens: [Token], at index: Int) -> Match? {
        guard index + 1 < tokens.count, tokens[index].unaccented == "nua",
            millionUnits.contains(tokens[index + 1].unaccented)
        else { return nil }
        return makeMatch(tokens, from: index, count: 2, value: 500_000, confidence: Confidence.slang)
    }

    /// `năm chục`, `5 chục` = 50.000.
    private static func matchSlangChuc(tokens: [Token], at index: Int) -> Match? {
        guard index + 1 < tokens.count, tokens[index + 1].unaccented == "chuc",
            let tens = integerOrWord(tokens[index]),
            let total = multiply(tens, 10_000)
        else { return nil }
        return makeMatch(tokens, from: index, count: 2, value: total, confidence: Confidence.slang)
    }

    /// `<số> <đơn vị>` kèm ký hiệu tiền tệ (nếu có): `45k`, `1,5tr`, `5 lít`, `45 nghìn đồng`.
    private static func matchNumberWithUnit(tokens: [Token], at index: Int) -> Match? {
        guard index + 1 < tokens.count, tokens[index].type == .number else { return nil }
        let unit = tokens[index + 1].unaccented

        guard let multiplier = unitMultiplier(unit),
            let number = parseNumber(tokens[index].text, preferDecimal: !thousandUnits.contains(unit)),
            let value = scaledAmount(number, multiplier: multiplier)
        else { return nil }

        let count = 2 + currencySuffixCount(tokens, at: index + 2)
        let confidence = unitConfidence(tokens, unitAt: index + 1)
        return makeMatch(tokens, from: index, count: count, value: value, confidence: confidence)
    }

    /// Số không có đơn vị: `450.000`, `1,250,000`, `350000`, `50000đ`.
    /// Bỏ qua số bắt đầu bằng `0` (số điện thoại) và số trần dưới 1.000 (số lượng, số nhà).
    private static func matchRawNumber(tokens: [Token], at index: Int) -> Match? {
        let token = tokens[index]
        guard token.type == .number, !token.text.hasPrefix("0"),
            let number = parseNumber(token.text, preferDecimal: false), number.scale == 0
        else { return nil }

        let suffix = currencySuffixCount(tokens, at: index + 1)
        guard suffix > 0 || number.mantissa >= 1000 else { return nil }

        let confidence: Double
        if suffix > 0 {
            confidence = Confidence.explicitUnit
        } else if number.isGrouped {
            confidence = Confidence.groupedNumber
        } else {
            confidence = Confidence.bareNumber
        }
        return makeMatch(tokens, from: index, count: 1 + suffix, value: number.mantissa, confidence: confidence)
    }

    // MARK: - Tiện ích

    private static func makeMatch(
        _ tokens: [Token],
        from start: Int,
        count: Int,
        value: Int64,
        confidence: Double
    ) -> Match? {
        guard value > 0, value <= maxAmount else { return nil }
        let amount = ParsedAmount(
            value: Money(value),
            startIndex: tokens[start].startIndex,
            endIndex: tokens[start + count - 1].endIndex,
            tokenStartIndex: start,
            tokenEndIndex: start + count,
            confidence: confidence
        )
        return (amount, count)
    }

    /// `2tr500k`: số phụ mang đơn vị nghìn riêng, cộng vào phần triệu.
    private static func millionPlusThousands(_ tokens: [Token], at index: Int, base: Int64) -> Int64? {
        guard index + 3 < tokens.count, tokens[index + 2].type == .number,
            thousandUnits.contains(tokens[index + 3].unaccented),
            let thousands = plainInteger(tokens[index + 2].text),
            let extra = multiply(thousands, 1000)
        else { return nil }
        return add(base, extra)
    }

    private static func unitMultiplier(_ unit: String) -> Int64? {
        if thousandUnits.contains(unit) { return 1000 }
        if millionUnits.contains(unit) { return 1_000_000 }
        if hundredThousandUnits.contains(unit) { return 100_000 }
        return nil
    }

    private static func unitConfidence(_ tokens: [Token], unitAt index: Int) -> Double {
        let unit = tokens[index].unaccented
        guard hundredThousandUnits.contains(unit) || unit == "cu" else { return Confidence.explicitUnit }
        let next = index + 1 < tokens.count ? tokens[index + 1].unaccented : ""
        return liquidWords.contains(next) ? Confidence.ambiguousSlang : Confidence.slang
    }

    private static func currencySuffixCount(_ tokens: [Token], at index: Int) -> Int {
        index < tokens.count && currencySuffixes.contains(tokens[index].unaccented) ? 1 : 0
    }

    private static func integerOrWord(_ token: Token) -> Int64? {
        token.type == .number ? plainInteger(token.text) : vnNumberWords[token.unaccented]
    }

    /// `3tr 2 người`: số đứng sau đơn vị (cách bởi khoảng trắng) mà theo sau là từ đếm
    /// thì là số lượng, không phải phần lẻ. Viết liền (`1tr2`) thì luôn là phần lẻ.
    /// Tương tự, `1tr 2tr` là hai khoản riêng: số sau mang đơn vị lớn của chính nó.
    private static func isCountedQuantity(_ tokens: [Token], unitAt index: Int) -> Bool {
        let second = index + 1
        guard second + 1 < tokens.count, tokens[index].endIndex != tokens[second].startIndex else { return false }
        let next = tokens[second + 1]
        let nextMultiplier = unitMultiplier(next.unaccented) ?? 0
        return countingWords.contains(next.text) || nextMultiplier >= 100_000
    }
}
