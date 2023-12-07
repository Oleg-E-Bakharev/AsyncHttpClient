// Copyright © 2022 Oleg Bakharev. All rights reserved.
// Created by Oleg Bakharev

import Foundation

/// Протокол специальной реакции на некоторые ошибки.
public protocol AsyncHttpRequestRetrier {
    func shouldRetry(request: URLRequest, error: Error) async -> Bool
}

/// Протокол проверки ответов и генерации специфических ошибок.
public protocol AsyncHttpResponseValidator {
    func validate(response: HTTPURLResponse, data: Data?) throws
}

// MARK: - Private extensions

private extension URLError {
    static let invalidUrl = URLError(.badURL)
    static let emptyResponse = URLError(URLError.Code(rawValue: 204))
    static let invalidResponse = URLError(.badServerResponse)
}

private extension String {
    static let jsonMimeType = "application/json"
    static let post = "POST"
    static let put = "PUT"
    static let delete = "DELETE"
    static let patch = "PATCH"
    static let contentType = "Content-Type"
}

private extension AnyHashable {
    static let accept = "Accept"
}

private extension HTTPURLResponse {
    var isError: Bool { statusCode >= 400 }
}

private extension Dictionary where Key == String {
    // ВАЖНО! При отображении массива в словарь, порядок ключей может меняться случайным образом.
    // Для работы Etag порядок ключей в запросе должен быть всегда одинаков.
    var urlQueryItems: [URLQueryItem] {
        map { .init(name: $0, value: String(describing: $1)) }
        .sorted { $0.name < $1.name }
    }
}

private extension URLSession {
    func asyncData(for request: URLRequest) async throws -> (Data, URLResponse) {
        if #available(iOS 15.0, *) {
            return try await data(for: request)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                let task = self.dataTask(with: request) { data, response, error in
                    guard let data, let response else {
                        let error = error ?? URLError.invalidResponse
                        return continuation.resume(throwing: error)
                    }

                    continuation.resume(returning: (data, response))
                }
                task.resume()
            }
        }
    }
}

// MARK: - AsyncHttpJsonClient

public class AsyncHttpJsonClient: AsyncHttpClient {

    // MARK: - Public properties

    public lazy var session: URLSession = {
        URLSession(configuration: configuration)
    }()

    // MARK: - Private properties

    private let configuration: URLSessionConfiguration

    // Вызывается в случае бросания исключения вследствии ошибки или проверки ответа.
    private let requestRetrier: AsyncHttpRequestRetrier?
    // Вызывается для валидации ответа.
    private let responseValidator: AsyncHttpResponseValidator?

    private let dateFormatter: DateFormatter

    // MARK: - Initializers

    public init(
        configuration: URLSessionConfiguration = URLSessionConfiguration.default,
        requestRetrier: AsyncHttpRequestRetrier? = nil,
        responseValidator: AsyncHttpResponseValidator? = nil,
        dateFormatter: DateFormatter = ISO8601DateFormatterEx()
    ) {
        self.configuration = configuration
        self.requestRetrier = requestRetrier
        self.responseValidator = responseValidator
        self.dateFormatter = dateFormatter
        setupSessionConfiguration()
    }

    // MARK: - AsyncHttpClient Methods

    /// GET HTTP method.
    public func get<Target: Decodable>(
        url: URL,
        parameters: [String: Any],
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target {
        let targetUrl = try makeUrl(from: url, parameters: parameters)
        var request = URLRequest(
            url: targetUrl,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: .defaultAsyncRequestTimeout
        )
        if case .request(let requestTuner)? = tuners[.request] {
            requestTuner(&request)
        }
        return try await perform(request: request, tuners: tuners)
    }

    /// POST HTTP method
    public func post<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target {
        try await perform(
            method: .post,
            url: url,
            body: body,
            tuners: tuners
        )
    }

    /// PUT HTTP method
    public func put<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target {
        try await perform(
            method: .put,
            url: url,
            body: body,
            tuners: tuners
        )
    }

    /// DELETE HTTP method
    public func delete<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target {
        try await perform(
            method: .delete,
            url: url,
            body: body,
            tuners: tuners
        )
    }

    /// PATCH HTTP method
    public func patch<Body: Encodable, Target: Decodable>(
        url: URL,
        body: Body,
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target {
        try await perform(
            method: .patch,
            url: url,
            body: body,
            tuners: tuners
        )
    }

    // MARK: - Private Methods

    private func setupSessionConfiguration() {
        if configuration.httpAdditionalHeaders == nil {
            configuration.httpAdditionalHeaders = [:]
        }
        configuration.httpAdditionalHeaders?[.accept] = String.jsonMimeType
    }

    private func makeUrl(from url: URL, parameters: [String: Any]) throws -> URL {
        guard
            url.scheme != nil || url.baseURL?.scheme != nil,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { throw URLError.invalidUrl }

        if !parameters.isEmpty {
            components.queryItems = parameters.urlQueryItems
        }

        guard let result = components.url else { throw URLError.invalidUrl }

        return result
    }

    private func perform<Body: Encodable, Target: Decodable>(
        method: String,
        url: URL,
        body: Body,
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target {
        guard url.scheme != nil || url.baseURL?.scheme != nil else {
            throw URLError.invalidUrl
        }

        var request = URLRequest(url: url)

        if case .request(let requestTuner)? = tuners[.request] {
            requestTuner(&request)
        }

        var encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if case .encoder(let encoderTuner)? = tuners[.encoder] {
            encoderTuner(&encoder)
        }

        let httpBody = try encoder.encode(body)
        request.setValue(.jsonMimeType, forHTTPHeaderField: .contentType)
        request.httpMethod = method
        request.httpBody = httpBody
        return try await perform(request: request, tuners: tuners)
    }

    private func perform<Target: Decodable>(
        request: URLRequest,
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) async throws -> Target {
        do {
            let (data, response) = try await session.asyncData(for: request)
            return try handle(data: data, response: response, tuners: tuners)
        } catch {
            if let requestRetrier,
               await requestRetrier.shouldRetry(request: request, error: error) {
                return try await perform(request: request, tuners: tuners)
            }
            throw error
        }
    }

    private func handle<Target: Decodable>(
        data: Data?,
        response: URLResponse?,
        tuners: [AsyncHttpRequestTuners.Keys: AsyncHttpRequestTuners]
    ) throws -> Target {
        guard let response, let data else {
            throw URLError.emptyResponse
        }

        try validate(response, data: data)

        do {
            var decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)

            if case .decoder(let decoderTuner)? = tuners[.decoder] {
                decoderTuner(&decoder)
            }

            let target = try decoder.decode(Target.self, from: data)
            return target
        } catch {
            print("JSON parsing error: \(error)\n\ndata: \(String(data: data, encoding: .utf8) ?? "")")
            throw error
        }
    }

    private func validate(_ response: URLResponse, data: Data?) throws {
        guard let response = response as? HTTPURLResponse else {
            throw URLError.invalidResponse
        }
        if let responseValidator {
            try responseValidator.validate(response: response, data: data)
        } else if data?.count ?? 0 == 0 || response.isError {
            throw URLError(URLError.Code(rawValue: response.statusCode))
        } else if response.mimeType != .jsonMimeType {
            throw URLError.invalidResponse
        }
    }

}
