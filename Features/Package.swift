// swift-tools-version: 6.2
//
// ==============================================================================
// LUẬT PHỤ THUỘC (ARCHITECTURE RULES) - PACKAGE FEATURES
// Dự án: ChiTieu (iOS) - Sprint iS0 / Task iS0-02
// ==============================================================================
// 1. FEATURE -> FEATURE: BỊ CẤM HOÀN TOÀN (Zero cross-feature dependencies).
//    Các module tính năng độc lập tuyệt đối, không gọi chéo nhau. Mọi điều hướng
//    hoặc tích hợp dữ liệu do target App (:ChiTieu) điều phối.
//
// 2. FEATURE -> CORE (Danh sách product được phép):
//    - `Model`, `Data`, `DesignSystem`: Được phép phụ thuộc khi module cần dữ liệu,
//      lưu trữ SwiftData hoặc thành phần giao diện dùng chung.
//    - `Parser`: CHỈ DÀNH RIÊNG cho feature `QuickAdd` (phân tích câu nhập tự nhiên).
//      Các feature khác (Transactions, Budget, Stats, Settings, Onboarding)
//      TUYỆT ĐỐI KHÔNG phụ thuộc vào `Parser`.
//
// 3. QUY ĐỊNH CHO TEST TARGETS:
//    - Các test target (QuickAddTests, BudgetTests...) ĐƯỢC PHÉP phụ thuộc vào
//      `CoreTesting` để sử dụng mock data, fakes và test fixtures.
//    - `CoreTesting` TUYỆT ĐỐI KHÔNG được link vào target App production.
//
// 4. UI/VIEW ISOLATION:
//    - Mặc định MainActor cho các target UI/Feature (swiftSettings: [.defaultIsolation(MainActor.self)]).
// ==============================================================================

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [
        .iOS("26.0"),
        .macOS(.v26)
    ],
    products: [
        .library(name: "QuickAdd", targets: ["QuickAdd"]),
        .library(name: "Transactions", targets: ["Transactions"]),
        .library(name: "Budget", targets: ["Budget"]),
        .library(name: "Stats", targets: ["Stats"]),
        .library(name: "Settings", targets: ["Settings"]),
        .library(name: "Onboarding", targets: ["Onboarding"]),
    ],
    dependencies: [
        .package(path: "../Core")
    ],
    targets: [
        // QuickAdd
        .target(
            name: "QuickAdd",
            dependencies: [
                .product(name: "Model", package: "Core"),
                .product(name: "DesignSystem", package: "Core")
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(name: "QuickAddTests", dependencies: ["QuickAdd"]),

        // Transactions
        .target(
            name: "Transactions",
            dependencies: [
                .product(name: "Model", package: "Core"),
                .product(name: "DesignSystem", package: "Core")
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(name: "TransactionsTests", dependencies: ["Transactions"]),

        // Budget
        .target(
            name: "Budget",
            dependencies: [
                .product(name: "Model", package: "Core"),
                .product(name: "DesignSystem", package: "Core")
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(name: "BudgetTests", dependencies: ["Budget"]),

        // Stats
        .target(
            name: "Stats",
            dependencies: [
                .product(name: "Model", package: "Core"),
                .product(name: "DesignSystem", package: "Core")
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(name: "StatsTests", dependencies: ["Stats"]),

        // Settings
        .target(
            name: "Settings",
            dependencies: [
                .product(name: "Model", package: "Core"),
                .product(name: "DesignSystem", package: "Core")
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(name: "SettingsTests", dependencies: ["Settings"]),

        // Onboarding
        .target(
            name: "Onboarding",
            dependencies: [
                .product(name: "Model", package: "Core"),
                .product(name: "DesignSystem", package: "Core")
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(name: "OnboardingTests", dependencies: ["Onboarding"]),
    ]
)
