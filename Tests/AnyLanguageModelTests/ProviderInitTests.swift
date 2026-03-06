import Foundation
import Testing

@testable import AnyLanguageModel

@Suite("ProviderInit")
struct ProviderInitTests {
    // MARK: - OpenAI

    @Test func openAIDefaultBaseURL() {
        let model = OpenAILanguageModel(apiKey: "key", model: "gpt-4")
        #expect(model.baseURL.absoluteString.contains("api.openai.com"))
    }

    @Test func openAICustomBaseURLTrailingSlash() {
        let model = OpenAILanguageModel(
            baseURL: URL(string: "https://custom.api.com/v1")!,
            apiKey: "key",
            model: "gpt-4"
        )
        #expect(model.baseURL.absoluteString.hasSuffix("/"))
    }

    @Test func openAIDefaultApiVariant() {
        let model = OpenAILanguageModel(apiKey: "key", model: "gpt-4")
        #expect(model.apiVariant == .chatCompletions)
    }

    @Test func openAIModelStored() {
        let model = OpenAILanguageModel(apiKey: "key", model: "gpt-4-turbo")
        #expect(model.model == "gpt-4-turbo")
    }

    // MARK: - Anthropic

    @Test func anthropicDefaultBaseURL() {
        let model = AnthropicLanguageModel(apiKey: "key", model: "claude-3")
        #expect(model.baseURL.absoluteString.contains("api.anthropic.com"))
    }

    @Test func anthropicCustomBaseURLTrailingSlash() {
        let model = AnthropicLanguageModel(
            baseURL: URL(string: "https://custom.anthropic.com")!,
            apiKey: "key",
            model: "claude-3"
        )
        #expect(model.baseURL.absoluteString.hasSuffix("/"))
    }

    @Test func anthropicDefaultApiVersion() {
        let model = AnthropicLanguageModel(apiKey: "key", model: "claude-3")
        #expect(model.apiVersion == "2023-06-01")
    }

    @Test func anthropicBetasStored() {
        let model = AnthropicLanguageModel(
            apiKey: "key",
            betas: ["beta-1", "beta-2"],
            model: "claude-3"
        )
        #expect(model.betas == ["beta-1", "beta-2"])
    }

    @Test func anthropicModelStored() {
        let model = AnthropicLanguageModel(apiKey: "key", model: "claude-3-opus")
        #expect(model.model == "claude-3-opus")
    }

    // MARK: - Gemini

    @Test func geminiDefaultBaseURL() {
        let model = GeminiLanguageModel(apiKey: "key", model: "gemini-pro")
        #expect(model.baseURL.absoluteString.contains("generativelanguage.googleapis.com"))
    }

    @Test func geminiCustomBaseURLTrailingSlash() {
        let model = GeminiLanguageModel(
            baseURL: URL(string: "https://custom.google.com")!,
            apiKey: "key",
            model: "gemini-pro"
        )
        #expect(model.baseURL.absoluteString.hasSuffix("/"))
    }

    @Test func geminiDefaultApiVersion() {
        let model = GeminiLanguageModel(apiKey: "key", model: "gemini-pro")
        #expect(model.apiVersion == "v1beta")
    }

    // MARK: - OpenResponses

    @Test func openResponsesCustomBaseURLTrailingSlash() {
        let model = OpenResponsesLanguageModel(
            baseURL: URL(string: "https://openrouter.ai/api/v1")!,
            apiKey: "key",
            model: "gpt-4"
        )
        #expect(model.baseURL.absoluteString.hasSuffix("/"))
    }

    @Test func openResponsesModelStored() {
        let model = OpenResponsesLanguageModel(
            baseURL: URL(string: "https://openrouter.ai/api/v1/")!,
            apiKey: "key",
            model: "anthropic/claude-3"
        )
        #expect(model.model == "anthropic/claude-3")
    }
}
