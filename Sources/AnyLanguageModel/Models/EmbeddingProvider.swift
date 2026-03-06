import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

/// A provider that generates embedding vectors from text.
public protocol EmbeddingProvider: Sendable {
    /// The number of dimensions in the embedding vectors.
    var dimensions: Int { get }

    /// Generates embeddings for the given texts.
    func embed(_ texts: [String]) async throws -> [[Float]]
}

/// An embedding provider using the OpenAI-compatible `/v1/embeddings` endpoint.
///
/// Works with OpenAI, vllm-mlx, and other compatible services.
public struct OpenAIEmbeddingProvider: EmbeddingProvider, Sendable {
    public let baseURL: URL
    public let model: String
    public let dimensions: Int
    let additionalHeaders: [String: String]
    private let tokenProvider: @Sendable () -> String
    private let urlSession: URLSession

    public init(
        baseURL: URL = URL(string: "http://localhost:8000/v1/")!,
        apiKey tokenProvider: @escaping @autoclosure @Sendable () -> String,
        model: String,
        dimensions: Int,
        additionalHeaders: [String: String] = [:],
        session: URLSession = URLSession(configuration: .default)
    ) {
        var baseURL = baseURL
        if !baseURL.absoluteString.hasSuffix("/") {
            baseURL = baseURL.appendingPathComponent("")
        }
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.model = model
        self.dimensions = dimensions
        self.additionalHeaders = additionalHeaders
        self.urlSession = session
    }

    public func embed(_ texts: [String]) async throws -> [[Float]] {
        let url = baseURL.appendingPathComponent("embeddings")
        let request = EmbeddingRequest(model: model, input: texts, dimensions: dimensions)
        let body = try JSONEncoder().encode(request)

        let headers = ["Authorization": "Bearer \(tokenProvider())"]
            .merging(additionalHeaders) { _, new in new }

        let response: EmbeddingResponse = try await urlSession.fetch(
            .post,
            url: url,
            headers: headers,
            body: body
        )

        return response.data.sorted(by: { $0.index < $1.index }).map(\.embedding)
    }
}

private struct EmbeddingRequest: Codable, Sendable {
    let model: String
    let input: [String]
    let dimensions: Int
}

private struct EmbeddingResponse: Codable, Sendable {
    let data: [EmbeddingData]

    struct EmbeddingData: Codable, Sendable {
        let index: Int
        let embedding: [Float]
    }
}
