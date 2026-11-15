//
//  BudgetTests.swift
//  Features
//
//  Created by Le Hung on 14/11/26.
//

import Testing
@testable import Budget

@MainActor
@Test func testBudgetInit() {
    let _ = BudgetView()
    #expect(true)
}
