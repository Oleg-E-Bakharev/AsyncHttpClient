//
//  AnyPrimitiveCodableTests.swift
//
//
//  Created by Oleg Bakharev on 21.03.2024.
//

import XCTest
@testable import AsyncHttpClient

final class AnyPrimitiveCodableTests: XCTestCase {

    private struct TestData: Codable {
        let value: AnyPrimitiveCodable
    }

    lazy var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
    }

    func testIntEncode() throws {
        let input = AnyPrimitiveCodable.int(123)
        let data = try encoder.encode(input)
        let output = try decoder.decode(Int.self, from: data)
        XCTAssertEqual(output, 123)
    }

    func testIntDecode() throws {
        let json = [ "value": 123 ]
        let data = try encoder.encode(json)
        let item = try decoder.decode(TestData.self, from: data)
        let result = if case .int(123) = item.value { true } else { false }
        XCTAssertTrue(result)
    }

    func testStringEncode() throws {
        let input = AnyPrimitiveCodable.string("hello")
        let data = try encoder.encode(input)
        let output = try decoder.decode(String.self, from: data)
        XCTAssertEqual(output, "hello")
    }

    func testStringDecode() throws {
        let json = [ "value": "hello" ]
        let data = try encoder.encode(json)
        let item = try decoder.decode(TestData.self, from: data)
        let result = if case .string("hello") = item.value { true } else { false }
        XCTAssertTrue(result)
    }

    func testDoubleEncode() throws {
        let input = AnyPrimitiveCodable.double(123.0)
        let data = try encoder.encode(input)
        let output = try decoder.decode(Double.self, from: data)
        XCTAssertEqual(output, 123.0)
    }

    func testDoubleDecode() throws {
        let json = [ "value": 123.0 ]
        let data = try encoder.encode(json)
        let item = try decoder.decode(TestData.self, from: data)
        XCTAssertTrue(item.value.anyDouble == 123.0)
    }

    func testDoubleDecode2() throws {
        let json = [ "value": 123.5 ]
        let data = try encoder.encode(json)
        let item = try decoder.decode(TestData.self, from: data)
        XCTAssertTrue(item.value.anyDouble == 123.5)
    }


    func testBoolEncode() throws {
        let input = AnyPrimitiveCodable.bool(true)
        let data = try encoder.encode(input)
        let output = try decoder.decode(Bool.self, from: data)
        XCTAssertEqual(output, true)
    }

    func testBoolDecode() throws {
        let json = [ "value": true ]
        let data = try encoder.encode(json)
        let item = try decoder.decode(TestData.self, from: data)
        let result = if case .bool(true) = item.value { true } else { false }
        XCTAssertTrue(result == true)
    }

    func testDateEncode() throws {
        let date = Date()
        let input = AnyPrimitiveCodable.date(date)
        let data = try encoder.encode(input)
        let output = try decoder.decode(Date.self, from: data)
        XCTAssertEqual(Int(date.timeIntervalSinceReferenceDate), Int(output.timeIntervalSinceReferenceDate))
    }

    func testDateDecode() throws {
        let date = Date()
        let json = [ "value": date ]
        let data = try encoder.encode(json)
        let item = try decoder.decode(TestData.self, from: data)
        let result = if case .date(let value) = item.value { value } else { Date.distantPast }
        XCTAssertEqual(Int(date.timeIntervalSinceReferenceDate), Int(result.timeIntervalSinceReferenceDate))
    }

}
