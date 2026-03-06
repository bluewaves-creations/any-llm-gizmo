import Foundation
import Testing

@testable import AnyLanguageModel

/// URLProtocol subclass that captures request headers and returns a mock response.
final class HeaderCapturingProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var capturedRequests: [URLRequest] = []
    nonisolated(unsafe) static var mockResponseBody: Data = Data()
    nonisolated(unsafe) static var mockStatusCode: Int = 200

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.capturedRequests.append(request)
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: Self.mockStatusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.mockResponseBody)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    static func reset() {
        capturedRequests = []
        mockStatusCode = 200
        mockResponseBody = Data()
    }
}

func makeCapturingSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [HeaderCapturingProtocol.self]
    return URLSession(configuration: config)
}

@Suite("AdditionalHeaders")
struct AdditionalHeadersTests {
    // MARK: - Property Storage Tests

    @Test func openAIDefaultAdditionalHeadersEmpty() {
        let model = OpenAILanguageModel(apiKey: "key", model: "gpt-4")
        #expect(model.additionalHeaders.isEmpty)
    }

    @Test func openAICustomAdditionalHeadersStored() {
        let model = OpenAILanguageModel(
            apiKey: "key",
            model: "gpt-4",
            additionalHeaders: ["X-Custom": "value"]
        )
        #expect(model.additionalHeaders == ["X-Custom": "value"])
    }

    @Test func anthropicDefaultAdditionalHeadersEmpty() {
        let model = AnthropicLanguageModel(apiKey: "key", model: "claude-3")
        #expect(model.additionalHeaders.isEmpty)
    }

    @Test func anthropicCustomAdditionalHeadersStored() {
        let model = AnthropicLanguageModel(
            apiKey: "key",
            model: "claude-3",
            additionalHeaders: ["cf-aig-authorization": "Bearer token"]
        )
        #expect(model.additionalHeaders["cf-aig-authorization"] == "Bearer token")
    }

    @Test func geminiDefaultAdditionalHeadersEmpty() {
        let model = GeminiLanguageModel(apiKey: "key", model: "gemini-pro")
        #expect(model.additionalHeaders.isEmpty)
    }

    @Test func geminiCustomAdditionalHeadersStored() {
        let model = GeminiLanguageModel(
            apiKey: "key",
            model: "gemini-pro",
            additionalHeaders: ["X-Custom": "value"]
        )
        #expect(model.additionalHeaders == ["X-Custom": "value"])
    }

    @Test func openResponsesDefaultAdditionalHeadersEmpty() {
        let model = OpenResponsesLanguageModel(
            baseURL: URL(string: "https://api.example.com/v1/")!,
            apiKey: "key",
            model: "gpt-4"
        )
        #expect(model.additionalHeaders.isEmpty)
    }

    @Test func openResponsesCustomAdditionalHeadersStored() {
        let model = OpenResponsesLanguageModel(
            baseURL: URL(string: "https://api.example.com/v1/")!,
            apiKey: "key",
            model: "gpt-4",
            additionalHeaders: ["cf-aig-authorization": "Bearer token"]
        )
        #expect(model.additionalHeaders["cf-aig-authorization"] == "Bearer token")
    }
}
