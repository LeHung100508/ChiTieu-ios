//
//  Token.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation

/// Loại token phân loại theo nội dung cú pháp.
public enum TokenType: Sendable, Hashable {
    /// Từ hoặc cụm chữ cái.
    case word
    /// Số nguyên hoặc số thập phân/phân cách.
    case number
    /// Dấu câu như dấu phẩy, chấm, hai chấm, chấm phẩy.
    case punctuation
    /// Ký tự xuống dòng.
    case newline
}

/// Một từ hoặc đơn vị cú pháp được bóc tách từ câu người dùng.
public struct Token: Sendable, Hashable {
    /// Từ chuẩn hóa dạng chữ thường.
    public let text: String
    /// Từ chuẩn hóa không dấu tiếng Việt.
    public let unaccented: String
    /// Chỉ số ký tự bắt đầu trong chuỗi raw gốc.
    public let startIndex: Int
    /// Chỉ số ký tự kết thúc trong chuỗi raw gốc.
    public let endIndex: Int
    /// Phân loại token.
    public let type: TokenType

    public init(
        text: String,
        unaccented: String,
        startIndex: Int,
        endIndex: Int,
        type: TokenType = .word
    ) {
        self.text = text
        self.unaccented = unaccented
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.type = type
    }
}

/// Câu hoàn chỉnh sau khi đi qua tầng chuẩn hóa và phân rã token.
public struct NormalizedSentence: Sendable, Hashable {
    /// Chuỗi gốc nguyên bản ban đầu người dùng nhập vào.
    public let raw: String
    /// Chuỗi đã chuẩn hóa có dấu (các token chữ thường nối bằng khoảng trắng).
    public let text: String
    /// Chuỗi đã chuẩn hóa không dấu (các token không dấu nối bằng khoảng trắng).
    public let unaccentedText: String
    /// Danh sách token kèm vị trí đối chiếu trên chuỗi gốc.
    public let tokens: [Token]

    public init(
        raw: String,
        text: String,
        unaccentedText: String,
        tokens: [Token] = []
    ) {
        self.raw = raw
        self.text = text
        self.unaccentedText = unaccentedText
        self.tokens = tokens
    }
}
