import Foundation
import Testing

@testable import AnyLanguageModel

@Suite("TranscriptCodable")
struct TranscriptCodableTests {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Test func fullTranscriptRoundTrip() throws {
        let instructions = Transcript.Instructions(
            id: "instr-1",
            segments: [.text(.init(id: "s1", content: "Be helpful"))],
            toolDefinitions: []
        )
        let prompt = Transcript.Prompt(
            id: "prompt-1",
            segments: [.text(.init(id: "s2", content: "Hello"))]
        )
        let args = try GeneratedContent(json: #"{"city":"Paris"}"#)
        let toolCall = Transcript.ToolCall(id: "tc-1", toolName: "weather", arguments: args)
        let toolCalls = Transcript.ToolCalls(id: "tcs-1", [toolCall])
        let toolOutput = Transcript.ToolOutput(
            id: "to-1",
            toolName: "weather",
            segments: [.text(.init(id: "s3", content: "Sunny"))]
        )
        let response = Transcript.Response(
            id: "resp-1",
            assetIDs: ["asset-1"],
            segments: [.text(.init(id: "s4", content: "It's sunny in Paris"))]
        )

        let transcript = Transcript(entries: [
            .instructions(instructions),
            .prompt(prompt),
            .toolCalls(toolCalls),
            .toolOutput(toolOutput),
            .response(response),
        ])

        let data = try encoder.encode(transcript)
        let decoded = try decoder.decode(Transcript.self, from: data)
        #expect(decoded == transcript)
    }

    @Test func emptyTranscriptRoundTrip() throws {
        let transcript = Transcript()
        let data = try encoder.encode(transcript)
        let decoded = try decoder.decode(Transcript.self, from: data)
        #expect(decoded == transcript)
        #expect(decoded.count == 0)
    }

    @Test func textSegmentRoundTrip() throws {
        let segment = Transcript.Segment.text(.init(id: "t1", content: "Hello world"))
        let data = try encoder.encode(segment)
        let decoded = try decoder.decode(Transcript.Segment.self, from: data)
        #expect(decoded == segment)
    }

    @Test func structuredSegmentRoundTrip() throws {
        let content = try GeneratedContent(json: #"{"key":"value","num":42}"#)
        let segment = Transcript.Segment.structure(
            .init(id: "ss1", source: "test-source", content: content)
        )
        let data = try encoder.encode(segment)
        let decoded = try decoder.decode(Transcript.Segment.self, from: data)
        #expect(decoded == segment)
    }

    @Test func imageSegmentDataRoundTrip() throws {
        let segment = Transcript.Segment.image(
            .init(id: "img1", data: Data([0xCA, 0xFE]), mimeType: "image/png")
        )
        let data = try encoder.encode(segment)
        let decoded = try decoder.decode(Transcript.Segment.self, from: data)
        #expect(decoded == segment)
    }

    @Test func imageSegmentURLRoundTrip() throws {
        let segment = Transcript.Segment.image(
            .init(id: "img2", url: URL(string: "https://example.com/photo.jpg")!)
        )
        let data = try encoder.encode(segment)
        let decoded = try decoder.decode(Transcript.Segment.self, from: data)
        #expect(decoded == segment)
    }

    @Test func toolCallsWithArgumentsRoundTrip() throws {
        let args = try GeneratedContent(json: #"{"query":"swift","limit":10}"#)
        let call = Transcript.ToolCall(id: "call-1", toolName: "search", arguments: args)
        let toolCalls = Transcript.ToolCalls(id: "tcs-1", [call])
        let entry = Transcript.Entry.toolCalls(toolCalls)

        let data = try encoder.encode(entry)
        let decoded = try decoder.decode(Transcript.Entry.self, from: data)
        #expect(decoded == entry)
    }

    @Test func responseWithAssetIDsRoundTrip() throws {
        let response = Transcript.Response(
            id: "r1",
            assetIDs: ["model-v1", "adapter-v2"],
            segments: [.text(.init(id: "rs1", content: "Generated text"))]
        )
        let entry = Transcript.Entry.response(response)

        let data = try encoder.encode(entry)
        let decoded = try decoder.decode(Transcript.Entry.self, from: data)
        #expect(decoded == entry)
    }

    @Test func instructionsWithToolDefinitionsRoundTrip() throws {
        let schema = GenerationSchema(type: String.self, anyOf: ["a"])
        let toolDef = Transcript.ToolDefinition(
            name: "calculator",
            description: "Performs math",
            parameters: schema
        )
        let instructions = Transcript.Instructions(
            id: "instr-td",
            segments: [.text(.init(id: "s1", content: "Use tools"))],
            toolDefinitions: [toolDef]
        )
        let entry = Transcript.Entry.instructions(instructions)

        let data = try encoder.encode(entry)
        let decoded = try decoder.decode(Transcript.Entry.self, from: data)
        #expect(decoded == entry)
    }

    @Test func promptWithGenerationOptionsRoundTrip() throws {
        var options = GenerationOptions(temperature: 0.7)
        options.maximumResponseTokens = 512
        let prompt = Transcript.Prompt(
            id: "p-opts",
            segments: [.text(.init(id: "s1", content: "Generate"))],
            options: options
        )
        let entry = Transcript.Entry.prompt(prompt)

        let data = try encoder.encode(entry)
        let decoded = try decoder.decode(Transcript.Entry.self, from: data)
        #expect(decoded == entry)
    }
}
