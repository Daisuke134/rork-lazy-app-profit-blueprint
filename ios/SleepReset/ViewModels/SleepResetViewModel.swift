import Foundation
import Observation
import RevenueCat

@Observable
@MainActor
final class SleepResetViewModel {
    var path: [SleepResetStep] = []
    var selectedGoal: SleepGoal = .improveSleep
    var bedtime: Date = SleepResetViewModel.defaultBedtime
    var wakeTime: Date = SleepResetViewModel.defaultWakeTime
    var energyLevel: EnergyLevel = .low
    var disruption: SleepDisruption = .lateNights
    var result: SleepResetResult?
    var plan: ResetPlan?
    var selectedProduct: SubscriptionProduct = .yearly
    var currentOffering: Offering?
    var isAnalyzing: Bool = false
    var isLoadingProducts: Bool = false
    var isPurchasing: Bool = false
    var paywallErrorMessage: String?
    var hasUnlockedPlan: Bool = false
    var progressPoints: [ProgressPoint] = [
        ProgressPoint(day: "Mon", score: 41),
        ProgressPoint(day: "Tue", score: 48),
        ProgressPoint(day: "Wed", score: 56),
        ProgressPoint(day: "Thu", score: 63),
        ProgressPoint(day: "Fri", score: 71)
    ]

    private let scoringService: SleepResetScoringService = SleepResetScoringService()
    private let analyticsService: AnalyticsService = AnalyticsService()

    init() {
        analyticsService.track(.appOpen)
        Task {
            await refreshSubscriptionState()
        }
        Task {
            await observeCustomerInfo()
        }
        Task {
            await loadOffering()
        }
    }

    func start() {
        path = [.goals]
    }

    func continueFromGoals() {
        analyticsService.track(.onboardingComplete)
        path.append(.bedtime)
    }

    func continueFromBedtime() {
        path.append(.wakeTime)
    }

    func continueFromWakeTime() {
        path.append(.disruption)
    }

    func analyze() async {
        isAnalyzing = true
        analyticsService.track(.scoreStarted)
        path.append(.analyzing)

        do {
            try await Task.sleep(for: .milliseconds(1400))
        } catch {
            isAnalyzing = false
            if path.last == .analyzing {
                _ = path.popLast()
            }
            return
        }

        let result: SleepResetResult = scoringService.score(
            bedtime: bedtime,
            wakeTime: wakeTime,
            energyLevel: energyLevel,
            disruption: disruption
        )
        let plan: ResetPlan = scoringService.plan(
            bedtime: bedtime,
            wakeTime: wakeTime,
            disruption: disruption
        )

        self.result = result
        self.plan = plan
        isAnalyzing = false

        if path.last == .analyzing {
            _ = path.popLast()
        }
        path.append(.result)
        analyticsService.track(.scoreRevealed, properties: ["score": "\(result.score)"])
    }

    func showPaywall() {
        guard path.last != .paywall else { return }
        path.append(.paywall)
        analyticsService.track(.paywallViewed)
    }

    func purchaseSelectedPlan() async {
        guard let package = selectedPackage else {
            paywallErrorMessage = "Subscription options are still loading. Please try again in a moment."
            return
        }

        analyticsService.track(.checkoutStarted, properties: ["product": selectedProduct.title])
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)
            guard !result.userCancelled else {
                return
            }

            let isPremium: Bool = result.customerInfo.entitlements["premium"]?.isActive == true
            hasUnlockedPlan = isPremium

            if isPremium {
                analyticsService.track(.subscriptionPurchased, properties: ["product": selectedProduct.title])
                path = [.dashboard]
            }
        } catch ErrorCode.purchaseCancelledError {
            return
        } catch {
            paywallErrorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            let isPremium: Bool = customerInfo.entitlements["premium"]?.isActive == true
            hasUnlockedPlan = isPremium

            if isPremium {
                analyticsService.track(.subscriptionPurchased, properties: ["product": "restored"])
                path = [.dashboard]
            } else {
                paywallErrorMessage = "No active subscription was found to restore."
            }
        } catch {
            paywallErrorMessage = error.localizedDescription
        }
    }

    func loadOffering() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            currentOffering = offerings.current
        } catch {
            paywallErrorMessage = error.localizedDescription
        }
    }

    func refreshSubscriptionState() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            hasUnlockedPlan = customerInfo.entitlements["premium"]?.isActive == true
            if hasUnlockedPlan {
                path = [.dashboard]
            }
        } catch {
            paywallErrorMessage = error.localizedDescription
        }
    }

    func clearPaywallError() {
        paywallErrorMessage = nil
    }

    private func observeCustomerInfo() async {
        for await customerInfo in Purchases.shared.customerInfoStream {
            let isPremium: Bool = customerInfo.entitlements["premium"]?.isActive == true
            hasUnlockedPlan = isPremium

            if isPremium {
                path = [.dashboard]
            }
        }
    }

    private var selectedPackage: Package? {
        currentOffering?.availablePackages.first(where: { $0.storeProduct.productIdentifier == selectedProduct.revenueCatProductID })
    }

    func resetFlow() {
        path = []
        hasUnlockedPlan = false
        result = nil
        plan = nil
        selectedGoal = .improveSleep
        bedtime = Self.defaultBedtime
        wakeTime = Self.defaultWakeTime
        disruption = .lateNights
        selectedProduct = .yearly
    }

    private static var defaultBedtime: Date {
        let calendar: Calendar = Calendar.current
        return calendar.date(bySettingHour: 0, minute: 30, second: 0, of: .now) ?? .now
    }

    private static var defaultWakeTime: Date {
        let calendar: Calendar = Calendar.current
        return calendar.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
    }
}
