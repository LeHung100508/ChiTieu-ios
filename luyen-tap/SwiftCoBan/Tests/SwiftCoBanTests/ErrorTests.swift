import Testing
@testable import SwiftCoBan

struct ErrorTests {
    @Test("divide hoạt động đúng và ném Typed Error khi chia cho 0")
    func testDivide() throws {
        #expect(try divide(10, by: 2) == 5)
        #expect(throws: MathError.divisionByZero) {
            try divide(10, by: 0)
        }
    }
    
    @Test("safeSquareRoot trả về đúng Result success hoặc failure")
    func testSquareRoot() {
        #expect(safeSquareRoot(9.0) == .success(3.0))
        #expect(safeSquareRoot(-1.0) == .failure(.negativeValue))
    }
}
