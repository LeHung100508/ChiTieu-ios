
public final class Author {
    public let name: String
    public var book: BookDetail?
    public var onDeinit: (() -> Void)?
    
    public init(name: String) {
        self.name = name
    }
    
    deinit {
        onDeinit?()
    }
}

public final class BookDetail {
    public let title: String
    // Dùng weak để phá vỡ vòng lặp tham chiếu mạnh (Retain Cycle)
    public weak var author: Author?
    public var onDeinit: (() -> Void)?
    
    public init(title: String) {
        self.title = title
    }
    
    deinit {
        onDeinit?()
    }
}

// Lớp minh họa closure giữ weak self
public final class PageViewer {
    public var pageNumber: Int
    public var onPageChange: (() -> Void)?
    public var onDeinit: (() -> Void)?
    
    public init(pageNumber: Int) {
        self.pageNumber = pageNumber
    }
    
    public func setupAction() {
        
        onPageChange = { [weak self] in
            guard let self else { return }
            self.pageNumber += 1
        }
    }
    
    deinit {
        onDeinit?()
    }
}

// Đối tượng cha (Chủ sở hữu)
public final class Book {
    public let title: String
    public var bookmark: Bookmark?
    public var onDeinit: (() -> Void)?
    
    public init(title: String) {
        self.title = title
    }
    
    deinit {
        onDeinit?()
    }
}

// Đối tượng con gắn liền (Non-optional reference)
public final class Bookmark {
    public var page: Int
    // Dùng `unowned`:
    // 1. Không tăng reference count của Book (bẻ gãy Retain Cycle).
    // 2. Không phải Optional (let book: Book), vì Bookmark bắt buộc luôn phải có Book đi kèm.
    public unowned let book: Book
    public var onDeinit: (() -> Void)?
    
    public init(page: Int, book: Book) {
        self.page = page
        self.book = book
    }
    
    deinit {
        onDeinit?()
    }
}
