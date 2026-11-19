//
//  CategoryChip.swift
//  Core
//
//  Created by Le Hung on 19/11/26.
//

import SwiftUI

/// Thẻ bấm chọn hoặc lọc theo danh mục, bảo đảm vùng chạm tối thiểu 44 pt.
public struct CategoryChip: View {
    @Environment(\.colorScheme) private var colorScheme

    private let title: String
    private let iconName: String?
    private let isSelected: Bool
    private let action: () -> Void

    public init(
        _ title: String,
        iconName: String? = nil,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.iconName = iconName
        self.isSelected = isSelected
        self.action = action
    }

    /// Màu chữ/icon: khi chọn thì tương phản với brandPrimary, khi chưa chọn thì dùng textSecondary.
    private var foregroundColor: Color {
        if isSelected {
            return colorScheme == .dark ? .black : .white
        }
        return AppColor.textPrimary
    }

    /// Màu nền: khi chọn dùng brandPrimary, khi chưa chọn dùng surfaceSubtle (hoặc surfaceCard).
    private var chipBackground: Color {
        isSelected ? AppColor.brandPrimary : AppColor.surfaceSubtle
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.extraSmall) {
                if let iconName {
                    Image(systemName: iconName)
                        .font(AppTypography.caption)
                }
                Text(title)
                    .font(AppTypography.body)
            }
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, AppSpacing.compact)
            .padding(.vertical, AppSpacing.small)
            .background(chipBackground, in: Capsule())
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // Ngữ nghĩa trợ năng VoiceOver
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Sáng") {
    HStack(spacing: AppSpacing.small) {
        CategoryChip("Tất cả", isSelected: true, action: {})
        CategoryChip("Ăn uống", iconName: "fork.knife", isSelected: false, action: {})
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Tối") {
    HStack(spacing: AppSpacing.small) {
        CategoryChip("Tất cả", isSelected: true, action: {})
        CategoryChip("Ăn uống", iconName: "fork.knife", isSelected: false, action: {})
    }
    .padding()
    .background(AppColor.backgroundGrouped)
    .preferredColorScheme(.dark)
}
