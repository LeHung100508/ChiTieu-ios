import Foundation
// 1. DTO đại diện cho một cuốn sách trong JSON:
public struct BookDTO: Decodable, Equatable {
    public let id: String
    public let title: String
    public let publishedYear: Int? // Trường tùy chọn (có thể null hoặc khuyết)
    
    public init(id: String, title: String, publishedYear: Int? = nil) {
        self.id = id
        self.title = title
        self.publishedYear = publishedYear
    }
    
    // Ánh xạ tên thuộc tính Swift sang tên khóa trong JSON:
    // id -> "book_id"
    // title -> "book_title"
    // publishedYear -> "published_year"
    enum CodingKeys: String, CodingKey {
        case id = "book_id"
        case title = "book_title"
        case publishedYear = "published_year"
    }
}

public func parseBooks(from data: Data) throws -> [BookDTO] {
    return try JSONDecoder().decode([BookDTO].self, from: data)
}

public func parseBooks(from jsonString: String) throws -> [BookDTO] {
    return try parseBooks(from: Data(jsonString.utf8))
}
