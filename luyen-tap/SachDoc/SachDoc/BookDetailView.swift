import SwiftUI


struct BookDetailView: View {
    let bookId: UUID
    let store: BookStore
    @State private var isShowingEditSheet = false
    var book: BookItem? {
        store.book(for: bookId)
    }
    var body: some View {
        if let book {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(book.title)
                            .font(.title.bold())
                        Text(book.author)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text(book.isRead ? "Đã đọc xong" : "Chưa đọc")
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                book.isRead ? Color.green : Color.orange
                            )
                            .clipShape(Capsule())
                    }
                        
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ghi chú")
                            .font(.headline)
                        Text(
                            book.note.isEmpty ? "Chưa có ghi chú nào cho cuốn sách này." : book.note
                        )
                        .font(.body)
                        .foregroundStyle(
                            book.note.isEmpty ? .secondary : .primary
                        )
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle(book.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sửa") {
                        isShowingEditSheet = true
                    }
                }
            }.sheet(isPresented: $isShowingEditSheet) {
                BookFormView(
                    book: book,
                    navigationTitle: "Chỉnh sửa sách"
                ) { updatedBook in
                    store.updateBook(updatedBook)
                }
            }
        } else {
            ContentUnavailableView(
                "Sách không tồn tại",
                systemImage: "books.vertical"
            )
        }
    }
}

#Preview {
    @Previewable @State var store = BookStore()
    NavigationStack {
        BookDetailView(bookId: BookItem.samples[0].id, store: store)
    }
}
