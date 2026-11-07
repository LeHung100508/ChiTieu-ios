import Testing
@testable import SwiftCoBan

struct AsyncTests {
    
    @Test("fetchTotalPrice chạy đúng cho cả cách tuần tự và song song async let")
    func testFetchPrices() async throws {
        // Cả 2 cách đều phải ra cùng kết quả tổng tiền:
        let totalSeq = try await fetchTotalPriceSequential(id1: "B01", id2: "B02")
        let totalCon = try await fetchTotalPriceConcurrent(id1: "B01", id2: "B02")
        
        #expect(totalSeq == 250_000)
        #expect(totalCon == 250_000)
    }
    
    @Test("processLongRunningTask hoàn thành đủ bước khi không bị hủy")
    func testTaskCompletesNormally() async throws {
        let steps = try await processLongRunningTask(totalSteps: 3)
        #expect(steps == 3)
    }
    
    @Test("task bị hủy thì ném CancellationError")
    func testTaskCancellation() async {
        // 1. Tạo tác vụ chạy nền với số bước lớn:
        let task = Task {
            try await processLongRunningTask(totalSteps: 100)
        }
        
        // 2. Gửi tín hiệu hủy tác vụ:
        task.cancel()
        
        // 3. Dùng Swift Testing để kiểm tra task ném đúng CancellationError:
        await #expect(throws: CancellationError.self) {
            try await task.value
        }
    }
    
    @Test("Task bị hủy ném CancellationError chỉ do Task.checkCancellation")
    func testTaskCheckCancellation() async {
        let task = Task {
            try computeWithCancellationCheck(totalSteps: 1_000_000)
        }
        task.cancel()
        await #expect(throws: CancellationError.self) {
            try await task.value
        }
    }

    @Test("fetchTotalPrice ném BookStoreError.bookNotFound khi id không tồn tại")
    func testFetchPriceNotFound() async {
        await #expect(throws: BookStoreError.bookNotFound) {
            try await fetchTotalPriceSequential(id1: "UNKNOWN", id2: "B01")
        }
        await #expect(throws: BookStoreError.bookNotFound) {
            try await fetchTotalPriceConcurrent(id1: "B01", id2: "UNKNOWN")
        }
    }
    
    @Test("Task bị hủy với Task.isCancelled dừng sớm và trả về số bước nhỏ hơn totalSteps")
    func testCountStepsUntilCancelled() async {
        let task = Task {
            countStepsUntilCancelled(totalSteps: 1_000_000)
        }
        task.cancel()
        let steps = await task.value
        #expect(steps < 1_000_000)
    }
}
