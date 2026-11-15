//
//  StatsTests.swift
//  Features
//
//  Created by Le Hung on 14/11/26.
//

import Testing
@testable import Stats

@MainActor
@Test func testStatsInit() {
    let _ = StatsView()
    #expect(true)
}
