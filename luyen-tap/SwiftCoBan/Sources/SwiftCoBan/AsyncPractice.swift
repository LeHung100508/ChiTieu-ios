public enum BookStoreError: Error, Equatable {
    case bookNotFound
}

// 1. Giả lập tác vụ bất đồng bộ lấy giá sách:
public func fetchBookPrice(bookId: String) async throws -> Int {
    // Tạm dừng 50ms không chặn luồng:
    try await Task.sleep(for: .milliseconds(50))
    
    switch bookId {
    case "B01": return 100_000
    case "B02": return 150_000
    default: throw BookStoreError.bookNotFound
    }
}

// 2. Chạy tuần tự (Sequential): Xong tác vụ 1 rồi mới tới tác vụ 2
public func fetchTotalPriceSequential(id1: String, id2: String) async throws -> Int {
    let price1 = try await fetchBookPrice(bookId: id1)
    let price2 = try await fetchBookPrice(bookId: id2)
    return price1 + price2
}

// 3. Chạy song song (Concurrent) bằng `async let`:
public func fetchTotalPriceConcurrent(id1: String, id2: String) async throws -> Int {
    async let price1 = fetchBookPrice(bookId: id1)
    async let price2 = fetchBookPrice(bookId: id2)
    return try await price1 + price2
}

// 4. Tác vụ dài có kiểm tra hủy (Cancellation):
public func processLongRunningTask(totalSteps: Int) async throws -> Int {
    var completedSteps = 0
    for _ in 1...totalSteps {
        // Kiểm tra xem tác vụ cha có gửi tín hiệu hủy không:
        try Task.checkCancellation()
        
        try await Task.sleep(for: .milliseconds(20))
        completedSteps += 1
    }
    return completedSteps
}

// Vòng lặp tính toán thuần túy (không có Task.sleep hay await ném lỗi):
public func computeWithCancellationCheck(totalSteps: Int) throws -> Int {
    var completed = 0
    for _ in 1...totalSteps {
        try Task.checkCancellation()
        completed += 1
    }
    return completed
}

// Hoặc biến thể đếm bước với Task.isCancelled:
public func countStepsUntilCancelled(totalSteps: Int) -> Int {
    var completed = 0
    for _ in 1...totalSteps {
        if Task.isCancelled { break }
        completed += 1
    }
    return completed
}
