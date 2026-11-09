// SachDoc/BookFormView.swift

import SwiftUI

struct BookFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Biến state tạm thời để người dùng chỉnh sửa trong form:
    @State private var book: BookItem
    let navigationTitle: String
    let onSave: (BookItem) -> Void
    
    init(book: BookItem = BookItem(title: "", author: "", isRead: false),
         navigationTitle: String,
         onSave: @escaping (BookItem) -> Void) {
        _book = State(initialValue: book)
        self.navigationTitle = navigationTitle
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Thông tin cơ bản") {
                    TextField("Tên sách", text: $book.title)
                    TextField("Tác giả", text: $book.author)
                }
                
                Section("Trạng thái đọc") {
                    Toggle("Đã đọc xong", isOn: $book.isRead)
                }
                
                Section("Ghi chú") {
                    TextField("Cảm nghĩ về cuốn sách...", text: $book.note, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") {
                        onSave(book)
                        dismiss()
                    }
                    .disabled(book.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    BookFormView(navigationTitle: "Thêm Sách") { _ in }
}
