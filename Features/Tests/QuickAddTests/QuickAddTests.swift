//
//  QuickAddTests.swift
//  Features
//
//  Created by Le Hung on 14/11/26.
//

import Testing

@testable import QuickAdd

@MainActor
@Test func testQuickAddInit() {
    _ = QuickAddView()
    #expect(true)
}
