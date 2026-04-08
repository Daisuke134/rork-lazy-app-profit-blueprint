import Foundation

nonisolated enum AnalyticsEvent: String, Sendable {
    case appOpen = "app_open"
    case onboardingComplete = "onboarding_complete"
    case scoreStarted = "score_started"
    case scoreRevealed = "score_revealed"
    case paywallViewed = "paywall_viewed"
    case checkoutStarted = "checkout_started"
    case subscriptionPurchased = "subscription_purchased"
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
    }
}
