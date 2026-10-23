import Foundation
import RevenueCat

nonisolated enum AnalyticsEvent: String, Sendable {
    case appOpen = "app_open"
    case onboardingComplete = "onboarding_complete"
    case scoreStarted = "score_started"
    case scoreRevealed = "score_revealed"
    case paywallViewed = "paywall_viewed"
    case checkoutStarted = "checkout_started"
    case subscriptionPurchased = "subscription_purchased"
    case paywallClosed = "paywall_closed"
}

nonisolated struct AnalyticsService: Sendable {
    func track(_ event: AnalyticsEvent, properties: [String: String] = [:]) {
        let eventName: String = event.rawValue
        let propertySummary: String

        if properties.isEmpty {
            propertySummary = ""
        } else {
            let pairs: [String] = properties.map { key, value in
                "\(key)=\(value)"
            }
            .sorted()
            propertySummary = " | " + pairs.joined(separator: ", ")
        }

        print("Analytics: \(eventName)\(propertySummary)")

        // Funnel counts land on the RevenueCat customer (free, no extra SDK): last time each step happened.
        guard Purchases.isConfigured else { return }
        var attributes: [String: String] = ["\(eventName)_at": ISO8601DateFormatter().string(from: .now)]
        if let product = properties["product"] {
            attributes["\(eventName)_product"] = product
        }
        Purchases.shared.attribution.setAttributes(attributes)
    }
}
