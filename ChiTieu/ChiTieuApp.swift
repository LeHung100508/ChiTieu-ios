//
//  ChiTieuApp.swift
//  ChiTieu
//
//  Created by Le Hung on 14/11/26.
//

import Model
import Parser
import SwiftUI
import os

private let logger = Logger(subsystem: "hung.lct.chitieu", category: "App")

@main
struct ChiTieuApp: App {
    private let parserConfiguration: ParserConfiguration?

    init() {
        self.parserConfiguration = Self.loadParserConfiguration()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(parserConfiguration: parserConfiguration)
        }
    }

    private static func loadParserConfiguration() -> ParserConfiguration? {
        guard let url = Bundle.main.url(forResource: "category_keywords", withExtension: "json") else {
            logger.error("Không tìm thấy file category_keywords.json trong Bundle.main")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            let dictionary = try CategoryDictionary(data: data)
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? .current
            let defaultWallets = [
                WalletAlias(key: "cash", aliases: ["tiền mặt", "ví tiền mặt", "tien mat"])
            ]
            return ParserConfiguration(dictionary: dictionary, wallets: defaultWallets, calendar: calendar)
        } catch {
            logger.error("Lỗi nạp hoặc giải mã category_keywords.json: \(error.localizedDescription)")
            return nil
        }
    }
}
