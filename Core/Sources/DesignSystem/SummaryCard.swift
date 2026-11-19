//
//  SummaryCard.swift
//  Core
//
//  Created by Le Hung on 19/11/26.
//

import SwiftUI

/// Thẻ tổng quan đầu màn hình hiển thị tổng chi tiêu trong tháng, dòng phụ và tiến độ ngân sách.
public struct SummaryCard: View {
    private let title: String
    private let amount: Int64
    private let subtitle: String?
    private let budgetRatio: Double?
    private let budgetLabel: String?

    public init(
        title: String,
        amount: Int64,
        subtitle: String? = nil,
        budgetRatio: Double? = nil,
        budgetLabel: String? = nil
    ) {
        self.title = title
        self.amount = amount
        self.subtitle = subtitle
        self.budgetRatio = budgetRatio
        self.budgetLabel = budgetLabel
    }

    /// Màu thanh tiến trình theo ngưỡng ngân sách.
    private var progressColor: Color {
        guard let budgetRatio else { return AppColor.brandPrimary }
        return BudgetProgressCard.determineProgressColor(ratio: budgetRatio)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
            Text(title)
                .font(AppTypography.secondary)
                .foregroundStyle(AppColor.textSecondary)

            AmountText(amount, style: .hero)

            if let subtitle {
                Text(subtitle)
                    .font(AppTypography.secondary)
                    .foregroundStyle(AppColor.textSecondary)
            }

            if let budgetRatio {
                budgetProgressSection(ratio: budgetRatio)
                    .padding(.top, AppSpacing.small)
            }
        }
        .padding(AppSpacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            AppColor.surfaceCard,
            in: RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }

    private func budgetProgressSection(ratio: Double) -> some View {
        HStack(spacing: AppSpacing.compact) {
            GeometryReader { proxy in
                let clampedProgress = min(max(ratio, 0.0), 1.0)
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColor.surfaceSubtle)
                        .frame(height: 6)

                    Capsule()
                        .fill(progressColor)
                        .frame(width: proxy.size.width * clampedProgress, height: 6)
                }
            }
            .frame(height: 6)

            if let budgetLabel {
                Text(budgetLabel)
                    .font(AppTypography.badge)
                    .foregroundStyle(AppColor.textPrimary)
            }
        }
    }
}

#Preview("Sáng") {
    VStack(spacing: AppSpacing.medium) {
        SummaryCard(
            title: "Đã chi tháng này",
            amount: 4_250_000,
            subtitle: "Hôm nay 62.000 ₫",
            budgetRatio: 0.68,
            budgetLabel: "68% ngân sách"
        )
    }
    .padding()
    .background(AppColor.backgroundGrouped)
    .preferredColorScheme(.light)
}

#Preview("Tối") {
    VStack(spacing: AppSpacing.medium) {
        SummaryCard(
            title: "Đã chi tháng này",
            amount: 4_250_000,
            subtitle: "Hôm nay 62.000 ₫",
            budgetRatio: 0.68,
            budgetLabel: "68% ngân sách"
        )
    }
    .padding()
    .background(AppColor.backgroundGrouped)
    .preferredColorScheme(.dark)
}
