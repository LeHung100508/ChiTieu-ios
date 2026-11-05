//
//  EnumPractice.swift
//  
//
//  Created by Le Hung on 5/11/26.
//
public enum BookFormat: Equatable {
    case paper(pages: Int)
    case ebook(sizeMB: Double)
    case audioBook(durationMinutes: Int)
}

public func formatDescription(_ format: BookFormat) -> String {
    return switch format {
    case .paper(let pages):
        "Sách giấy: \(pages) trang"
    case .ebook(let sizeMB):
        "Sách điện tử: \(sizeMB) MB"
    case .audioBook(let durationMinutes):
        "Sách nói: \(durationMinutes) phút"
    }
}
