//
//  CompactDictionaryRepresentationTests.swift
//  
//
//  Created by Oleg Bakharev on 22.03.2024.
//

import XCTest
@testable import AsyncHttpClient

final class CompactDictionaryRepresentationTests: XCTestCase {

    func testExample() throws {
        struct Test: CompactDictionaryRepresentable {
            let int: Int?
            let bool: Bool?
            let string: String?
        }
        let test = Test(int: 1, bool: nil, string: "hello")
        let dict = test.compactDictionaryRepresentation

        XCTAssert(dict.count == 2)
        XCTAssert(dict["int"] as! Int == 1)
        XCTAssert(dict["string"] as! String == "hello")
    }

}
