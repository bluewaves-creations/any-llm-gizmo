import Foundation
import Testing

@testable import AnyLanguageModel

@Suite("AnthropicContentCodable")
struct AnthropicContentCodableTests {
    private let decoder = JSONDecoder()

    // Mirror structs for testing private Anthropic types via JSON contract

    private struct TextBlock: Codable {
        let type: String
        let text: String
    }

    private struct ImageBlock: Codable {
        let type: String
        let source: ImageSource

        struct ImageSource: Codable {
            let type: String
            let mediaType: String?
            let data: String?
            let url: String?

            enum CodingKeys: String, CodingKey {
                case type
                case mediaType = "media_type"
                case data
                case url
            }
        }
    }

    private struct ToolUseBlock: Decodable {
        let type: String
        let id: String
        let name: String
        let input: [String: String]?
    }

    private struct ToolResultBlock: Codable {
        let type: String
        let toolUseId: String
        let content: [TextBlock]

        enum CodingKeys: String, CodingKey {
            case type
            case toolUseId = "tool_use_id"
            case content
        }
    }

    private struct MessageResponse: Codable {
        let id: String
        let type: String
        let role: String
        let content: [ContentBlock]
        let model: String
        let stopReason: String?

        enum CodingKeys: String, CodingKey {
            case id, type, role, content, model
            case stopReason = "stop_reason"
        }
    }

    private struct ContentBlock: Codable {
        let type: String
    }

    private struct ErrorResponse: Codable {
        let error: ErrorDetail
        struct ErrorDetail: Codable {
            let type: String
            let message: String
        }
    }

    private struct DeltaEvent: Codable {
        let type: String
        let index: Int
        let delta: DeltaPayload

        struct DeltaPayload: Codable {
            let type: String
            let text: String?
            let partialJson: String?

            enum CodingKeys: String, CodingKey {
                case type
                case text
                case partialJson = "partial_json"
            }
        }
    }

    @Test func textContentBlockJSON() throws {
        let json = #"{"type":"text","text":"Hello world"}"#.data(using: .utf8)!
        let block = try decoder.decode(TextBlock.self, from: json)
        #expect(block.type == "text")
        #expect(block.text == "Hello world")
    }

    @Test func imageContentBlockBase64JSON() throws {
        let json = #"{"type":"image","source":{"type":"base64","media_type":"image/png","data":"AAAA"}}"#
            .data(using: .utf8)!
        let block = try decoder.decode(ImageBlock.self, from: json)
        #expect(block.type == "image")
        #expect(block.source.type == "base64")
        #expect(block.source.mediaType == "image/png")
        #expect(block.source.data == "AAAA")
    }

    @Test func imageContentBlockURLJSON() throws {
        let json = #"{"type":"image","source":{"type":"url","url":"https://example.com/img.png"}}"#
            .data(using: .utf8)!
        let block = try decoder.decode(ImageBlock.self, from: json)
        #expect(block.source.type == "url")
        #expect(block.source.url == "https://example.com/img.png")
    }

    @Test func toolUseContentBlockJSON() throws {
        let json = #"{"type":"tool_use","id":"tu_1","name":"calculator","input":{"expr":"2+2"}}"#
            .data(using: .utf8)!
        let block = try decoder.decode(ToolUseBlock.self, from: json)
        #expect(block.type == "tool_use")
        #expect(block.id == "tu_1")
        #expect(block.name == "calculator")
        #expect(block.input?["expr"] == "2+2")
    }

    @Test func toolResultContentBlockJSON() throws {
        let json = """
        {"type":"tool_result","tool_use_id":"tu_1","content":[{"type":"text","text":"4"}]}
        """.data(using: .utf8)!
        let block = try decoder.decode(ToolResultBlock.self, from: json)
        #expect(block.type == "tool_result")
        #expect(block.toolUseId == "tu_1")
        #expect(block.content.first?.text == "4")
    }

    @Test func messageResponseJSON() throws {
        let json = """
        {"id":"msg_1","type":"message","role":"assistant","content":[{"type":"text","text":"Hi"}],"model":"claude-3","stop_reason":"end_turn"}
        """.data(using: .utf8)!
        let resp = try decoder.decode(MessageResponse.self, from: json)
        #expect(resp.id == "msg_1")
        #expect(resp.role == "assistant")
        #expect(resp.model == "claude-3")
        #expect(resp.stopReason == "end_turn")
    }

    @Test func errorResponseJSON() throws {
        let json = #"{"error":{"type":"invalid_request_error","message":"Bad request"}}"#
            .data(using: .utf8)!
        let resp = try decoder.decode(ErrorResponse.self, from: json)
        #expect(resp.error.type == "invalid_request_error")
        #expect(resp.error.message == "Bad request")
    }

    @Test func contentBlockDeltaTextDeltaJSON() throws {
        let json = #"{"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}"#
            .data(using: .utf8)!
        let event = try decoder.decode(DeltaEvent.self, from: json)
        #expect(event.type == "content_block_delta")
        #expect(event.index == 0)
        #expect(event.delta.type == "text_delta")
        #expect(event.delta.text == "Hello")
    }

    @Test func contentBlockDeltaInputJsonDeltaJSON() throws {
        let json = """
        {"type":"content_block_delta","index":1,"delta":{"type":"input_json_delta","partial_json":"{\\"key\\""}}
        """.data(using: .utf8)!
        let event = try decoder.decode(DeltaEvent.self, from: json)
        #expect(event.delta.type == "input_json_delta")
        #expect(event.delta.partialJson == #"{"key""#)
    }

    @Test func contentBlockDeltaUnknownTypeDecodesAsIgnored() throws {
        // Unknown delta types should not crash — they just decode with type field
        let json = #"{"type":"content_block_delta","index":0,"delta":{"type":"future_delta"}}"#
            .data(using: .utf8)!
        let event = try decoder.decode(DeltaEvent.self, from: json)
        #expect(event.delta.type == "future_delta")
    }
}
