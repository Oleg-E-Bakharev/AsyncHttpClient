//
//  EnumAlwaysDecodable.swift
//  WBPortal
//
//  Created by Oleg Bakharev on 01.07.2022.
//  Copyright © 2022 Wildberries OOO. All rights reserved.
//

import Foundation

/// Протокол для enum, чтобы при декодировании новых значений не падал парсинг всего JSONа
/// В целевом enum должно быть определено значение unparsed - оно будет назначаться неизвестным значениям enum
public protocol EnumAlwaysDecodable: Decodable {
    static var unparsed: Self { get }
}

public extension EnumAlwaysDecodable where Self: RawRepresentable, Self.RawValue == String {

    init(from decoder: Decoder) throws {
        do {
            let value = try decoder.singleValueContainer().decode(RawValue.self)
            self = Self(rawValue: value) ?? .unparsed
#if DEBUG
            if self == .unparsed {
                    print("[JSON] \(Self.self) unparsed enum value: \(value)")
            }
#endif
        } catch {
            self = .unparsed
        }
    }

}

public extension EnumAlwaysDecodable where Self: RawRepresentable, Self.RawValue == Int {

    init(from decoder: Decoder) throws {
        do {
            let value = try decoder.singleValueContainer().decode(RawValue.self)
            self = Self(rawValue: value) ?? .unparsed
#if DEBUG
            if self == .unparsed {
                    print("[JSON] \(Self.self) unparsed enum value: \(value)")
            }
#endif
        } catch {
            self = .unparsed
        }
    }

}
