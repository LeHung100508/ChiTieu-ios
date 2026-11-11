//
//  BookRowView.swift
//  SachDoc
//
//  Created by Le Hung on 8/11/26.
//

import SwiftUI

struct BookRowView: View {
    @Binding var book: BookItem
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title).font(.headline)
                Text(book.author).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Text(book.isRead ? "Đã đọc" : "Chưa đọc")
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(book.isRead ? Color.green : Color.gray)
                .clipShape(Capsule())
            Spacer()
            Button {
                book.isRead.toggle()
            } label: {
                Image(systemName: book.isRead ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(book.isRead ? .green : .gray)
            }.buttonStyle(.borderless)
        }
    }
}

#Preview("Tương tác Toggle") {
    @Previewable @State var book = BookItem.samples[0]
    BookRowView(book: $book)
        .padding()
}

#Preview("Tên sách rất dài") {
    @Previewable @State var book = BookItem(
        title: "Cuốn sách có tiêu đề rất dài để kiểm tra bố cục hiển thị trên nhiều dòng không bị đè lên nút",
        author: "Tác giả có tên cũng tương đối dài",
        isRead: false
    )
    BookRowView(book: $book)
        .padding()
}

#Preview("Thử nghiệm thứ tự modifier") {
    VStack(spacing: 20) {
        // Cách A: Padding trước -> Background sau (Chuẩn: màu phủ trọn vùng đệm)
        Text("Đúng: Padding trước")
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green)
            .clipShape(Capsule())

        // Cách B: Background trước -> Padding sau (Lỗi: màu bó sát chữ, padding trong suốt)
        Text("Sai: Background trước")
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .background(Color.green)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .clipShape(Capsule())
    }
}
