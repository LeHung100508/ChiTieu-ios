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
