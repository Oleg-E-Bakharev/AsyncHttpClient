// Copyright © 2023 Oleg Bakharev. All rights reserved.
// Created by Oleg Bakharev

import Foundation

/// Расширенный парсер дат, подходящий для большинства формат дат в ISO8601
public class ISO8601DateFormatterEx: DateFormatter, @unchecked Sendable {

    public override func date(from string: String) -> Date? {
        switch string.utf8.count {
        case 0...10:
            onlyDateFormatter.date(from: string)
        default:
            integerDateFormatter.date(from: string)
            ?? fractionalDateFormatter.date(from: string)
            ?? integerDateFormatterWithoutTimeZone.date(from: string)
            ?? fractionalDateFormatterWithoutTimeZone.date(from: string)
        }
    }

    // MARK: - Private Properties

    // Применяем последовательно форматирование без дробной части и с дробной частью.
    private lazy var integerDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        return formatter
    }()

    private lazy var fractionalDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime,
                                   .withTimeZone,
                                   .withFractionalSeconds]
        return formatter
    }()

    private lazy var integerDateFormatterWithoutTimeZone: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = timeZone
        return formatter
    }()

    private lazy var fractionalDateFormatterWithoutTimeZone: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = timeZone
        return formatter
    }()

    private lazy var onlyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = timeZone
        return formatter
    }()

}
