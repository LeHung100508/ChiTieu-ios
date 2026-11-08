// Tests/SwiftCoBanTests/ActorTests.swift

import Testing
@testable import SwiftCoBan

struct ActorTests {

    @Test("BookInventory đảm bảo không bị data race khi 100 tác vụ mua đồng thời")
    func testConcurrentPurchases() async {
        let inventory = BookInventory()
        await inventory.setStock(bookId: "B01", count: 100)

        // Dùng withTaskGroup chạy 100 task con cùng gọi purchase:
        let successfulPurchases = await withTaskGroup(of: Bool.self) { group in
            for _ in 1...100 {
                group.addTask {
                    await inventory.purchase(bookId: "B01")
                }
            }
            
            var successCount = 0
            for await success in group {
                if success { successCount += 1 }
            }
            return successCount
        }

        // Cả 100 lần mua đều thành công và kho sách về đúng 0:
        #expect(successfulPurchases == 100)
        #expect(await inventory.getStock(bookId: "B01") == 0)
    }

    @Test("BookViewModel được cô lập trên MainActor và yêu cầu await từ background")
    func testMainActorViewModel() async {
        let viewModel = await BookViewModel()

        // Gọi từ một background Task (detached):
        await Task.detached {
            await viewModel.addTitle("Swift 6 Concurrency")
            let count = await viewModel.titles.count
            #expect(count == 1)
        }.value
    }
    
    @Test("SafeBookRecord gửi an toàn qua Task con nhờ Sendable")
    func testSendableRecord() async {
        let record = SafeBookRecord(title: "Học Swift 6")
        let result = await processSafeRecord(record: record)
        #expect(result == "Đã xử lý: Học Swift 6")
    }

    @Test("ReaderStatistics quản lý biến đếm toàn cục an toàn trên actor")
    func testReaderStatistics() async {
        let stats = ReaderStatistics()
        await stats.increment()
        #expect(await stats.activeReaders == 1)
    }

    @Test("getTitleCountAsync đọc an toàn từ BookViewModel qua await")
    func testMainActorAsyncAccess() async {
        let vm = await BookViewModel()
        await vm.addTitle("Sach A")
        let count = await getTitleCountAsync(viewModel: vm)
        #expect(count == 1)
    }

    @Test("BookInventory trả về false khi mua sách đã hết hàng")
    func testPurchaseOutOfStock() async {
        let inventory = BookInventory()
        await inventory.setStock(bookId: "B02", count: 0)
        let success = await inventory.purchase(bookId: "B02")
        #expect(!success)
    }
    
    @Test("BookInventory ngăn chặn bán quá số lượng khi nhu cầu lớn hơn tồn kho")
    func testCheckThenActOverselling() async {
        let inventory = BookInventory()
        await inventory.setStock(bookId: "B03", count: 50)

        let successfulPurchases = await withTaskGroup(of: Bool.self) { group in
            for _ in 1...100 {
                group.addTask {
                    await inventory.purchase(bookId: "B03")
                }
            }
            var count = 0
            for await success in group {
                if success { count += 1 }
            }
            return count
        }

        #expect(successfulPurchases == 50)
        #expect(await inventory.getStock(bookId: "B03") == 0)
    }
}
