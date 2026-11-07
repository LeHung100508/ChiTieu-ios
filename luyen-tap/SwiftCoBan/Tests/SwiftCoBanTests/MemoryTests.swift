import Testing
@testable import SwiftCoBan

struct MemoryTests {
    
    @Test("Hai đối tượng tham chiếu nhau được giải phóng thành công nhờ weak")
    func testWeakReferenceBreaksCycle() {
        var isAuthorDeallocated = false
        var isBookDeallocated = false
        
        // Khối do { ... } tạo một phạm vi scope cục bộ:
        do {
            let author = Author(name: "Nguyễn Nhật Ánh")
            let book = BookDetail(title: "Mắt Biếc")
            
            author.onDeinit = { isAuthorDeallocated = true }
            book.onDeinit = { isBookDeallocated = true }
            
            // Thiết lập quan hệ 2 chiều:
            author.book = book
            book.author = author
            
            #expect(book.author != nil)
            #expect(author.book != nil)
        } // Hết scope khối do, các biến author và book cục bộ bị hủy
        
        // Kiểm tra xem deinit có được gọi hay không:
        #expect(isAuthorDeallocated == true, "Author bị rò rỉ bộ nhớ!")
        #expect(isBookDeallocated == true, "BookDetail bị rò rỉ bộ nhớ!")
    }
    
    @Test("Closure dùng [weak self] không làm rò rỉ PageViewer")
    func testClosureWeakSelf() {
        var isViewerDeallocated = false
        
        do {
            let viewer = PageViewer(pageNumber: 1)
            viewer.onDeinit = { isViewerDeallocated = true }
            viewer.setupAction()
            
            // Gọi closure để kiểm tra hoạt động:
            viewer.onPageChange?()
            #expect(viewer.pageNumber == 2)
        }
        
        #expect(isViewerDeallocated == true, "PageViewer bị closure giữ lại gây retain cycle!")
    }
    
    @Test("Hai đối tượng có quan hệ gắn liền được giải phóng nhờ unowned")
    func testUnownedReferenceBreaksCycle() {
        var isBookDeallocated = false
        var isBookmarkDeallocated = false
        
        do {
            let book = Book(title: "Nhà Giả Kim")
            let bookmark = Bookmark(page: 42, book: book)
            book.bookmark = bookmark
            
            book.onDeinit = { isBookDeallocated = true }
            bookmark.onDeinit = { isBookmarkDeallocated = true }
            
            // Truy cập trực tiếp qua unowned không cần unwrap (vì không phải Optional):
            #expect(bookmark.book.title == "Nhà Giả Kim")
        } // Hết scope do { ... }, cả book và bookmark đều phải được giải phóng
        
        #expect(isBookDeallocated == true, "Book bị rò rỉ bộ nhớ!")
        #expect(isBookmarkDeallocated == true, "Bookmark bị rò rỉ bộ nhớ!")
    }
}
