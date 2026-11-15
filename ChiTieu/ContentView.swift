//
//  ContentView.swift
//  ChiTieu
//
//  Created by Le Hung on 14/11/26.
//

import SwiftUI
import QuickAdd
import Transactions
import Budget
import Stats
import Settings
import Onboarding

struct ContentView: View {
    @State private var showingSettings = false
    @State private var showingOnboarding = false

    var body: some View {
        TabView {
            Tab("Tổng quan", systemImage: "house") {
                NavigationStack {
                    QuickAddView()
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Onboarding") {
                                    showingOnboarding = true
                                }
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showingSettings = true
                                } label: {
                                    Image(systemName: "gearshape")
                                }
                            }
                        }
                }
            }

            Tab("Giao dịch", systemImage: "list.bullet.rectangle") {
                TransactionsView()
            }

            Tab("Ngân sách", systemImage: "chart.bar.fill") {
                BudgetView()
            }

            Tab("Thống kê", systemImage: "chart.pie.fill") {
                StatsView()
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
