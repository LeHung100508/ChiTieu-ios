// 1. Hàm tính độ dài an toàn:
// Yêu cầu: Nếu text có giá trị thì trả về text.count, nếu nil thì trả về 0.
// Gợi ý: Dùng toán tử ?? hoặc if let.
public func safeLength(of text: String?) -> Int {
    guard let text else { return 0 }
    return text.count
}

// 2. Hàm trích xuất tuổi hợp lệ:
// Yêu cầu:
//   - Dùng `guard let` để unwrap text và chuyển sang Int bằng Int(text).
//   - Kiểm tra thêm điều kiện tuổi >= 0.
//   - Hợp lệ: trả về Int tuổi; Không hợp lệ (nil, chữ, số âm): return nil.
public func parseAge(from text: String?) -> Int? {
    guard let text, let age = Int(text), age >= 0 else {
        return nil
    }
    
    return age
}

// 3. Hai struct lồng nhau để luyện Optional Chaining:
public struct Address {
    public var street: String?
    
    public init(street: String? = nil) {
        self.street = street
    }
}

public struct UserProfile {
    public var name: String
    public var address: Address?
    
    public init(name: String, address: Address? = nil) {
        self.name = name
        self.address = address
    }
}

// 4. Hàm lấy tên đường qua chuỗi optional:
// Yêu cầu: Dùng optional chaining `user?.address?.street` kết hợp toán tử `??`.
//   - Có tên đường: trả về tên đường.
//   - Bất kỳ mắt xích nào nil: trả về "Không có địa chỉ".
public func getStreetName(of user: UserProfile?) -> String {
    return user?.address?.street ?? "Không có địa chỉ"
}
