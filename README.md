# iOS Swift AsyncHttpClient

Useful Swift iOS and MacOS Async HTTP Client.\
Motto: Perform http requests in one string

## SPM Usage:
```swift
    dependencies: [
        .package(url: "https://github.com/Oleg-E-Bakharev/AsyncHttpClient", from: "1.0.0")
    ],
```

## Usage sample:
```swift

#import Foundation
#import AsyncHttpClient

struct Warehouse: Codable {
    let id: Int
    let title: String
}

let httpClient: AsyncHttpClient = AsyncHttpJSONClient()

func fetchWarehouses() async throws -> [Warehouse] {
    try await userSession.httpClient.get(url: URL(string: "https://my_sweet_url.com/warehouses"))
}

func update(warehouse: Warehouse) async throws {
    try await userSession.httpClient.post(url: URL(string: "https://my_sweet_url.com/warehouse"), body: warehouse)
}

```
