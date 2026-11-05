// 1. Struct (Value Type):
// Yêu cầu:
//   - Thuộc tính `title: String`, `isRead: Bool` (mặc định false).
//   - Phương thức `mutating func markAsRead()` đổi isRead thành true.
//   (Lưu ý: struct bắt buộc phải có từ khóa `mutating` mới được sửa thuộc tính của chính nó).
public struct BookStruct {
    public var title: String
    public var isRead: Bool
    
    public init(title: String, isRead: Bool = false) {
        self.title = title
        self.isRead = isRead
    }
    
    public mutating func markAsRead() {
        isRead = true
    }
}

// 2. Class (Reference Type):
// Yêu cầu:
//   - Thuộc tính tương tự `BookStruct`.
//   - Phương thức `func markAsRead()` đổi isRead thành true (class không cần từ khóa mutating).
public final class BookClass {
    public var title: String
    public var isRead: Bool
    
    public init(title: String, isRead: Bool = false) {
        self.title = title
        self.isRead = isRead
    }
    
    public func markAsRead() {
        isRead = true
    }
}
