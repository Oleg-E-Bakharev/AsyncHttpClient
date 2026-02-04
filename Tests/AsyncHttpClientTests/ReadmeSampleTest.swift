//
//  Test.swift
//  AsyncHttpClient
//
//  Created by Олег Бахарев on 04.02.2026.
//

import Testing

import Foundation
import AsyncHttpClient

struct Warehouse: Codable {
    let id: Int
    let title: String
}

@AsyncNetwokActor
struct NetworkClient {
    let httpClient: AsyncHttpClient = AsyncHttpJsonClient()

    func fetchWarehouses() async throws -> [Warehouse] {
        try await httpClient.get(url: URL(string: "https://my_sweet_url.com/warehouses")!)
    }

    func update(warehouse: Warehouse) async throws {
        try await httpClient.post(url: URL(string: "https://my_sweet_url.com/warehouse")!, body: warehouse)
    }
}

struct Test {

    @Test func readmeSampleTest() async throws {
    }

}
