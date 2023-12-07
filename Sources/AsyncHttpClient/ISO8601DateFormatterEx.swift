// Copyright © 2023 Oleg Bakharev. All rights reserved.
// Created by Oleg Bakharev

import Foundation

/// ISO8601DateFormatter не поддерживает таймзоны и дробные секунды. Этот поддерживает и то и другое.
/// timeZone можно изменить после инициализации до первого вызова date(from string:)
public class ISO8601DateFormatterEx: DateFormatter {

    public override func date(from string: String) -> Date? {
        integerDateFormatter.date(from: string) ?? fractionalDateFormatter.date(from: string)
    }

    // MARK: - Private Properties

    // Применяем последовательно форматирование без дробной части и с дробной частью.
    private lazy var integerDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = timeZone
        formatter.formatOptions = [.withInternetDateTime, .withTimeZone]
        return formatter
    }()

    private lazy var fractionalDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = timeZone
        formatter.formatOptions = [.withInternetDateTime,
                                   .withTimeZone,
                                   .withFractionalSeconds]
        return formatter
    }()

}
