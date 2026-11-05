import Testing
@testable import SwiftCoBan

struct ProtocolTests {
    
    @Test("displayLabel sử dụng cài đặt mặc định hoặc ghi đè đúng cách")
    func testDisplayLabel() {
        // 1. Tạo một BookItem(id: "B01")
        //    - Dùng #expect kiểm tra item.displayLabel() == "Mục #B01" (dùng mặc định từ extension)
        
        let book = BookItem(id: "B01")
        let article = ArticleItem(id: "A01", title: "Học Swift")
        
        #expect(book.displayLabel() == "Mục #B01")
        #expect(article.displayLabel() == "Bài báo: Học Swift")
        
        // 2. Tạo một ArticleItem(id: "A01", title: "Học Swift")
        //    - Dùng #expect kiểm tra item.displayLabel() == "Bài báo: Học Swift" (đã ghi đè)
    }
    
    @Test("findFirstMatch tìm đúng phần tử theo id trong mảng generic")
    func testFindFirstMatch() {
        // 1. Tạo mảng các BookItem mẫu (ví dụ có id: "1", "2", "3")
        // 2. Kiểm tra tìm id "2" -> #expect(kết quả?.id == "2")
        // 3. Kiểm tra tìm id "99" (không tồn tại) -> #expect(kết quả == nil)
        
    
        let array = [BookItem(id: "1"), BookItem(id: "2"), BookItem(id: "3")]
        #expect(findFirstMatch(in: array, matchingId: "2")?.id == "2")
        #expect(findFirstMatch(in: array, matchingId: "99") == nil)
    }
    
    @Test("some và any thể hiện đúng hành vi Opaque Type và Existential Type")
    func testSomeAndAny() {
        // 1. Kiểm tra hàm trả về `some IdentifiableItem`
        let defaultItem = makeDefaultItem()
        #expect(defaultItem.displayLabel() == "Mục #DEFAULT")
        
        // 2. Kiểm tra mảng dị thể [any IdentifiableItem] chứa cả BookItem và ArticleItem
        let mixedItems: [any IdentifiableItem] = [
            BookItem(id: "1"),
            ArticleItem(id: "2", title: "Swift 6")
        ]
        let labels = getDisplayLabels(from: mixedItems)
        #expect(labels == ["Mục #1", "Bài báo: Swift 6"])
    }
}
