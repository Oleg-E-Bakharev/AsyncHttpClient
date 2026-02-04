// Copyright © 2022 Oleg Bakharev. All rights reserved.
// Created by Oleg Bakharev

import Foundation

@globalActor public actor AsyncNetwokActor {
    public static let shared = AsyncNetwokActor()
    private init() {}
}

/// Тюнеры запросов
public enum AsyncHttpRequestTuners {
    /// Тюнер запроса - позволяет как угодно настроить запрос
    case request((inout URLRequest) -> Void)

    /// Тюнер ответа - позволяет валидировать и извлекать данные из заголовка ответа
    case response((HTTPURLResponse) throws -> Void)

    /// Тюнер кодера. Позволяет кастомизировать кодер
    case encoder((inout JSONEncoder) -> Void)

    /// Тюнер декодера. Позволяет кастомизировать декодер
    case decoder((inout JSONDecoder) -> Void)

    /// Тюнер ошибки. Случается бэкендеры путают транспортные ошибки с бизнесовыми.
    /// Данный тюнер позволяет на стороне обработчика переопределить любой код ошибки как success 200 (true).
    case error((URLError) -> Bool)

    public enum Keys {
        case request
        case response
        case encoder
        case decoder
        case error
    }
}

/// Асинхронный HTTP клиент
@AsyncNetwokActor
public protocol AsyncHttpClient {

    var session: URLSession { get }

    /// GET HTTP method
    /// Для удобства формирования parameters удобно использовать CompactDictionaryRepresentable
    func get<Target: Decodable>(
        url: URL,
        parameters: [String: Any],
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target

    /// POST HTTP method
    func post<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target

    /// PUT HTTP method
    func put<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target

    /// DELETE HTTP method
    func delete<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target

    /// PATCH HTTP method
    func patch<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target

}

/// Расширение делающее необязательными некоторые параметры и возвращаемые результаты
public extension AsyncHttpClient {

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
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
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
    nonisolated(unsafe) static var defaultAsyncRequestTimeout = 60.0
}

public struct AsyncHttpClientEmpty: Codable {
    public init() {}
}

// MARK: - Private part

private extension AsyncHttpClient {

    func emptyResponseCall(body: () async throws -> Void) async rethrows {
        do {
            try await body()
        } catch let urlError as URLError {
            if !((0..<400) ~= urlError.code.rawValue) {
                throw urlError
            }
        }
    }

}
