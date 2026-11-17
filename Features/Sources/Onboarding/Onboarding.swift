//
//  Onboarding.swift
//  Features
//
//  Created by Le Hung on 14/11/26.
//

import DesignSystem
import Model
import SwiftUI

@MainActor
public struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Text("OnboardingView")
            Button("Bỏ qua") {
                dismiss()
            }
        }
    }

}
