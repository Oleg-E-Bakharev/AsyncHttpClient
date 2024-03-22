//
//  ISO8601DateFormatterExTest.swift
//  
//
//  Created by Oleg Bakharev on 22.03.2024.
//

import XCTest
@testable import AsyncHttpClient

final class ISO8601DateFormatterExTest: XCTestCase {

    private struct TestData: Codable {
        let date: Date
    }

    lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(ISO8601DateFormatterEx())
        return decoder
    }()


    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDefaultDormat() throws {
        if #available(macOS 12, iOS 15, *) {
            let data = "{\"date\":\"\(Date.now.ISO8601Format())\"}".data(using: .utf8)!
            _ = try decoder.decode(TestData.self, from: data)
        }
    }

    func testIntegerFormat() throws {
        let data = "{\"date\":\"2022-09-05T10:35:08Z\"}".data(using: .utf8)!
        _ = try decoder.decode(TestData.self, from: data)
    }

    func testIntegerFormat2() throws {
        let data = "{\"date\":\"2006-01-02T15:04:05Z0700\"}".data(using: .utf8)!
        _ = try decoder.decode(TestData.self, from: data)
    }

    func testIntegerFormatWithoutTimeZone() throws {
        let data = "{\"date\":\"2006-01-02T15:04:05\"}".data(using: .utf8)!
        _ = try decoder.decode(TestData.self, from: data)
    }

    func testIntegerVsTimeZoneFormat() throws {
        let data = "{\"date\":\"2022-09-05T10:35:08+003\"}".data(using: .utf8)!
        _ = try decoder.decode(TestData.self, from: data)
    }

    func testFractionFormat() throws {
        let data = "{\"date\":\"2022-09-05T10:35:08.217174Z\"}".data(using: .utf8)!
        _ = try decoder.decode(TestData.self, from: data)
    }

    func testOnlyDateFormat() throws {
        let data = "{\"date\":\"2022-09-05\"}".data(using: .utf8)!
        _ = try decoder.decode(TestData.self, from: data)
    }

    func testFractionFormatWithoutTimeZone() throws {
        let data = "{\"date\":\"2022-09-05T10:35:08.217174\"}".data(using: .utf8)!
        _ = try decoder.decode(TestData.self, from: data)
    }

}
