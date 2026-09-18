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
        var isEntitled = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == TiloqSettings.plusAnnualProductID,
               transaction.revocationDate == nil {
                isEntitled = true
            }
        }
        TiloqSettings.sharedDefaults.set(isEntitled, forKey: TiloqSettings.isPlusSubscriberKey)
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        await transaction.finish()
    }
}
