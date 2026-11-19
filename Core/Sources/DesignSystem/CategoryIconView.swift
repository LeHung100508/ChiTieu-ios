//
//  CategoryIconView.swift
//  Core
//
//  Created by Le Hung on 19/11/26.
//

import SwiftUI

/// Ô vuông bo góc hiển thị icon đại diện cho danh mục giao dịch.
public struct CategoryIconView: View {
    private let iconName: String
    private let tintColor: Color
    private let backgroundColor: Color
    private let size: CGFloat

    public init(
        _ iconName: String,
        tintColor: Color = AppColor.brandPrimary,
        backgroundColor: Color = AppColor.brandTintBackground,
        size: CGFloat = 40
    ) {
        self.iconName = iconName
        self.tintColor = tintColor
        self.backgroundColor = backgroundColor
        self.size = size
    }

    public var body: some View {
        Image(systemName: iconName)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(tintColor)
            .frame(width: size, height: size)
            .background(
                backgroundColor,
                in: RoundedRectangle(cornerRadius: AppRadius.medium, style: .continuous)
            )
            // Ẩn với VoiceOver vì icon thường đi liền với nhãn tên danh mục
            .accessibilityHidden(true)
    }
}

#Preview("Sáng") {
    HStack(spacing: AppSpacing.medium) {
        CategoryIconView("fork.knife")
        CategoryIconView("cart.fill")
        CategoryIconView("fuelpump.fill")
    }
    .padding()
    .preferredColorScheme(.light)
}

#Preview("Tối") {
    HStack(spacing: AppSpacing.medium) {
        CategoryIconView("fork.knife")
        CategoryIconView("cart.fill")
        CategoryIconView("fuelpump.fill")
    }
    .padding()
    .background(AppColor.backgroundGrouped)
    .preferredColorScheme(.dark)
}
