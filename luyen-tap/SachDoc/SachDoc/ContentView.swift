//
//  ContentView.swift
//  SachDoc
//
//  Created by Le Hung on 4/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var store = BookStore()
    var body: some View {
        NavigationStack {
            BookListView(store: store).navigationTitle("Sách đang đọc")
        }
    }
}

#Preview {
    ContentView()
}
