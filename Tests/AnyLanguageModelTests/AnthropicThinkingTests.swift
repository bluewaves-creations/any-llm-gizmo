import Foundation
import Testing

@testable import AnyLanguageModel

@Suite("AnthropicThinking")
struct AnthropicThinkingTests {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Test func responseThinkingContentDefaultsToNil() {
        let response = Transcript.Response(
            id: "r1",
            assetIDs: [],
            segments: [.text(.init(content: "Hello"))]
        )
        #expect(response.thinkingContent == nil)
    }

    @Test func responseWithThinkingContentRoundTrip() throws {
        let response = Transcript.Response(
            id: "r1",
            assetIDs: [],
            segments: [.text(.init(content: "Hello"))],
            thinkingContent: "Let me think about this..."
        )
        let data = try encoder.encode(response)
        let decoded = try decoder.decode(Transcript.Response.self, from: data)
        #expect(decoded.thinkingContent == "Let me think about this...")
        #expect(decoded == response)
    }

    @Test func responseWithoutThinkingContentBackwardCompatible() throws {
        // Encode a response WITHOUT thinkingContent, then strip the field from JSON,
        // then decode — should still work with nil thinkingContent
        let original = Transcript.Response(
            id: "r1",
            assetIDs: [],
            segments: [.text(.init(id: "s1", content: "Hi"))]
        )
        var data = try encoder.encode(original)
        // Decode as dictionary, remove thinkingContent, re-encode
        var dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        dict.removeValue(forKey: "thinkingContent")
        data = try JSONSerialization.data(withJSONObject: dict)
        let decoded = try decoder.decode(Transcript.Response.self, from: data)
        #expect(decoded.thinkingContent == nil)
        #expect(decoded.id == "r1")
    }

    @Test func thinkingContentBlockJSONDecode() throws {
        // Test the JSON contract for thinking content blocks
        struct ThinkingBlock: Codable {
            let type: String
            let thinking: String
        }
        let json = #"{"type":"thinking","thinking":"Let me think..."}"#.data(using: .utf8)!
        let block = try decoder.decode(ThinkingBlock.self, from: json)
        #expect(block.type == "thinking")
        #expect(block.thinking == "Let me think...")
    }

    @Test func thinkingDeltaJSONDecode() throws {
        struct ThinkingDelta: Codable {
            let type: String
            let thinking: String
        }
        let json = #"{"type":"thinking_delta","thinking":"partial thought"}"#.data(using: .utf8)!
        let delta = try decoder.decode(ThinkingDelta.self, from: json)
        #expect(delta.type == "thinking_delta")
        #expect(delta.thinking == "partial thought")
    }

    @Test func contentBlockStartThinkingType() throws {
        struct ContentBlockStart: Codable {
            let type: String
            let thinking: String?
        }
        let json = #"{"type":"thinking","thinking":""}"#.data(using: .utf8)!
        let block = try decoder.decode(ContentBlockStart.self, from: json)
        #expect(block.type == "thinking")
        #expect(block.thinking == "")
    }

    @Test func transcriptResponseThinkingCodable() throws {
        let response = Transcript.Response(
            id: "r1",
            assetIDs: ["a1"],
            segments: [.text(.init(id: "s1", content: "Result"))],
            thinkingContent: "My reasoning"
        )
        let transcript = Transcript(entries: [.response(response)])
        let data = try encoder.encode(transcript)
        let decoded = try decoder.decode(Transcript.self, from: data)
        if case .response(let r) = decoded.first {
            #expect(r.thinkingContent == "My reasoning")
            #expect(r.segments.count == 1)
        } else {
            Issue.record("Expected response entry")
        }
    }
}
