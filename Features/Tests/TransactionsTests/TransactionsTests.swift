//
//  TransactionsTests.swift
//  Features
//
//  Created by Le Hung on 14/11/26.
//

import Testing

@testable import Transactions

@MainActor
@Test func testTransactionsInit() {
    _ = TransactionsView()
    #expect(true)
}
