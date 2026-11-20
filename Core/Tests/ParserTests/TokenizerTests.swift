//
//  TokenizerTests.swift
//  Core
//
//  Created by Le Hung on 20/11/26.
//

import Foundation
import Testing
@testable import Parser

/// Cặp giá trị mong đợi (chữ chuẩn hóa, loại token) để so sánh trong test.
struct ExpectedToken: Sendable, Hashable, CustomStringConvertible {
    let text: String
    let type: TokenType

    init(_ text: String, _ type: TokenType) {
        self.text = text
        self.type = type
    }

    var description: String {
        "(\(text), \(type))"
    }
}

/// Dữ liệu test tham số cho Tokenizer.
struct TokenizerParamCase: Sendable, CustomTestStringConvertible {
    let input: String
    let expectedTokens: [ExpectedToken]

    var testDescription: String {
        input.replacingOccurrences(of: "\r\n", with: "\\r\\n")
            .replacingOccurrences(of: "\n", with: "\\n")
    }
}

@Suite("Kiểm thử bộ chuẩn hóa và tách từ (TextNormalizer & Tokenizer)")
struct TokenizerTests {
    private static let vietnameseLocale = Locale(identifier: "vi_VN")

    @Test("Bỏ dấu tiếng Việt bao gồm chữ đ và Đ")
    func testStripDiacritics() {
        #expect(TextNormalizer.stripDiacritics("Phở Bò") == "pho bo")
        #expect(TextNormalizer.stripDiacritics("đổ xăng ĐI CHỢ") == "do xang di cho")
        #expect(TextNormalizer.stripDiacritics("bánh mì 20k") == "banh mi 20k")
        #expect(TextNormalizer.stripDiacritics("Đường Lê Lợi") == "duong le loi")
    }

    @Test("Tách cụm số và đơn vị tiền tệ")
    func testSeparateNumberAndUnits() {
        #expect(TextNormalizer.separateNumberAndUnits("45k") == "45 k")
        #expect(TextNormalizer.separateNumberAndUnits("1tr2") == "1 tr 2")
        #expect(TextNormalizer.separateNumberAndUnits("2củ") == "2 củ")
        #expect(TextNormalizer.separateNumberAndUnits("5lít") == "5 lít")
        #expect(TextNormalizer.separateNumberAndUnits("50nghìn") == "50 nghìn")
        #expect(TextNormalizer.separateNumberAndUnits("30ngàn") == "30 ngàn")
    }

    @Test("Bảo toàn số thập phân và phân cách hàng nghìn khi tách")
    func testPreserveDecimalsAndThousands() {
        #expect(TextNormalizer.separateNumberAndUnits("1.5tr") == "1.5 tr")
        #expect(TextNormalizer.separateNumberAndUnits("1,5tr") == "1,5 tr")
        #expect(TextNormalizer.separateNumberAndUnits("45.000") == "45.000")
        #expect(TextNormalizer.separateNumberAndUnits("1,250,000") == "1,250,000")
        #expect(TextNormalizer.separateNumberAndUnits("123 Lê Lợi") == "123 Lê Lợi")
    }

    @Test("Thu gọn khoảng trắng thừa và ký tự tab")
    func testNormalizeWhitespace() {
        #expect(TextNormalizer.normalizeWhitespace("   phở   bò   45k   ") == "phở bò 45k")
        #expect(TextNormalizer.normalizeWhitespace("cơm\t\trang   35k") == "cơm rang 35k")
        #expect(TextNormalizer.normalizeWhitespace("") == "")
    }

    @Test("Chuẩn hóa toàn diện câu nhập liệu qua Tokenizer")
    func testNormalizeFull() {
        let normalized = TextNormalizer.normalize("  ĂN BÚN BÒ  45K  ")
        #expect(normalized.text == "ăn bún bò 45 k")
        #expect(normalized.unaccentedText == "an bun bo 45 k")
    }

    @Test("Phân rã câu thành mảng Token chính xác vị trí raw")
    func testTokenizeSentence() {
        let raw = "Phở bò 45k"
        let sentence = Tokenizer.tokenize(raw)

        #expect(sentence.raw == raw)
        #expect(sentence.tokens.count == 4)

        let token0 = sentence.tokens[0]
        #expect(token0.text == "phở")
        #expect(token0.unaccented == "pho")
        #expect(token0.type == .word)
        #expect(token0.startIndex == 0)
        #expect(token0.endIndex == 3)

        let token1 = sentence.tokens[1]
        #expect(token1.text == "bò")
        #expect(token1.unaccented == "bo")
        #expect(token1.type == .word)
        #expect(token1.startIndex == 4)
        #expect(token1.endIndex == 6)

        let token2 = sentence.tokens[2]
        #expect(token2.text == "45")
        #expect(token2.unaccented == "45")
        #expect(token2.type == .number)
        #expect(token2.startIndex == 7)
        #expect(token2.endIndex == 9)

        let token3 = sentence.tokens[3]
        #expect(token3.text == "k")
        #expect(token3.unaccented == "k")
        #expect(token3.type == .word)
        #expect(token3.startIndex == 9)
        #expect(token3.endIndex == 10)

        // Kiểm tra cắt substring từ raw theo startIndex..<endIndex
        for token in sentence.tokens {
            let start = raw.index(raw.startIndex, offsetBy: token.startIndex)
            let end = raw.index(raw.startIndex, offsetBy: token.endIndex)
            let slice = String(raw[start..<end])
            #expect(slice.lowercased(with: Self.vietnameseLocale) == token.text)
        }
    }

