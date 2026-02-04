# iOS Swift AsyncHttpClient

Useful Swift iOS and MacOS Async HTTP Client.\
Motto: Perform http requests in one string

## SPM Usage:
```swift
    dependencies: [
        .package(url: "https://github.com/Oleg-E-Bakharev/AsyncHttpClient", from: "1.1.0")
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

@AsyncNetwokActor
func fetchWarehouses() async throws -> [Warehouse] {
    try await httpClient.get(url: URL(string: "https://my_sweet_url.com/warehouses"))
}

@AsyncNetwokActor
func update(warehouse: Warehouse) async throws {
    try await httpClient.post(url: URL(string: "https://my_sweet_url.com/warehouse"), body: warehouse)
}

```

## History of changes:
- 2.0.0:
	- All code run in public global actor AsyncNetworkActor for convenience resove Swift6 isolation issues. 
	- Added error tuner to hook errors when use-case errors maps to transort http-errors.
