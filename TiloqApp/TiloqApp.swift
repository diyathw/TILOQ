import SwiftUI

@main
struct TiloqApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .task {
                    await SubscriptionManager.shared.start()
                }
        }
    }
}
