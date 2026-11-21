//
//  DateParser+Expressions.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation

/// Các mẫu cụm thời gian. Thứ tự trong `matchAny` là thứ tự ưu tiên: cụm dài trước cụm ngắn,
/// để `tối qua` không bị đọc thành `tối` (buổi) rồi bỏ rơi `qua`.
extension DateParser.Context {
    /// Giờ của từng buổi. So trên bản **có dấu**, vì bỏ dấu thì `sang` (chuyển sang), `toi` (tôi),
    /// `dem` (đếm) bị trùng. Riêng `trua`, `chieu` không trùng nghĩa nên nhận cả bản không dấu.
    static let periodHours: [String: Int] = [
        "sáng": 8, "trưa": 12, "chiều": 15, "tối": 20, "đêm": 22, "trua": 12, "chieu": 15,
    ]
    /// `thứ hai` … `thứ bảy` (0 là thứ Hai). So trên bản không dấu vì đã có `thứ` đứng trước.
    static let weekdayWords: [String: Int] = ["hai": 0, "ba": 1, "tu": 2, "nam": 3, "sau": 4, "bay": 5]

    struct DayMatch {
        let date: Date
        let end: Int
        let confidence: Double
    }

    func matchAny(at index: Int) -> ParsedDate? {
        matchPeriodWithDay(at: index)
            ?? matchPeriodWithModifier(at: index)
            ?? matchDay(at: index).map { found(from: index, day: $0) }
            ?? matchBarePeriod(at: index)
    }

    // MARK: - Buổi

    /// `sáng hôm qua`, `tối 15/10`, `tối thứ 6 tuần trước`: buổi ghép với ngày.
    private func matchPeriodWithDay(at index: Int) -> ParsedDate? {
        guard let hour = periodHour(index), let day = matchDay(at: index + 1),
            let date = date(atHour: hour, onDayOf: day.date)
        else { return nil }
        return ParsedDate(
            date: date, kind: .day, hour: hour, tokenStartIndex: index, tokenEndIndex: day.end,
            confidence: day.confidence)
    }

    /// `sáng nay`, `tối qua`, `đêm qua`.
    private func matchPeriodWithModifier(at index: Int) -> ParsedDate? {
        guard let hour = periodHour(index) else { return nil }
        let offset: Int
        switch text(index + 1) {
        case "nay": offset = 0
        case "qua": offset = -1
        default: return nil
        }
        guard let day = shifted(days: offset), let date = date(atHour: hour, onDayOf: day) else { return nil }
        return ParsedDate(
            date: date, kind: .day, hour: hour, tokenStartIndex: index, tokenEndIndex: index + 2,
            confidence: DateParser.Confidence.explicit)
    }

    /// `sáng`, `trưa`, `chiều`, `tối` đứng một mình **ở đầu khoản**: `sáng phở 45k`.
    /// Ở giữa khoản (`ăn sáng 30k`, `cơm trưa 40k`) thì là tên món, không phải thời gian.
    private func matchBarePeriod(at index: Int) -> ParsedDate? {
        guard let hour = periodHour(index), isClauseStart(index), let date = date(atHour: hour, onDayOf: now) else {
            return nil
        }
        return ParsedDate(
            date: date, kind: .period, hour: hour, tokenStartIndex: index, tokenEndIndex: index + 1,
            confidence: DateParser.Confidence.barePeriod)
    }

    // MARK: - Ngày

    func matchDay(at index: Int) -> DayMatch? {
        matchRelativeDay(at: index)
            ?? matchPrefixedDayOfMonth(at: index)
            ?? matchWeekday(at: index)
            ?? matchSlashDate(at: index, confidence: DateParser.Confidence.bareDayMonth)
    }

    /// `hôm nay`, `hôm qua`, `hôm kia`, `hôm 15/10`.
    private func matchRelativeDay(at index: Int) -> DayMatch? {
        guard plain(index) == "hom" else { return nil }
        let offset: Int
        switch plain(index + 1) {
        case "nay": offset = 0
        case "qua": offset = -1
        case "kia": offset = -2
        default: return matchSlashDate(at: index + 1, confidence: DateParser.Confidence.explicit)
        }
        guard let date = shifted(days: offset) else { return nil }
        return DayMatch(date: date, end: index + 2, confidence: DateParser.Confidence.explicit)
    }

