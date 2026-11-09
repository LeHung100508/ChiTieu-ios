import SwiftUI

struct BookListView: View {
    @Bindable var store: BookStore
    @State private var isShowingAddSheet = false
    var body: some View {
        Group {
            if store.books.isEmpty {
                ContentUnavailableView("Chưa có sách nào", systemImage: "book.closed")
            } else {
                List {
                    ForEach($store.books) { $book in
                        NavigationLink(value: book.id) {
                            BookRowView(book: $book)
                        }
                    }
                }
            }
        }.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }.accessibilityLabel("Thêm sách mới")
            }
        }.sheet(isPresented: $isShowingAddSheet) {
            BookFormView(navigationTitle: "Thêm sách mới") { newBook in
                store.addBook(newBook)
            }
        }.navigationDestination(for: UUID.self) { bookId in
            BookDetailView(bookId: bookId, store: store)
        }
    }
}

#Preview("Có dữ liệu") {
    @Previewable @State var store = BookStore()
    NavigationStack {
        BookListView(store: store).navigationTitle("Sách đang đọc")
    }
}

#Preview("Chưa có dữ liệu") {
    @Previewable @State var store = BookStore(books: [])
    NavigationStack {
        BookListView(store: store).navigationTitle("Sách đang đọc")
    }
}
