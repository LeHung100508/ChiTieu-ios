//
//  File.swift
//  Core
//
//  Created by Le Hung on 14/11/26.
//

import Testing

@testable import DesignSystem

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

@Test func testColorAssetsExistInModule() {
    let expectedColors = [
        "BrandPrimary",
        "BrandTintBackground",
        "StatusWarning",
        "StatusDanger",
        "StatusIncome",
    ]
    for name in expectedColors {
        #if canImport(UIKit)
            let color = UIColor(named: name, in: .module, compatibleWith: nil)
        #elseif canImport(AppKit)
            let color = NSColor(named: NSColor.Name(name), bundle: .module)
        #endif
        #expect(color != nil, "Asset \(name) phai ton tai trong Colors.xcassets")
    }
}

@Test func testLayoutTokensArePositiveAndAscending() {
    #expect(AppSpacing.extraSmall > 0)
    #expect(AppSpacing.extraSmall < AppSpacing.small)
    #expect(AppSpacing.small < AppSpacing.compact)
    #expect(AppSpacing.compact < AppSpacing.medium)
    #expect(AppSpacing.medium < AppSpacing.large)
    #expect(AppSpacing.large < AppSpacing.extraLarge)

    #expect(AppRadius.small > 0)
    #expect(AppRadius.small < AppRadius.medium)
    #expect(AppRadius.medium < AppRadius.large)
    #expect(AppRadius.large < AppRadius.card)
}

@MainActor
@Test func testVNDCurrencyFormatting() {
    let viLocale = Locale(identifier: "vi_VN")
    let enLocale = Locale(identifier: "en_US")

    // Test số dương: phải có 45.000 và ký hiệu ₫
    let amount: Int64 = 45_000
    let formattedVi = amount.formattedVND(locale: viLocale)
    #expect(formattedVi.contains("45.000"))
    #expect(formattedVi.contains("₫"))

    // Test số âm: bắt buộc phải có dấu trừ (ASCII '-' hoặc Unicode '−') ở đầu
    let negative: Int64 = -62_000
    let formattedNeg = negative.formattedVND(locale: viLocale)
    #expect(formattedNeg.contains("62.000"))
    #expect(formattedNeg.hasPrefix("-") || formattedNeg.hasPrefix("−"))

    // Test số 0: kiểm tra chính xác "0 ₫" (kèm non-breaking space U+00A0), không dùng contains("0") lỏng lẻo
    let formattedZero = Int64(0).formattedVND(locale: viLocale)
    #expect(formattedZero == "0 ₫" || formattedZero == "0\u{00A0}₫")

    // Test locale tiếng Anh: phân cách hàng nghìn bằng dấu phẩy và có mã VND/ký hiệu ₫
    let formattedEn = amount.formattedVND(locale: enLocale)
    #expect(formattedEn.contains("45,000"))
    #expect(formattedEn.contains("VND") || formattedEn.contains("₫"))
}

@MainActor
@Test func testBudgetProgressLogic() {
    // Ca hạn mức = 0 (tránh crash chia cho 0)
    #expect(BudgetProgressCard.calculateRatio(spent: 100_000, budget: 0) == 0.0)

    // Ca dưới 80%: màu brandPrimary
    let safeRatio = BudgetProgressCard.calculateRatio(spent: 500_000, budget: 1_000_000)
    #expect(safeRatio == 0.5)
    #expect(BudgetProgressCard.calculatePercentage(ratio: safeRatio) == 50)
    #expect(BudgetProgressCard.determineProgressColor(ratio: safeRatio) == AppColor.brandPrimary)

    // Ca đúng 80%: màu statusWarning
    let warningRatio = BudgetProgressCard.calculateRatio(spent: 800_000, budget: 1_000_000)
    #expect(BudgetProgressCard.determineProgressColor(ratio: warningRatio) == AppColor.statusWarning)

    // Ca đúng 100%: màu statusDanger
    let dangerRatio = BudgetProgressCard.calculateRatio(spent: 1_000_000, budget: 1_000_000)
    #expect(BudgetProgressCard.determineProgressColor(ratio: dangerRatio) == AppColor.statusDanger)

    // Ca vượt hạn mức (> 100%): màu statusDanger
    let overRatio = BudgetProgressCard.calculateRatio(spent: 1_200_000, budget: 1_000_000)
    #expect(BudgetProgressCard.determineProgressColor(ratio: overRatio) == AppColor.statusDanger)
}
