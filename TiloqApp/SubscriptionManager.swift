import Foundation
import StoreKit

actor SubscriptionManager {
    static let shared = SubscriptionManager()

    enum PurchaseOutcome {
        case success
        case userCancelled
        case pending
    }

    enum SubscriptionError: LocalizedError {
        case productUnavailable

        var errorDescription: String? {
            switch self {
            case .productUnavailable:
                "TILOQ Plus isn't available right now. Check your connection and try again."
            }
        }
    }

    private var updatesTask: Task<Void, Never>?

    private init() {}

    func start() {
        guard updatesTask == nil else { return }
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(update)
                await self?.refreshEntitlement()
            }
        }
        Task { await refreshEntitlement() }
    }

    func product() async throws -> Product {
        let products = try await Product.products(for: [TiloqSettings.plusAnnualProductID])
        guard let product = products.first else {
            throw SubscriptionError.productUnavailable
        }
        return product
    }

    func purchase() async throws -> PurchaseOutcome {
        let product = try await product()
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            await handle(verification)
            await refreshEntitlement()
            return .success
        case .userCancelled:
            return .userCancelled
        case .pending:
            return .pending
        @unknown default:
            return .pending
        }
    }

    func restore() async throws {
        try await AppStore.sync()
        await refreshEntitlement()
    }

    func refreshEntitlement() async {
        var isEntitled = Self.isTestFlightBuild
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == TiloqSettings.plusAnnualProductID,
               transaction.revocationDate == nil {
                isEntitled = true
            }
        }
        TiloqSettings.sharedDefaults.set(isEntitled, forKey: TiloqSettings.isPlusSubscriberKey)
    }

    /// TestFlight builds are Release configuration, so `TiloqSettings.isRunningInDebugConfiguration`
    /// is false for them -- they're unlocked here instead, by caching `true` into the same shared
    /// `isPlusSubscriberKey` the extension already reads. The standard way to distinguish a
    /// TestFlight install from a public App Store install: TestFlight's receipt file is always
    /// named "sandboxReceipt"; a real App Store install's is named "receipt".
    nonisolated static var isTestFlightBuild: Bool {
        guard let path = Bundle.main.appStoreReceiptURL?.path else { return false }
        return path.contains("sandboxReceipt")
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        await transaction.finish()
    }
}
