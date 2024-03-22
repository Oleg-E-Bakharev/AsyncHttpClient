//
//  AnyPrimitiveCodable.swift
//  AsyncHttpClient
//
//  Created by Oleg Bakharev on 23.06.2022.
//  Copyright © 2022 Wildberries OOO. All rights reserved.
//

import Foundation

/// Тип, задающий один из возможных примитивных типов в JSON
/// В JSONе будет только значение целевого типа.
/// Даты следует кодировать только в ISO8601 иначе любая дата будет раскодироваться в число.
public enum AnyPrimitiveCodable {
    case date(Date)
    case string(String)
    case double(Double) // Do not use directly. Use anyDouble instead.
    case int(Int)
    case bool(Bool)
    case unknown

    var anyDouble: Double? {
        switch self {
        case .double(let value):
            value
        case .int(let value):
            Double(value)
        default:
            nil
        }
    }
}

extension AnyPrimitiveCodable: Decodable {

    public init(from decoder: Decoder) throws {
        // int должен быть перед double
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            self = .int(int)
            return
        }

        if let double = try? decoder.singleValueContainer().decode(Double.self) {
            self = .double(double)
            return
        }

        // Не следует применять числовой формат даты, т.к. из дат будут получаться числа.
        if let date = try? decoder.singleValueContainer().decode(Date.self) {
            self = .date(date)
            return
        }

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            self = .string(string)
            return
        }

        if let bool = try? decoder.singleValueContainer().decode(Bool.self) {
            self = .bool(bool)
            return
        }

        self = .unknown
    }

}

extension AnyPrimitiveCodable: Encodable {

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .int(let int):
            try int.encode(to: encoder)
        case .date(let date):
            // https://stackoverflow.com/questions/48658574/jsonencoders-dateencodingstrategy-not-working
            var container = encoder.singleValueContainer()
            try container.encode(date)
        case .string(let string):
            try string.encode(to: encoder)
        case .bool(let bool):
            try bool.encode(to: encoder)
        case .double(let double):
            try double.encode(to: encoder)
        default:
            break
        }
    }

}
