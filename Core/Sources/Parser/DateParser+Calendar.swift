//
//  DateParser+Calendar.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation

/// Tính ngày giờ từ `now` và `Calendar` được truyền vào. Mọi hàm trả `nil` khi ngày không hợp lệ.
extension DateParser {
    struct Context {
        let tokens: [Token]
        let now: Date
        let calendar: Calendar

        /// `now` lùi hoặc tiến `days` ngày, giữ nguyên giờ phút.
        func shifted(days: Int) -> Date? {
            calendar.date(byAdding: .day, value: days, to: now)
        }

        /// Cùng ngày với `date`, đặt giờ thành `hour:00:00`.
        func date(atHour hour: Int, onDayOf date: Date) -> Date? {
            calendar.date(bySettingHour: hour, minute: 0, second: 0, of: date)
        }

        /// `ngày 5`, `15/10`, `15/10/2026`. Giữ giờ phút của `now`.
        ///
        /// Chống ngày tương lai: thiếu tháng mà ngày lớn hơn hôm nay thì lùi về tháng trước;
        /// thiếu năm mà ngày-tháng sau hôm nay thì lùi về năm trước; có năm mà vẫn ở tương lai thì bỏ.
        /// Ngày không tồn tại (`ngày 31` của tháng 30 ngày, `30/2`) trả `nil`.
        func dayOfMonth(_ day: Int, month: Int?, year: Int?) -> Date? {
            let today = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
            guard let todayYear = today.year, let todayMonth = today.month, let todayDay = today.day else {
                return nil
            }

            var targetYear = year.map { $0 < 100 ? 2000 + $0 : $0 } ?? todayYear
            var targetMonth = month ?? todayMonth
            if month == nil, day > todayDay {
                targetMonth -= 1
                if targetMonth == 0 {
                    targetMonth = 12
                    targetYear -= 1
                }
            } else if month != nil, year == nil, (targetMonth, day) > (todayMonth, todayDay) {
                targetYear -= 1
            }

            let components = DateComponents(
                calendar: calendar,
                timeZone: calendar.timeZone,
                year: targetYear,
                month: targetMonth,
                day: day,
                hour: today.hour,
                minute: today.minute,
                second: today.second
            )
            guard components.isValidDate, let date = calendar.date(from: components), date <= now else { return nil }
            return date
        }

        /// `thứ 2` (gần nhất, có thể là hôm nay), `thứ 2 tuần trước`, `thứ 2 tuần này`.
        /// `weekday`: 0 là thứ Hai, 6 là Chủ nhật (tuần bắt đầu từ thứ Hai, không phụ thuộc `firstWeekday`).
        func weekday(_ weekday: Int, weeksBack: Int?) -> Date? {
            // `Calendar.weekday`: 1 là Chủ nhật, 2 là thứ Hai … 7 là thứ Bảy.
            let todayIndex = (calendar.component(.weekday, from: now) + 5) % 7
            let offset: Int
            switch weeksBack {
            case .some(let weeks):
                offset = weekday - todayIndex - 7 * weeks
                guard offset <= 0 else { return nil }
            case .none:
                offset = -((todayIndex - weekday + 7) % 7)
            }
            return shifted(days: offset)
        }
    }
}
