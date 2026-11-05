import Testing
@testable import SwiftCoBan

struct OptionalTests {
    
    @Test("safeLength trả về đúng độ dài chuỗi hoặc 0 khi nil")
    func testSafeLength() {
        #expect(safeLength(of: "Xin chào") == 8)
        #expect(safeLength(of: nil) == 0)
    }
    
    @Test("parseAge chỉ nhận số nguyên không âm")
    func testParseAge() {
        #expect(parseAge(from: "25") == 25)
        #expect(parseAge(from: "-5") == nil)
        #expect(parseAge(from: "0") == 0)
        #expect(parseAge(from: "abc") == nil)
        #expect(parseAge(from: nil) == nil)
        
    }
    
    @Test("getStreetName xử lý đúng các trường hợp optional lồng nhau")
    func testGetStreetName() {
        // TH1: user có address và có street "Nguyễn Huệ"
        // TH2: user có address nhưng street là nil
        // TH3: user có address là nil
        // TH4: user là nil
        
        let user1 = UserProfile(name: "Hưng", address: Address(street: "Nguyễn Huệ"))
        let user2 = UserProfile(name: "Hưng", address: Address(street: nil))
        let user3 = UserProfile(name: "Hưng", address: nil)
        #expect(getStreetName(of: user1) == "Nguyễn Huệ")
        #expect(getStreetName(of: user2) == "Không có địa chỉ")
        #expect(getStreetName(of: user3) == "Không có địa chỉ")
        #expect(getStreetName(of: nil) == "Không có địa chỉ")
    }
}
