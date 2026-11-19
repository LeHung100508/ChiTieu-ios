//
//  Typography.swift
//  Core
//
//  Created by Le Hung on 18/11/26.
//

import SwiftUI

public enum AppTypography {
    // MARK: - Số tiền (SF Pro Rounded, tự co giãn Dynamic Type)

    public static let amountHero: Font = .system(.largeTitle, design: .rounded, weight: .bold)
    public static let amountPrimary: Font = .system(.title2, design: .rounded, weight: .bold)
    public static let amountRow: Font = .system(.body, design: .rounded, weight: .medium)

    // MARK: - Văn bản hệ thống (SF Pro, tự co giãn Dynamic Type)

    public static let screenTitle: Font = .system(.largeTitle, weight: .bold)
    public static let sectionTitle: Font = .system(.title3, weight: .bold)
    public static let body: Font = .body
    public static let bodyEmphasized: Font = .body.weight(.semibold)
    public static let secondary: Font = .subheadline
    public static let caption: Font = .footnote
    public static let badge: Font = .caption.weight(.semibold)
}

extension View {
    public func amountStyle(_ font: Font) -> some View {
        self.font(font).monospacedDigit()
    }
}
