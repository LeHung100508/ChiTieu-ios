import Testing
import Foundation
@testable import SwiftCoBan

struct CodableTests {
    
    @Test("parseBooks giải mã thành công JSON hợp lệ có trường optional")
    func testParseValidBooksJSON() throws {
        let json = """
        [
            {
                "book_id": "B01",
                "book_title": "Swift 6 Mastery",
                "published_year": 2026
            },
            {
                "book_id": "B02",
                "book_title": "SwiftUI in Depth",
                "published_year": null
            },
            {
                "book_id": "B03",
                "book_title": "SwiftUI"
            }
        ]
        """
        
        let books = try parseBooks(from: json)
        #expect(books.count == 3)
        #expect(books[0] == BookDTO(id: "B01", title: "Swift 6 Mastery", publishedYear: 2026))
        #expect(books[1] == BookDTO(id: "B02", title: "SwiftUI in Depth", publishedYear: nil))
        #expect(books[2] == BookDTO(id: "B03", title: "SwiftUI", publishedYear: nil))
    }
    
    @Test("parseBooks ném lỗi DecodingError cụ thể khi JSON sai định dạng hoặc thiếu khóa")
    func testParseInvalidJSON() {
        // TH1: JSON sai cú pháp -> bắt buộc phải ném DecodingError.dataCorrupted
        let malformedJson = """
        [ { "book_id": "B01"
        """
        #expect{
            try parseBooks(from: malformedJson)
        } throws: { error in
            guard case DecodingError.dataCorrupted = error else { return false }
            return true
        }
        
        // TH2: JSON thiếu khóa bắt buộc "book_title" -> bắt buộc phải ném DecodingError.keyNotFound
        let missingKeyJson = """
        [
            { "book_id": "B01" }
        ]
        """
        #expect {
            try parseBooks(from: missingKeyJson)
        } throws: { error in
            guard case DecodingError.keyNotFound(let key, _) = error else { return false }
            return key.stringValue == "book_title" // Kiểm tra chính xác khóa bị thiếu
        }
    }
    
    @Test("parseBooks đọc và giải mã thành công từ file books.json trong Bundle.module")
    func testParseBooksFromFile() throws {
        // 1. Lấy URL của file books.json từ Bundle.module:
        let fileURL = try #require(
            Bundle.module.url(forResource: "books", withExtension: "json"),
            "Không tìm thấy file books.json trong Bundle.module"
        )
        
        // 2. Đọc Data từ file URL:
        let data = try Data(contentsOf: fileURL)
        
        // 3. Decode và kiểm tra:
        let books = try parseBooks(from: data)
        #expect(books.count == 3)
        #expect(books[0].id == "B01")
        #expect(books[0].publishedYear == 2026)
        #expect(books[1].publishedYear == nil)
        #expect(books[2].publishedYear == nil)
    }
}
