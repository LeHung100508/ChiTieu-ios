// Sources/SwiftCoBan/ActorPractice.swift

public actor BookInventory {
    // 1. Trạng thái nội bộ được bảo vệ bởi Actor Isolation:
    private var stock: [String: Int] = [:]

    public init() {}

    // 2. Cập nhật số lượng sách:
    public func setStock(bookId: String, count: Int) {
        stock[bookId] = count
    }

    // 3. Lấy số lượng tồn kho (trả về 0 nếu sách chưa có trong kho):
    public func getStock(bookId: String) -> Int {
        return stock[bookId] ?? 0
    }

    // 4. Mua sách: Nếu còn sách (> 0) thì trừ 1 và trả về true, ngược lại trả về false:
    public func purchase(bookId: String) -> Bool {
        guard let count = stock[bookId], count > 0 else {
            return false
        }
        stock[bookId] = count - 1
        return true
    }
}

// 5. ViewModel quản lý trạng thái UI, được cô lập trên Main Thread:
@MainActor
public final class BookViewModel {
    public private(set) var titles: [String] = []

    public init() {}

    public func addTitle(_ title: String) {
        titles.append(title)
    }
}

public struct SafeBookRecord: Sendable {
    public var title: String
    public init(title: String) { self.title = title }
}

public func processSafeRecord(record: SafeBookRecord) async -> String {
    let task = Task {
        return "Đã xử lý: \(record.title)"
    }
    return await task.value
}

public actor ReaderStatistics {
    public private(set) var activeReaders: Int = 0
    public init() {}
    public func increment() { activeReaders += 1 }
    public func decrement() { activeReaders -= 1 }
}

// Cách 1: Dùng async để có điểm await chuyển sang Main Thread
public func getTitleCountAsync(viewModel: BookViewModel) async -> Int {
    return await viewModel.titles.count
}

// Cách 2: Nếu hàm thuộc UI, gắn trực tiếp @MainActor
@MainActor
public func getTitleCountMain(viewModel: BookViewModel) -> Int {
    return viewModel.titles.count
}
