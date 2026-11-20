//
//  File.swift
//  Core
//
//  Created by Le Hung on 14/11/26.
//

import Foundation
import Testing

@testable import Model

@Test func testMoneyOperations() {
    let money1: Money = 30_000
    let money2: Money = 20_000

    #expect(money1 + money2 == 50_000)
    #expect(money1 - money2 == 10_000)
    #expect(money1 > money2)
    #expect(money1.description == "30000")
}

@Test func testParsedFieldClamping() {
    let fieldHigh = ParsedField("test", confidence: 1.5)
    #expect(fieldHigh.confidence == 1.0)

    let fieldLow = ParsedField("test", confidence: -0.5)
    #expect(fieldLow.confidence == 0.0)
}

@Test func testParsedTransactionCodable() throws {
    let transaction = ParsedTransaction(
        type: .transfer,
        amount: ParsedField(45_000, confidence: 0.95),
        categoryKey: nil,
        datetime: ParsedField(Date(timeIntervalSince1970: 1_700_000_000), confidence: 1.0),
        wallet: nil,
        sourceWallet: ParsedField("vcb", confidence: 0.9),
        targetWallet: ParsedField("cash", confidence: 0.9),
        note: ParsedField("rút tiền", confidence: 0.85)
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(transaction)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(ParsedTransaction.self, from: data)

    #expect(decoded.type == .transfer)
    #expect(decoded.amount?.value == 45_000)
    #expect(decoded.amount?.confidence == 0.95)
    #expect(decoded.sourceWallet?.value == "vcb")
    #expect(decoded.targetWallet?.value == "cash")
    #expect(decoded.note?.value == "rút tiền")
}
