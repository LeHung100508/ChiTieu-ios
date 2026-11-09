//
//  BookStore.swift
//  SachDoc
//
//  Created by Le Hung on 9/11/26.
//
import SwiftUI

@Observable
final class BookStore {
    var books: [BookItem] = []
    
    init(books: [BookItem] = BookItem.samples) {
        self.books = books
    }
    
    func addBook(_ book: BookItem) {
        books.append(book)
    }
    
    func updateBook(_ book: BookItem) {
        if let index = books.firstIndex(where: { $0.id == book.id}) {
            books[index] = book
        }
    }
    
    func book(for bookId: UUID) -> BookItem? {
        return books.first { $0.id == bookId }
    }
}
