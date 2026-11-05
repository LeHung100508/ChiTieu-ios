import Testing
@testable import SwiftCoBan

struct EnumTests {
    
    @Test("formatDescription trả về đúng định dạng cho từng loại sách")
    func testFormatDescription() {
        let paper = BookFormat.paper(pages: 350)
        let ebook = BookFormat.ebook(sizeMB: 2.5)
        let audiobook = BookFormat.audioBook(durationMinutes: 120)
        
        #expect(formatDescription(paper) == "Sách giấy: 350 trang")
        #expect(formatDescription(ebook) == "Sách điện tử: 2.5 MB")
        #expect(formatDescription(audiobook) == "Sách nói: 120 phút")
    
        
        
    }
}