    /// `ngày 5`, `mùng 5`, `mồng 5`, `ngày 15 tháng 10`, `ngày 15/10`.
    private func matchPrefixedDayOfMonth(at index: Int) -> DayMatch? {
        guard let prefix = plain(index), ["ngay", "mung", "mong"].contains(prefix),
            let day = number(index + 1), (1...31).contains(day)
        else { return nil }

        if plain(index + 2) == "thang", let month = number(index + 3) {
            guard let date = dayOfMonth(day, month: month, year: nil) else { return nil }
            return DayMatch(date: date, end: index + 4, confidence: DateParser.Confidence.explicit)
        }
        if let slashDate = matchSlashDate(at: index + 1, confidence: DateParser.Confidence.explicit) {
            return slashDate
        }
        guard let date = dayOfMonth(day, month: nil, year: nil) else { return nil }
        return DayMatch(date: date, end: index + 2, confidence: DateParser.Confidence.explicit)
    }

    /// `15/10`, `15-10`, `15/10/2026`, `15/10/26`.
    private func matchSlashDate(at index: Int, confidence: Double) -> DayMatch? {
        guard let day = number(index), (1...31).contains(day),
            let separator = text(index + 1), ["/", "-"].contains(separator),
            let month = number(index + 2), (1...12).contains(month)
        else { return nil }

        var end = index + 3
        var year: Int?
        if text(index + 3) == separator, let value = number(index + 4) {
            year = value
            end = index + 5
        }
        guard let date = dayOfMonth(day, month: month, year: year) else { return nil }
        return DayMatch(date: date, end: end, confidence: confidence)
    }

    /// `thứ 2`, `thứ hai tuần trước`, `chủ nhật tuần này`.
    private func matchWeekday(at index: Int) -> DayMatch? {
        let weekday: Int
        if text(index) == "thứ", let value = weekdayIndex(index + 1) {
            weekday = value
        } else if plain(index) == "chu", plain(index + 1) == "nhat" {
            weekday = 6
        } else {
            return nil
        }

        var end = index + 2
        var weeksBack: Int?
        if plain(end) == "tuan" {
            switch plain(end + 1) {
            case "truoc": weeksBack = 1
            case "nay": weeksBack = 0
            default: break
            }
            if weeksBack != nil { end += 2 }
        }
        guard let date = self.weekday(weekday, weeksBack: weeksBack) else { return nil }
        return DayMatch(date: date, end: end, confidence: DateParser.Confidence.explicit)
    }

    // MARK: - Tiện ích token

    private func found(from start: Int, day: DayMatch) -> ParsedDate {
        ParsedDate(
            date: day.date, kind: .day, hour: nil, tokenStartIndex: start, tokenEndIndex: day.end,
            confidence: day.confidence)
    }

    private func text(_ index: Int) -> String? {
        index < tokens.count ? tokens[index].text : nil
    }

    private func plain(_ index: Int) -> String? {
        index < tokens.count ? tokens[index].unaccented : nil
    }

    private func number(_ index: Int) -> Int? {
        guard index < tokens.count, tokens[index].type == .number, tokens[index].text.allSatisfy(\.isASCII) else {
            return nil
        }
        return Int(tokens[index].text)
    }

    private func periodHour(_ index: Int) -> Int? {
        text(index).flatMap { Self.periodHours[$0] }
    }

    private func weekdayIndex(_ index: Int) -> Int? {
        if let value = number(index) {
            return (2...7).contains(value) ? value - 2 : nil
        }
        return plain(index).flatMap { Self.weekdayWords[$0] }
    }

    private func isClauseStart(_ index: Int) -> Bool {
        index == 0 || ClauseSplitter.isSeparator(tokens[index - 1])
    }
}
