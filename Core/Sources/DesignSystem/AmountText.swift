//
//  AmountText.swift
//  Core
//
//  Created by Le Hung on 19/11/26.
//

import SwiftUI

/// Cấp độ hiển thị số tiền trong ứng dụng.
public enum AmountStyle: Sendable {
    case hero
    case primary
    case row
    var font: Font {
        switch self {
        case .hero:
            return AppTypography.amountHero
        case .primary:
            return AppTypography.amountPrimary
        case .row:
            return AppTypography.amountRow
        }
    }
}

/// Component hiển thị số tiền định dạng chuẩn VND với SF Pro Rounded và monospaced digit.
public struct AmountText: View {
    @Environment(\.locale) private var locale
    private let amount: Int64
    private let style: AmountStyle
    private let customColor: Color?
    public init(
        _ amount: Int64,
        style: AmountStyle = .primary,
        color: Color? = nil
    ) {
        self.amount = amount
        self.style = style
        self.customColor = color
    }
    /// Định dạng số tiền kèm ký hiệu ₫ và dấu chấm phân cách hàng nghìn.
    private var formattedText: String {
        return amount.formattedVND(locale: locale)
    }
    /// Tự động chọn màu: ưu tiên customColor, số âm dùng statusDanger, còn lại dùng textPrimary.
    private var displayColor: Color {
        if let customColor {
            return customColor
        }
        return AppColor.textPrimary
    }
    /// Nhãn đọc rõ nghĩa cho VoiceOver (ví dụ: "Âm 45.000 đồng" thay vì đọc ký tự dấu trừ).
    private var accessibilityDescription: String {
        return if amount < 0 {
            "Âm \(amount.magnitude) đồng"
        } else {
            "\(amount) đồng"
        }
    }
    public var body: some View {
        Text(formattedText)
            .amountStyle(style.font)
            .foregroundStyle(displayColor)
            .accessibilityLabel(accessibilityDescription)
    }
}

#Preview("Sáng") {
    VStack(spacing: AppSpacing.medium) {
        AmountText(-1_000_000, style: .hero)
        AmountText(1_000_000, style: .primary, color: AppColor.brandPrimary)
        AmountText(0, style: .row)
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Tối") {
    VStack(spacing: AppSpacing.medium) {
        AmountText(-1_000_000, style: .hero)
        AmountText(1_000_000, style: .primary, color: AppColor.brandPrimary)
        AmountText(0, style: .row)
    }
    .padding()
    .background(AppColor.backgroundGrouped)
    .preferredColorScheme(.dark)
}
