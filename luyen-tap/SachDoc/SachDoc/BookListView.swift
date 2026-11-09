import SwiftUI

struct BookListView: View {
    @Binding var books: [BookItem]
    var body: some View {
        if books.isEmpty {
            ContentUnavailableView("Chưa có sách nào", systemImage: "book.closed")
        } else {
            List {
                ForEach($books) { $book in
                    BookRowView(book: $book)
                }
            }
        }
    }
}

#Preview("Có dữ liệu") {
    @Previewable @State var books = BookItem.samples
    NavigationStack {
        BookListView(books: $books).navigationTitle("Sách đang đọc")
    }
}

#Preview("Chưa có dữ liệu") {
    @Previewable @State var emptyBooks: [BookItem] = []
    NavigationStack {
        BookListView(books: $emptyBooks).navigationTitle("Sách đang đọc")
    }
}
