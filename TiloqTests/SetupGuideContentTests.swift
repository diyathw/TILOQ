import Testing
@testable import Tiloq

struct SetupGuideContentTests {
    @Test("Primary navigation includes a dedicated decrypt tab")
    func primaryNavigationIncludesDecrypt() {
        #expect(AppTab.allCases == [.setup, .keyboard, .decrypt, .settings])
    }

    @Test("Setup guide follows the activation journey")
    func setupSequence() {
        let steps = SetupGuideContent.steps

        #expect(steps.count == 4)
        #expect(steps.map(\.title) == ["Add TILOQ", "Switch keyboards", "Select your writing", "Fix it instantly"])
    }

    @Test("Setup guide provides the exact Settings path")
    func settingsPath() {
        #expect(SetupGuideContent.settingsPath == "General → Keyboard → Keyboards → Add New Keyboard → TILOQ")
    }

    @Test("TILOQ setup never asks for Full Access")
    func fullAccessIsNotRequired() {
        #expect(SetupGuideContent.requiresFullAccess == false)
    }
}
