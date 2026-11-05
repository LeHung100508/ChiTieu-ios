import Testing
@testable import SwiftCoBan

struct ValueVsReferenceTests {
    
    @Test("Gán struct tạo bản sao độc lập (Value Type)")
    func testStructCopySemantics() {
        // 1. Khởi tạo `var a = BookStruct(title: "Swift", isRead: false)`
        // 2. Gán `var b = a`
        // 3. Gọi `b.markAsRead()`
        // 4. Dùng #expect để chứng minh:
        //    - b.isRead == true
        //    - a.isRead == false (thay đổi trên b KHÔNG ảnh hưởng tới a)
        
        let a = BookStruct(title: "Swift", isRead: false)
        var b = a
        b.markAsRead()
        #expect(b.isRead == true)
        #expect(a.isRead == false)
    }
    
    @Test("Gán class chia sẻ cùng một đối tượng (Reference Type)")
    func testClassReferenceSemantics() {
        // 1. Khởi tạo `let a = BookClass(title: "Swift", isRead: false)`
        // 2. Gán `let b = a`
        // 3. Gọi `b.markAsRead()`
        // 4. Dùng #expect để chứng minh:
        //    - b.isRead == true
        //    - a.isRead == true (thay đổi trên b LÀM THAY ĐỔI a vì cùng trỏ vào 1 vùng nhớ)
        let a = BookClass(title: "Swift", isRead: false)
        let b = a
        b.markAsRead()
        #expect(b.isRead == true)
        #expect(a.isRead == true)
    }
}
