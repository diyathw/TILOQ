import Foundation
import Testing
@testable import Tiloq

struct TiloqSettingsTests {
    private func isolatedDefaults() -> UserDefaults {
        let suiteName = "TiloqSettingsTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }

    @Test("Debug builds are unlocked by default with no override set")
    func debugBuildIsUnlockedByDefault() {
        let defaults = isolatedDefaults()

        #expect(TiloqSettings.hasPlusAccess(in: defaults, isDebugBuild: true) == true)
    }

    @Test("Turning the debug override off previews the locked, free experience")
    func debugOverrideCanPreviewLockedState() {
        let defaults = isolatedDefaults()
        defaults.set(false, forKey: TiloqSettings.debugForcePlusKey)

        #expect(TiloqSettings.hasPlusAccess(in: defaults, isDebugBuild: true) == false)
    }

    @Test("Turning the debug override on unlocks explicitly")
    func debugOverrideCanForceUnlock() {
        let defaults = isolatedDefaults()
        defaults.set(true, forKey: TiloqSettings.debugForcePlusKey)

        #expect(TiloqSettings.hasPlusAccess(in: defaults, isDebugBuild: true) == true)
    }

    @Test("Release builds (App Store or TestFlight) deny access with no cached entitlement")
    func releaseBuildRequiresRealEntitlement() {
        let defaults = isolatedDefaults()

        #expect(TiloqSettings.hasPlusAccess(in: defaults, isDebugBuild: false) == false)
    }

    @Test("Release builds honor a cached subscriber entitlement")
    func releaseBuildHonorsSubscriberEntitlement() {
        let defaults = isolatedDefaults()
        defaults.set(true, forKey: TiloqSettings.isPlusSubscriberKey)

        #expect(TiloqSettings.hasPlusAccess(in: defaults, isDebugBuild: false) == true)
    }

    @Test("Release builds ignore the debug override entirely")
    func releaseBuildIgnoresDebugOverride() {
        let defaults = isolatedDefaults()
        defaults.set(true, forKey: TiloqSettings.debugForcePlusKey)

        #expect(TiloqSettings.hasPlusAccess(in: defaults, isDebugBuild: false) == false)
    }
}
