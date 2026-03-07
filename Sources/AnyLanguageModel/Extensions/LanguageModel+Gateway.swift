import Foundation

extension OpenAILanguageModel {
    /// Creates an OpenAI-compatible model for local vllm-mlx inference.
    public static func vllmMLX(
        baseURL: URL = URL(string: "http://localhost:8000/v1/")!,
        model: String
    ) -> OpenAILanguageModel {
        OpenAILanguageModel(
            baseURL: baseURL,
            apiKey: "not-needed",
            model: model
        )
    }

    /// Creates an OpenAI-compatible model routed through Cloudflare AI Gateway custom provider.
    public static func cloudflareHosted(
        gatewayURL: URL,
        cfToken: String,
        apiKey: String,
        model: String
    ) -> OpenAILanguageModel {
        OpenAILanguageModel(
            baseURL: gatewayURL,
            apiKey: apiKey,
            model: model,
            additionalHeaders: ["cf-aig-authorization": "Bearer \(cfToken)"]
        )
    }
}

extension OpenResponsesLanguageModel {
    /// Creates an OpenRouter model routed through Cloudflare AI Gateway.
    public static func openRouter(
        gatewayURL: URL,
        cfToken: String,
        model: String
    ) -> OpenResponsesLanguageModel {
        OpenResponsesLanguageModel(
            baseURL: gatewayURL,
            apiKey: "",
            model: model,
            additionalHeaders: ["cf-aig-authorization": "Bearer \(cfToken)"]
        )
    }
}

extension AnthropicLanguageModel {
    /// Creates an Anthropic model routed through Cloudflare AI Gateway.
    public static func cloudflareGateway(
        gatewayURL: URL,
        cfToken: String,
        model: String
    ) -> AnthropicLanguageModel {
        AnthropicLanguageModel(
            baseURL: gatewayURL,
            apiKey: "",
            model: model,
            additionalHeaders: ["cf-aig-authorization": "Bearer \(cfToken)"]
        )
    }
}
