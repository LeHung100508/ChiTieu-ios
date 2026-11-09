// SachDoc/Book.swift

import SwiftUI

struct BookItem: Identifiable {
    let id: UUID = UUID()
    var title: String
    var author: String
    var isRead: Bool
    var note: String = ""
}

extension BookItem {
    static let samples: [BookItem] = [
        BookItem(title: "Nhà Giả Kim", author: "Paulo Coelho", isRead: false),
        BookItem(title: "Đắc Nhân Tâm", author: "Dale Carnegie", isRead: true),
        BookItem(title: "Tuổi Trẻ Đáng Giá Bao Nhiêu", author: "Rosie Nguyễn", isRead: false)
    ]
}
