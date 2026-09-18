import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage(TiloqSettings.isPlusSubscriberKey, store: TiloqSettings.sharedDefaults)
    private var isPlusSubscriber = false

    @State private var product: Product?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    featureList
                    priceCard
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.red)
                    }
                    actions
                    disclosure
                }
                .padding(20)
            }
            .background(TypeTheme.background)
            .navigationTitle("TILOQ Plus")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .task {
            await loadProduct()
        }
        .onChange(of: isPlusSubscriber) { _, subscribed in
            if subscribed { dismiss() }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundStyle(TypeTheme.rewrite)
            Text("Unlock the fun extras")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
            Text("Every writing tool stays free. TILOQ Plus unlocks the keyboard's cosmetic extras.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 12)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 16) {
            featureRow(icon: "sparkle", title: "RGB Keys", detail: "Animated lighting around every key")
            featureRow(icon: "photo.on.rectangle", title: "Custom Photo Backdrops", detail: "Use any photo as your keyboard background")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TypeTheme.surface)
        .clipShape(.rect(cornerRadius: 12))
    }

    private func featureRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(TypeTheme.rewrite)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Text(detail)
                    .font(.system(size: 12, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var priceCard: some View {
        VStack(spacing: 6) {
            Text("14 days free, then \(displayPrice)/year")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            Text("Cancel anytime during the trial and you won't be charged.")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var displayPrice: String {
        product?.displayPrice ?? "$1.99"
    }

    private var actions: some View {
        VStack(spacing: 10) {
            Button {
                Task { await purchase() }
            } label: {
                if isLoading {
                    ProgressView()
                        .tint(.black)
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Start Free Trial")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(PaywallButtonStyle(primary: true))
            .disabled(isLoading)

            Button {
                Task { await restore() }
            } label: {
                Text("Restore Purchases")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PaywallButtonStyle(primary: false))
            .disabled(isLoading)
        }
    }

    private var disclosure: some View {
        VStack(spacing: 8) {
            Text("TILOQ Plus automatically renews at \(displayPrice)/year after the 14-day free trial unless cancelled at least 24 hours before the trial or the current period ends. Manage or cancel anytime in Settings \u{2192} Apple ID \u{2192} Subscriptions.")
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            NavigationLink("Privacy Policy") {
                PrivacyPolicyView()
            }
            .font(.system(size: 12, weight: .medium, design: .rounded))
        }
        .padding(.bottom, 12)
    }

    private func loadProduct() async {
        await SubscriptionManager.shared.start()
        product = try? await SubscriptionManager.shared.product()
    }

    private func purchase() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            _ = try await SubscriptionManager.shared.purchase()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func restore() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await SubscriptionManager.shared.restore()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct PaywallButtonStyle: ButtonStyle {
    let primary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(primary ? Color.black : Color.white)
            .padding(.vertical, 12)
            .background(primary ? TypeTheme.rewrite : TypeTheme.elevated)
            .clipShape(.rect(cornerRadius: 12))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
