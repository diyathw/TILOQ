import Testing
@testable import Tiloq

struct TypeCopyTests {
    @Test("Tone variants are unique")
    func toneVariantsAreUnique() {
        let variants = RewriteTone.allCases.map(TypeCopy.rewrite(for:))

        #expect(Set(variants).count == RewriteTone.allCases.count)
    }

    @Test("Grammar fallback fixes the demonstrated errors")
    func grammarFallbackCorrectsSample() {
        let result = TypeCopy.grammar

        #expect(result.contains("definitely"))
        #expect(result.contains("tomorrow"))
        #expect(result.contains("can’t"))
        #expect(result.contains("discuss the project"))
        #expect(result.contains("defenetely") == false)
    }
}