    private static let edgeTestCases: [TokenizerParamCase] = [
        TokenizerParamCase(
            input: "1tr2",
            expectedTokens: [
                ExpectedToken("1", .number),
                ExpectedToken("tr", .word),
                ExpectedToken("2", .number),
            ]
        ),
        TokenizerParamCase(
            input: "1,5tr",
            expectedTokens: [
                ExpectedToken("1,5", .number),
                ExpectedToken("tr", .word),
            ]
        ),
        TokenizerParamCase(
            input: "1.250.000",
            expectedTokens: [
                ExpectedToken("1.250.000", .number)
            ]
        ),
        TokenizerParamCase(
            input: "ĐỔ XĂNG 50K",
            expectedTokens: [
                ExpectedToken("đổ", .word),
                ExpectedToken("xăng", .word),
                ExpectedToken("50", .number),
                ExpectedToken("k", .word),
            ]
        ),
        TokenizerParamCase(
            input: "sáng phở 45k, trưa cơm 35k",
            expectedTokens: [
                ExpectedToken("sáng", .word),
                ExpectedToken("phở", .word),
                ExpectedToken("45", .number),
                ExpectedToken("k", .word),
                ExpectedToken(",", .punctuation),
                ExpectedToken("trưa", .word),
                ExpectedToken("cơm", .word),
                ExpectedToken("35", .number),
                ExpectedToken("k", .word),
            ]
        ),
        TokenizerParamCase(
            input: "15/10",
            expectedTokens: [
                ExpectedToken("15", .number),
                ExpectedToken("/", .punctuation),
                ExpectedToken("10", .number),
            ]
        ),
        TokenizerParamCase(
            input: "phở 45k\r\ncơm 35k",
            expectedTokens: [
                ExpectedToken("phở", .word),
                ExpectedToken("45", .number),
                ExpectedToken("k", .word),
                ExpectedToken("\n", .newline),
                ExpectedToken("cơm", .word),
                ExpectedToken("35", .number),
                ExpectedToken("k", .word),
            ]
        ),
        TokenizerParamCase(
            input: "phở bò 45k".decomposedStringWithCanonicalMapping,
            expectedTokens: [
                ExpectedToken("phở", .word),
                ExpectedToken("bò", .word),
                ExpectedToken("45", .number),
                ExpectedToken("k", .word),
            ]
        ),
    ]

    @Test("Phân rã token chi tiết các ca kiểm thử biên", arguments: edgeTestCases)
    func testTokenizeEdgeCases(testCase: TokenizerParamCase) {
        let sentence = Tokenizer.tokenize(testCase.input)
        let actual = sentence.tokens.map { ExpectedToken($0.text, $0.type) }
        #expect(actual == testCase.expectedTokens)

        // Kiểm tra cắt substring trên chuỗi raw
        for token in sentence.tokens {
            let start = testCase.input.index(testCase.input.startIndex, offsetBy: token.startIndex)
            let end = testCase.input.index(testCase.input.startIndex, offsetBy: token.endIndex)
            let slice = String(testCase.input[start..<end])
            if token.type == .newline {
                #expect(slice == "\n" || slice == "\r\n")
            } else {
                #expect(slice.lowercased(with: Self.vietnameseLocale) == token.text)
            }
        }
    }

    @Test("Tách câu rỗng hoặc toàn khoảng trắng an toàn")
    func testTokenizeEmptyOrWhitespace() {
        let empty = Tokenizer.tokenize("")
        #expect(empty.tokens.isEmpty)
        #expect(empty.text.isEmpty)
        #expect(empty.unaccentedText.isEmpty)

        let spaces = Tokenizer.tokenize("   \n\t  ")
        #expect(spaces.tokens.isEmpty)
        #expect(spaces.text.isEmpty)
        #expect(spaces.unaccentedText.isEmpty)
    }

    @Test("Tách câu có dấu câu và xuống dòng")
    func testTokenizePunctuationAndNewline() {
        let raw = "tiền điện: 450k;\ntiền nước 120k."
        let sentence = Tokenizer.tokenize(raw)

        let types = sentence.tokens.map(\.type)
        #expect(types.contains(.punctuation))
        #expect(types.contains(.newline))
        #expect(types.contains(.number))
        #expect(types.contains(.word))
    }
}
