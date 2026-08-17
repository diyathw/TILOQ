import Testing
@testable import Tiloq

struct LocalAIRequestTests {
    @Test("Grammar request preserves source text")
    func grammarPromptIncludesSource() {
        let request = LocalAIRequest(
            source: TypeCopy.original,
            action: .grammar,
            tone: .casual
        )

        #expect(request.prompt.contains(TypeCopy.original))
        #expect(request.prompt.contains("grammar"))
        #expect(request.prompt.contains("spelling"))
    }

    @Test("Rewrite request includes the selected tone", arguments: RewriteTone.allCases)
    func rewritePromptIncludesTone(_ tone: RewriteTone) {
        let request = LocalAIRequest(source: "See you tomorrow", action: .rewrite, tone: tone)

        #expect(request.prompt.contains(tone.rawValue.lowercased()))
    }

    @Test("Unavailable local AI preserves the user's source", arguments: AIAction.allCases)
    func offlineFallbackPreservesSource(_ action: AIAction) {
        let source = "A production sentence unique to this request."
        let request = LocalAIRequest(source: source, action: action, tone: .casual)

        #expect(request.fallback == source)
    }

    @Test("Generated replacement is trimmed")
    func trimsModelOutput() {
        let result = LocalAIRequest.clean("  Better sentence.\n")

        #expect(result == "Better sentence.")
    }

    @Test("Empty model output uses fallback")
    func emptyOutputUsesFallback() {
        let source = "Keep this exact sentence."
        let request = LocalAIRequest(source: source, action: .grammar, tone: .casual)

        #expect(request.resolved("  \n") == source)
    }
}
