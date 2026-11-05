public protocol IdentifiableItem {
    var id: String { get }
    func displayLabel() -> String
}

public extension IdentifiableItem {
    func displayLabel() -> String {
        return "Mục #\(id)"
    }
}

public struct BookItem: IdentifiableItem {
    public var id: String
    public init(id: String) { self.id = id }
}

public struct ArticleItem: IdentifiableItem {
    public var id: String
    public var title: String
    
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
    
    public func displayLabel() -> String {
        return "Bài báo: \(title)"
    }
}

public func findFirstMatch<T: IdentifiableItem>(in items: [T], matchingId id: String) -> T? {
    return items.first { $0.id == id }
}

// Opaque Type (`some`): Hàm luôn trả về một kiểu cụ thể duy nhất (BookItem)
// nhưng giấu kiểu cụ thể đó, caller chỉ biết nó là IdentifiableItem.
public func makeDefaultItem() -> some IdentifiableItem {
    return BookItem(id: "DEFAULT")
}

// Existential Type (`any`): Nhận vào một mảng dị thể (heterogeneous array)
// chứa các đối tượng có kiểu khác nhau (cả BookItem lẫn ArticleItem) cùng tuân thủ IdentifiableItem.
public func getDisplayLabels(from items: [any IdentifiableItem]) -> [String] {
    return items.map { $0.displayLabel() }
}
