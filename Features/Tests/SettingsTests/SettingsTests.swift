//
//  SettingTests.swift
//  Features
//
//  Created by Le Hung on 14/11/26.
//

import Testing
@testable import Settings

@MainActor
@Test func testSettingsInit() {
    let _ = SettingsView()
    #expect(true)
}
