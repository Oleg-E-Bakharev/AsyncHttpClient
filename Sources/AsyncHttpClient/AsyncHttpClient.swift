// Copyright © 2022 Oleg Bakharev. All rights reserved.
// Created by Oleg Bakharev

import Foundation

public struct AsyncHttp {

    public enum RequestTuners {
        case request((inout URLRequest) -> Void)
        case encoder((inout JSONEncoder) -> Void)
        case decoder((inout JSONDecoder) -> Void)

        public enum Keys {
            case request
            case encoder
            case decoder
        }
    }

}

public protocol AsyncHttpClient {

    var session: URLSession { get }

    /// GET HTTP method.
    func get<Target: Decodable>(
        url: URL,
        parameters: [String: Any],
        tuners: [AsyncHttp.RequestTuners.Keys: AsyncHttp.RequestTuners]
    ) async throws -> Target

    /// POST HTTP method
    func post<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttp.RequestTuners.Keys: AsyncHttp.RequestTuners]
    ) async throws -> Target

    /// PUT HTTP method
    func put<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttp.RequestTuners.Keys: AsyncHttp.RequestTuners]
    ) async throws -> Target

    /// DELETE HTTP method
    func delete<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttp.RequestTuners.Keys: AsyncHttp.RequestTuners]
    ) async throws -> Target

    /// PATCH HTTP method
    func patch<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttp.RequestTuners.Keys: AsyncHttp.RequestTuners]
    ) async throws -> Target

}

public extension AsyncHttpClient {

    func emptyResponseCall(body: () async throws -> Void) async rethrows {
        do {
            try await body()
        } catch let urlError as URLError {
            if !((0..<400) ~= urlError.code.rawValue) {
                throw urlError
            }
        }
    }

    func get<Target: Decodable>(
        url: URL,
        parameters: [String: Any] = [:]
    ) async throws -> Target {
        try await get(
            url: url,
            parameters: parameters,
            tuners: [:]
        )
    }

    func get<Target: Decodable>(
        url: URL,
        tuners: [AsyncHttp.RequestTuners.Keys: AsyncHttp.RequestTuners]
    ) async throws -> Target {
        try await get(
            url: url,
            parameters: [:],
            tuners: tuners
        )
    }

    func post<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body = AsyncHttpClientEmpty()
    ) async throws -> Target {
        try await post(url: url, body: body, tuners: [:])
    }

    func post<Body: Encodable>(
        url: URL,
        body: Body = AsyncHttpClientEmpty()
    ) async throws {
        try await emptyResponseCall {
            let _: AsyncHttpClientEmpty = try await post(url: url, body: body, tuners: [:])
        }
    }

    func put<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body = AsyncHttpClientEmpty()
    ) async throws -> Target {
        try await put(url: url, body: body, tuners: [:])
    }

    func put<Body: Encodable> (
        url: URL,
        body: Body = AsyncHttpClientEmpty()
    ) async throws {
        try await emptyResponseCall {
            let _: AsyncHttpClientEmpty = try await put(url: url, body: body, tuners: [:])
        }
    }

    func delete<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body = AsyncHttpClientEmpty()
    ) async throws -> Target {
        try await delete(url: url, body: body, tuners: [:])
    }

    func delete<Body: Encodable>(
        url: URL,
        body: Body = AsyncHttpClientEmpty()
    ) async throws {
        try await emptyResponseCall {
            let _: AsyncHttpClientEmpty = try await delete(url: url, body: body, tuners: [:])
        }
    }

    func patch<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body = AsyncHttpClientEmpty()
    ) async throws -> Target {
        try await patch(url: url, body: body, tuners: [:])
    }

    func patch<Body: Encodable>(
        url: URL,
        body: Body = AsyncHttpClientEmpty()
    ) async throws {
        try await emptyResponseCall {
            let _:AsyncHttpClientEmpty = try await patch(url: url, body: body, tuners: [:])
        }
    }

}

public extension TimeInterval {
    static var defaultAsyncRequestTimeout = 60.0
}

public struct AsyncHttpClientEmpty: Codable {
    public init() {}
}
