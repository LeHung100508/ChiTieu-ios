//
//  SummaryCard.swift
//  Core
//
//  Created by Le Hung on 19/11/26.
//

import SwiftUI

/// Thẻ tổng hợp tiến độ chi tiêu theo danh mục hoặc ngân sách.
public struct BudgetProgressCard: View {
    @Environment(\.locale) private var locale
    private let title: String
    private let iconName: String
    private let spentAmount: Int64
    private let budgetAmount: Int64
    private let action: (() -> Void)?

    public init(
        title: String,
        iconName: String,
        spentAmount: Int64,
        budgetAmount: Int64,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.iconName = iconName
        self.spentAmount = spentAmount
        self.budgetAmount = budgetAmount
        self.action = action
    }

    /// Tỷ lệ chi tiêu thực tế so với hạn mức (ví dụ 0.85 = 85%).
    private var ratio: Double {
        Self.calculateRatio(spent: spentAmount, budget: budgetAmount)
    }

    /// Phần trăm hiển thị làm tròn (có thể vượt 100%).
    private var percentage: Int {
        Self.calculatePercentage(ratio: ratio)
    }

    /// Màu thanh tiến trình đổi theo ngưỡng cảnh báo.
    private var progressColor: Color {
        Self.determineProgressColor(ratio: ratio)
    }

    /// Chuỗi định dạng hạn mức tiền tệ VND.
    private var formattedBudget: String {
        budgetAmount.formattedVND(locale: locale)
    }

    /// Mô tả mạch lạc cho VoiceOver.
    private var accessibilityDescription: String {
        let spentText = spentAmount.formattedVND(locale: locale)
        return "\(title): đã chi \(spentText) trên hạn mức \(formattedBudget), đạt \(percentage) phần trăm"
    }

    public var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    cardContent
                }
                .buttonStyle(.plain)
            } else {
                cardContent
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: AppSpacing.compact) {
            // Hàng 1: Icon + Tên + %
            HStack(spacing: AppSpacing.small) {
                CategoryIconView(iconName, size: 36)
                Text(title)
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text("\(percentage)%")
                    .font(AppTypography.bodyEmphasized)
                    .foregroundStyle(progressColor)
            }

            // Hàng 2: Thanh tiến trình
            progressBar

            // Hàng 3: Đã chi / Hạn mức
            HStack {
                AmountText(spentAmount, style: .row)
                Spacer()
                Text("trên \(formattedBudget)")
                    .font(AppTypography.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(AppSpacing.medium)
        .background(
            AppColor.surfaceCard,
            in: RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
        )
    }

    /// Thanh tiến trình hai lớp: nền mờ và thanh tiến độ tự co giãn (clamped tối đa 1.0)
    private var progressBar: some View {
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
    }
}

#Preview("Sáng") {
    VStack(spacing: AppSpacing.medium) {
        // An toàn (< 80%)
        BudgetProgressCard(title: "Ăn uống", iconName: "fork.knife", spentAmount: 1_500_000, budgetAmount: 4_000_000)
        // Cảnh báo sắp vượt (80% - 99%)
        BudgetProgressCard(title: "Mua sắm", iconName: "cart.fill", spentAmount: 3_400_000, budgetAmount: 4_000_000)
        // Vượt hạn mức (>= 100%)
        BudgetProgressCard(title: "Du lịch", iconName: "airplane", spentAmount: 5_200_000, budgetAmount: 4_000_000)
    }
    .padding()
    .background(AppColor.backgroundGrouped)
    .preferredColorScheme(.light)
}

#Preview("Tối") {
    VStack(spacing: AppSpacing.medium) {
        BudgetProgressCard(title: "Ăn uống", iconName: "fork.knife", spentAmount: 1_500_000, budgetAmount: 4_000_000)
        BudgetProgressCard(title: "Mua sắm", iconName: "cart.fill", spentAmount: 3_400_000, budgetAmount: 4_000_000)
        BudgetProgressCard(title: "Du lịch", iconName: "airplane", spentAmount: 5_200_000, budgetAmount: 4_000_000)
    }
    .padding()
    .background(AppColor.backgroundGrouped)
    .preferredColorScheme(.dark)
}

extension BudgetProgressCard {
    static func calculateRatio(spent: Int64, budget: Int64) -> Double {
        guard budget > 0 else { return 0 }
        return Double(spent) / Double(budget)
    }

    static func calculatePercentage(ratio: Double) -> Int {
        Int((ratio * 100).rounded())
    }

    static func determineProgressColor(ratio: Double) -> Color {
        if ratio >= 1.0 {
            return AppColor.statusDanger
        } else if ratio >= 0.8 {
            return AppColor.statusWarning
        } else {
            return AppColor.brandPrimary
        }
    }
}
