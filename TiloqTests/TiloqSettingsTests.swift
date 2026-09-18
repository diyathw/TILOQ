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

    @Test("Plus access is denied with no entitlement and no debug override")
    func noAccessByDefault() {
        let defaults = isolatedDefaults()

        #expect(TiloqSettings.hasPlusAccess(in: defaults) == false)
    }

    @Test("A verified subscriber entitlement grants Plus access")
    func subscriberEntitlementGrantsAccess() {
        let defaults = isolatedDefaults()
        defaults.set(true, forKey: TiloqSettings.isPlusSubscriberKey)

        #expect(TiloqSettings.hasPlusAccess(in: defaults) == true)
    }

    #if DEBUG
    @Test("The debug override grants Plus access without a real entitlement")
    func debugOverrideGrantsAccess() {
        let defaults = isolatedDefaults()
        defaults.set(true, forKey: TiloqSettings.debugForcePlusKey)

        #expect(TiloqSettings.hasPlusAccess(in: defaults) == true)
    }
    #endif
}
