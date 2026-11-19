// swift-tools-version: 6.2

// ==============================================================================
// BẢNG THIẾT KẾ VÀ LUẬT PHỤ THUỘC (ARCHITECTURE DEPENDENCY RULES)
// Dự án: ChiTieu (iOS) - Module hóa (Sprint iS0 / Task iS0-02)
// ==============================================================================
//
// 1. CÁC MODULE TRONG CORE:
//    - Model:
//        * Pure Foundation, value types (struct, enum), Sendable.
//        * Không phụ thuộc module nào khác (Zero dependencies).
//        * KHÔNG chứa UI (SwiftUI) và KHÔNG chứa persistence (SwiftData).
//    - Parser:
//        * Pure Foundation pipeline (thuần Swift logic).
//        * CHỈ phụ thuộc vào `Model`.
//        * TUYỆT ĐỐI KHÔNG import SwiftUI hay SwiftData.
//    - Data:
//        * Phụ thuộc vào `Model`.
//        * Quản lý SwiftData models (@Model), container, persistence và migration.
//    - DesignSystem:
//        * Phụ thuộc vào `Model`.
//        * Chứa màu sắc thương hiệu (#1B6B4A), typography, reusable components.
//    - CoreTesting:
//        * Phụ thuộc vào `Model`.
//        * Cung cấp fakes, mocks, test fixtures.
//        * CHỈ dùng cho các test target, KHÔNG link vào App target production.
//
// 2. QUY TẮC RÀNH BUỘC FEATURE (Áp dụng cho Package Features):
//    - Feature -> Feature: BỊ CẤM HOÀN TOÀN. Các feature hoàn toàn độc lập với nhau.
//    - Feature -> Core: Được phép phụ thuộc các thư viện cần thiết từ Core (Model, DesignSystem...).
//
// 3. TARGET APP (:ChiTieu):
//    - Đóng vai trò Orchestrator (lắp ghép).
//    - Phụ thuộc Features và các Core product cần thiết để dựng Navigation Graph và App Lifecycle.
//    - KHÔNG chứa trực tiếp logic nghiệp vụ hay data layer.
// ==============================================================================
//

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS("26.0"),
        .macOS(.v26),
    ],
    products: [
        .library(name: "Model", targets: ["Model"]),
        .library(name: "Parser", targets: ["Parser"]),
        .library(name: "Data", targets: ["Data"]),
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
        .library(name: "CoreTesting", targets: ["CoreTesting"]),
    ],
    targets: [
        .target(name: "Model"),
        .testTarget(name: "ModelTests", dependencies: ["Model"]),

        .target(name: "Parser", dependencies: ["Model"]),
        .testTarget(name: "ParserTests", dependencies: ["Parser"]),

        .target(name: "Data", dependencies: ["Model"]),
        .testTarget(name: "DataTests", dependencies: ["Data"]),

        .target(
            name: "DesignSystem",
            dependencies: ["Model"],
            resources: [.process("Resources")],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        ),
        .testTarget(name: "DesignSystemTests", dependencies: ["DesignSystem"]),

        .target(name: "CoreTesting", dependencies: ["Model"]),
        .testTarget(name: "CoreTestingTests", dependencies: ["CoreTesting"]),
    ]
)
