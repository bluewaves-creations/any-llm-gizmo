import Foundation
import Testing

@testable import AnyLanguageModel

@Suite("EmbeddingProvider")
struct EmbeddingProviderTests {
    @Test func initStoresProperties() {
        let provider = OpenAIEmbeddingProvider(
            apiKey: "test-key",
            model: "text-embedding-3-small",
            dimensions: 512
        )
        #expect(provider.model == "text-embedding-3-small")
        #expect(provider.dimensions == 512)
        #expect(provider.additionalHeaders.isEmpty)
    }

    @Test func initDefaultBaseURL() {
        let provider = OpenAIEmbeddingProvider(
            apiKey: "key",
            model: "model",
            dimensions: 256
        )
        #expect(provider.baseURL.absoluteString.contains("localhost:8000"))
    }

    @Test func initCustomBaseURL() {
        let provider = OpenAIEmbeddingProvider(
            baseURL: URL(string: "https://api.openai.com/v1/")!,
            apiKey: "key",
            model: "model",
            dimensions: 1536
        )
        #expect(provider.baseURL.absoluteString.contains("api.openai.com"))
    }

    @Test func embeddingRequestEncodeDecode() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        struct EmbeddingRequest: Codable {
            let model: String
            let input: [String]
            let dimensions: Int
        }

        let request = EmbeddingRequest(model: "model", input: ["hello", "world"], dimensions: 256)
        let data = try encoder.encode(request)
        let decoded = try decoder.decode(EmbeddingRequest.self, from: data)
        #expect(decoded.model == "model")
        #expect(decoded.input == ["hello", "world"])
        #expect(decoded.dimensions == 256)
    }

    @Test func embeddingResponseDecode() throws {
        let json = """
        {"data":[{"index":0,"embedding":[0.1,0.2,0.3]},{"index":1,"embedding":[0.4,0.5,0.6]}]}
        """.data(using: .utf8)!

        struct EmbeddingResponse: Codable {
            let data: [EmbeddingData]
            struct EmbeddingData: Codable {
                let index: Int
                let embedding: [Float]
            }
        }

        let response = try JSONDecoder().decode(EmbeddingResponse.self, from: json)
        #expect(response.data.count == 2)
        #expect(response.data[0].embedding == [0.1, 0.2, 0.3])
        #expect(response.data[1].index == 1)
    }
}
