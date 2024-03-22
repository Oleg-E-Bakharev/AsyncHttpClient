//
//  EnumAlwaysDecodableTests.swift
//
//
//  Created by Oleg Bakharev on 22.03.2024.
//

import XCTest
@testable import AsyncHttpClient

final class enumAlwaysDecodableTests: XCTestCase {

    private struct TestDataString: Decodable {

        enum TestEnum: String, Decodable, EnumAlwaysDecodable {
            case first
            case second
            case unparsed
        }

        let value: TestEnum
    }

    private struct TestDataInt: Decodable {

        enum TestEnum: Int, Decodable, EnumAlwaysDecodable {
            case first
            case second
            case unparsed
        }

        let value: TestEnum
    }

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStringEnumParsed() throws {
        let json = [ "value": "second" ]
        let data = try encoder.encode(json)
        let item = try decoder.decode(TestDataString.self, from: data)
        XCTAssert(item.value == .second)
    }

    func testStringEnumUnparsed() throws {
        let json = [ "value": "third" ]
        let data = try encoder.encode(json)
        let item = try decoder.decode(TestDataString.self, from: data)
        XCTAssert(item.value == .unparsed)
    }

    func testIntEnumParsed() throws {
        let json = [ "value": 0 ]
        let data = try encoder.encode(json)
        let item = try decoder.decode(TestDataInt.self, from: data)
        XCTAssert(item.value == .first)
    }

    func testIntEnumUnparsed() throws {
        let json = [ "value": -100 ]
        let data = try encoder.encode(json)
        let item = try decoder.decode(TestDataInt.self, from: data)
        XCTAssert(item.value == .unparsed)
    }

}
