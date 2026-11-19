//
//  DesignSystemPreview.swift
//  Core
//
//  Created by Le Hung on 18/11/26.
//

import SwiftUI

private struct DesignSystemPreview: View {
    @Environment(\.colorScheme) private var colorScheme

    /// Chữ trên nền nhấn: biến thể tối của các màu nhấn đều sáng nên cần chữ đen.
    private var onFill: Color { colorScheme == .dark ? .black : .white }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.large) {
                colorSection
                typographySection
                layoutAndGlassSection
            }
            .padding(AppSpacing.medium)
        }
        .background(AppColor.backgroundGrouped)
        .tint(AppColor.brandPrimary)
    }

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            card("brandPrimary", onFill, backgroundColor: AppColor.brandPrimary)
            card("brandPrimary trên tint", AppColor.brandPrimary, backgroundColor: AppColor.brandTintBackground)
            card("statusIncome", onFill, backgroundColor: AppColor.statusIncome)
            card("statusWarning", onFill, backgroundColor: AppColor.statusWarning)
            card("statusDanger", onFill, backgroundColor: AppColor.statusDanger)
            card("surfaceCard", AppColor.textPrimary, backgroundColor: AppColor.surfaceCard)
            card("surfaceSubtle", AppColor.textPrimary, backgroundColor: AppColor.surfaceSubtle)
            card("separator", AppColor.textPrimary, backgroundColor: AppColor.separator)
        }
    }

    private var typographySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            // Nhóm số tiền (SF Pro Rounded + monospacedDigit)
            typographyRow("amountHero", "4.250.000 ₫", font: AppTypography.amountHero, isAmount: true)
            typographyRow("amountPrimary", "45.000 ₫", font: AppTypography.amountPrimary, isAmount: true)
            typographyRow("amountRow", "−62.000 ₫", font: AppTypography.amountRow, isAmount: true)

            // Nhóm văn bản (SF Pro)
            typographyRow("screenTitle", "Tổng quan", font: AppTypography.screenTitle)
            typographyRow("sectionTitle", "Gần đây", font: AppTypography.sectionTitle)
            typographyRow("bodyEmphasized", "Ăn uống sắp vượt ngân sách", font: AppTypography.bodyEmphasized)
            typographyRow("body", "Tiền điện tháng 9", font: AppTypography.body)
            typographyRow("secondary", "Di chuyển · MoMo · 7:45", font: AppTypography.secondary)
            typographyRow("caption", "Hôm nay · Tiền mặt", font: AppTypography.caption)
            typographyRow("badge", "Ăn uống", font: AppTypography.badge)
        }
    }

    private func typographyRow(_ tokenName: String, _ sample: String, font: Font, isAmount: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
            Text(tokenName)
                .font(AppTypography.caption)
                .foregroundStyle(AppColor.textSecondary)

            if isAmount {
                Text(sample)
                    .amountStyle(font)
                    .foregroundStyle(AppColor.brandPrimary)
            } else {
                Text(sample)
                    .font(font)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            AppColor.surfaceCard,
            in: RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
        )
    }

    private var layoutAndGlassSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            card(text: "Spacing compact, radius card", spacing: AppSpacing.compact, radius: AppRadius.card)
            card(text: "Spacing extra large, radius, medium", spacing: AppSpacing.extraLarge, radius: AppRadius.large)
            card(text: "Spacing extra small, radius medium", spacing: AppSpacing.extraSmall, radius: AppRadius.medium)
            card(text: "Spacing large, radius small", spacing: AppSpacing.large, radius: AppRadius.small)
            card(text: "Spacing medium, radius small", spacing: AppSpacing.medium, radius: AppRadius.small)
            card(text: "Spacing small, radius small", spacing: AppSpacing.small, radius: AppRadius.small)
            Button("Button glass Prominent") {

            }.buttonStyle(.glassProminent)

            Button("Button glass") {

            }.buttonStyle(.glass)
        }
    }

    private func card(_ title: String? = nil, _ titleColor: Color? = nil, backgroundColor: Color) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.compact) {
            if let title {
                Text(title).font(AppTypography.body).foregroundStyle(titleColor ?? AppColor.textSecondary)
            }
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }

    private func card(text: String, spacing: CGFloat, radius: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.compact) {
            Text(text).font(AppTypography.body).foregroundStyle(AppColor.brandPrimary)
        }
        .padding(spacing)
        .background(AppColor.brandTintBackground, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

}

#Preview("Sáng") {
    DesignSystemPreview()
        .preferredColorScheme(.light)
}
#Preview("Tối") {
    DesignSystemPreview()
        .preferredColorScheme(.dark)
}
#Preview("Dynamic Type AX5") {
    DesignSystemPreview()
        .environment(\.dynamicTypeSize, .accessibility5)
}
