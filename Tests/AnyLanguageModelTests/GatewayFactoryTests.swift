import Foundation
import Testing

@testable import AnyLanguageModel

@Suite("GatewayFactory")
struct GatewayFactoryTests {
    // MARK: - vllmMLX

    @Test func vllmMLXDefaultBaseURL() {
        let model = OpenAILanguageModel.vllmMLX(model: "mlx-model")
        #expect(model.baseURL.absoluteString.contains("localhost:8000"))
        #expect(model.model == "mlx-model")
    }

    @Test func vllmMLXCustomBaseURL() {
        let model = OpenAILanguageModel.vllmMLX(
            baseURL: URL(string: "http://192.168.1.10:9000/v1/")!,
            model: "custom-model"
        )
        #expect(model.baseURL.absoluteString.contains("192.168.1.10:9000"))
    }

    @Test func vllmMLXNoAdditionalHeaders() {
        let model = OpenAILanguageModel.vllmMLX(model: "test")
        #expect(model.additionalHeaders.isEmpty)
    }

    // MARK: - openRouter

    @Test func openRouterAdditionalHeaders() {
        let model = OpenResponsesLanguageModel.openRouter(
            gatewayURL: URL(string: "https://gw.example.com/openrouter/")!,
            cfToken: "my-token",
            model: "anthropic/claude-3"
        )
        #expect(model.additionalHeaders["cf-aig-authorization"] == "Bearer my-token")
        #expect(model.model == "anthropic/claude-3")
    }

    @Test func openRouterBaseURLNormalized() {
        let model = OpenResponsesLanguageModel.openRouter(
            gatewayURL: URL(string: "https://gw.example.com/openrouter")!,
            cfToken: "tok",
            model: "m"
        )
        #expect(model.baseURL.absoluteString.hasSuffix("/"))
    }

    // MARK: - anthropicGateway

    @Test func anthropicGatewayAdditionalHeaders() {
        let model = AnthropicLanguageModel.cloudflareGateway(
            gatewayURL: URL(string: "https://gw.example.com/anthropic/")!,
            cfToken: "cf-token-123",
            model: "claude-3-opus"
        )
        #expect(model.additionalHeaders["cf-aig-authorization"] == "Bearer cf-token-123")
        #expect(model.model == "claude-3-opus")
    }

    @Test func anthropicGatewayBaseURLNormalized() {
        let model = AnthropicLanguageModel.cloudflareGateway(
            gatewayURL: URL(string: "https://gw.example.com/anthropic")!,
            cfToken: "tok",
            model: "m"
        )
        #expect(model.baseURL.absoluteString.hasSuffix("/"))
    }
}
