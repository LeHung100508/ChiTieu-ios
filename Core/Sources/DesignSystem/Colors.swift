//
//  Colors.swift
//  Core
//
//  Created by Le Hung on 18/11/26.
//

import SwiftUI

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

public enum AppColor {
    // MARK: - Màu thương hiệu & trạng thái (Asset Catalog, thích ứng Sáng/Tối)

    public static let brandPrimary = Color("BrandPrimary", bundle: .module)
    public static let brandTintBackground = Color("BrandTintBackground", bundle: .module)
    public static let statusWarning = Color("StatusWarning", bundle: .module)
    public static let statusDanger = Color("StatusDanger", bundle: .module)
    public static let statusIncome = Color("StatusIncome", bundle: .module)

    // MARK: - Màu chữ hệ thống

    public static let textPrimary = Color.primary
    public static let textSecondary = Color.secondary

    // MARK: - Màu nền & đường kẻ hệ thống (ưu tiên HIG & Liquid Glass)

    public static var backgroundGrouped: Color {
        #if canImport(UIKit)
            Color(uiColor: .systemGroupedBackground)
        #elseif canImport(AppKit)
            Color(nsColor: .windowBackgroundColor)
        #endif
    }

    public static var surfaceCard: Color {
        #if canImport(UIKit)
            Color(uiColor: .secondarySystemGroupedBackground)
        #elseif canImport(AppKit)
            Color(nsColor: .controlBackgroundColor)
        #endif
    }

    public static var surfaceSubtle: Color {
        #if canImport(UIKit)
            Color(uiColor: .secondarySystemFill)
        #elseif canImport(AppKit)
            Color(nsColor: .quaternaryLabelColor)
        #endif
    }

    public static var separator: Color {
        #if canImport(UIKit)
            Color(uiColor: .separator)
        #elseif canImport(AppKit)
            Color(nsColor: .separatorColor)
        #endif
    }
}
