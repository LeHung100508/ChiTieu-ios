import Testing
@testable import SwiftCoBan

struct ClosureTests {
    @Test("Các hàm bậc cao map, filter, reduce chạy đúng")
    func testHighOrderFunctions() {
        #expect(squareNumbers([1, 2, 3]) == [1, 4, 9])
        #expect(filterEvenNumbers([1, 2, 3, 4]) == [2, 4])
        #expect(sumOfNumbers([1, 2, 3, 4, 5]) == 15)
    }
}
