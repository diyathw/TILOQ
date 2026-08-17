import Foundation
import FoundationModels

struct LocalAIRequest: Sendable {
    let source: String
    let action: AIAction
    let tone: RewriteTone

    var prompt: String {
        switch action {
        case .grammar:
            "Correct grammar, spelling, punctuation, and capitalization. Keep the original voice: \(source)"
        case .rewrite:
            "Rewrite this in a \(tone.rawValue.lowercased()) tone: \(source)"
        case .improve:
            "Improve clarity, flow, and word choice while staying concise: \(source)"
        }
    }

    var fallback: String {
        source
    }

    static func clean(_ response: String) -> String {
        response.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func resolved(_ response: String) -> String {
        let cleaned = Self.clean(response)
        return cleaned.isEmpty ? fallback : cleaned
    }
}

actor LocalAIEngine {
    static let shared = LocalAIEngine()

    enum EngineState: Equatable {
        case ready
        case deviceNotEligible
        case appleIntelligenceDisabled
        case modelPreparing

        var label: String {
            switch self {
            case .ready: "Apple Intelligence Ready"
            case .deviceNotEligible: "Device Not Eligible"
            case .appleIntelligenceDisabled: "Enable Apple Intelligence"
            case .modelPreparing: "Model Preparing"
            }
        }
    }

    nonisolated static var state: EngineState {
        switch SystemLanguageModel.default.availability {
        case .available:
            .ready
        case .unavailable(.deviceNotEligible):
            .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            .appleIntelligenceDisabled
        case .unavailable(.modelNotReady):
            .modelPreparing
        case .unavailable:
            .modelPreparing
        }
    }

    func transform(_ source: String, action: AIAction, tone: RewriteTone) async -> String {
        let request = LocalAIRequest(source: source, action: action, tone: tone)
        guard Self.state == .ready else {
            return request.fallback
        }

        let model = SystemLanguageModel(
            useCase: .general,
            guardrails: .permissiveContentTransformations
        )
        let session = LanguageModelSession(
            model: model,
            instructions: """
            You edit writing directly on this device. Preserve the writer's meaning and factual details.
            Return only the replacement text with no quotation marks, label, explanation, or markdown.
            """
        )

        do {
            let response = try await session.respond(
                to: request.prompt,
                options: GenerationOptions(temperature: 0.2)
            )
            return request.resolved(response.content)
        } catch {
            return request.fallback
        }
    }
}
