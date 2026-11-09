//
//  ContentView.swift
//  SachDoc
//
//  Created by Le Hung on 4/11/26.
//

import SwiftUI

struct ContentView: View {
    @State private var books: [BookItem] = BookItem.samples
    var body: some View {
        NavigationStack {
            BookListView(books: $books).navigationTitle("Sách đang đọc")
        }
    }
}

#Preview {
    ContentView()
}
