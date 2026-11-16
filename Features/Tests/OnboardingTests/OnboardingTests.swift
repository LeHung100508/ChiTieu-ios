//
//  OnboardingTests.swift
//  Features
//
//  Created by Le Hung on 14/11/26.
//

import Testing

@testable import Onboarding

@MainActor
@Test func testOnboardingInit() {
    _ = OnboardingView()
    #expect(true)
}
