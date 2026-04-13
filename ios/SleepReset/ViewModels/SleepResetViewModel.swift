import Foundation
import Observation
import RevenueCat

@Observable
@MainActor
final class SleepResetViewModel {
    var path: [SleepResetStep] = []
    var selectedGoal: SleepGoal = .improveSleep
    var chronotype: SleepChronotype = .nightOwl
    var sleepLatency: SleepLatency = .under30
    var nightAwakenings: NightAwakenings = .once
    var consistency: SleepConsistency = .inconsistent
    var weekendDrift: WeekendDrift = .twoToThree
    var eveningState: EveningState = .mentallyBusy
    var windDownStyle: WindDownStyle = .nothing
    var bedtime: Date = SleepResetViewModel.defaultBedtime
    var wakeTime: Date = SleepResetViewModel.defaultWakeTime
    var energyLevel: EnergyLevel = .low
    var disruption: SleepDisruption = .lateNights
    var motivation: MotivationLevel = .ready
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

    var onboardingProgress: CGFloat {
        CGFloat(currentQuestionIndex + 1) / CGFloat(questionStepCount + 1)
    }

    var personalizationSummary: String {
        [
            selectedGoal.rawValue,
            chronotype.rawValue,
            eveningState.rawValue,
            disruption.rawValue
        ]
        .joined(separator: " · ")
    }

    private var questionStepCount: Int {
        11
    }

    private var currentQuestionIndex: Int {
        switch path.last ?? .welcome {
        case .goals: 0
        case .chronotype: 1
        case .sleepLatency: 2
        case .nightAwakenings: 3
        case .consistency: 4
        case .weekendDrift: 5
        case .eveningState: 6
        case .windDownStyle: 7
        case .bedtime: 8
        case .wakeTime: 9
        case .energyLevel: 10
        case .disruption: 11
        case .motivation: 12
        default: 0
        }
    }

    func start() {
        path = [.goals]
    }

    func continueFromGoals() {
        path.append(.chronotype)
    }

    func continueFromChronotype() {
        path.append(.sleepLatency)
    }

    func continueFromSleepLatency() {
        path.append(.nightAwakenings)
    }

    func continueFromNightAwakenings() {
        path.append(.consistency)
    }

    func continueFromConsistency() {
        path.append(.weekendDrift)
    }

    func continueFromWeekendDrift() {
        path.append(.eveningState)
    }

    func continueFromEveningState() {
        path.append(.windDownStyle)
    }

    func continueFromWindDownStyle() {
        path.append(.bedtime)
    }

    func continueFromBedtime() {
        path.append(.wakeTime)
    }

    func continueFromWakeTime() {
        path.append(.energyLevel)
    }

    func continueFromEnergyLevel() {
        path.append(.disruption)
    }

    func continueFromDisruption() {
        path.append(.motivation)
    }

    func continueFromMotivation() {
        analyticsService.track(.onboardingComplete)
        Task {
            await analyze()
        }
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
            disruption: disruption,
            chronotype: chronotype,
            sleepLatency: sleepLatency,
            nightAwakenings: nightAwakenings,
            consistency: consistency,
            weekendDrift: weekendDrift,
            eveningState: eveningState,
            motivation: motivation
        )
        let plan: ResetPlan = scoringService.plan(
            bedtime: bedtime,
            wakeTime: wakeTime,
            disruption: disruption,
            windDownStyle: windDownStyle,
            eveningState: eveningState
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

    func showReviewPrompt() {
        guard path.last != .reviewPrompt else { return }
        path.append(.reviewPrompt)
    }

    func showPaywall() {
        guard path.last != .paywall else { return }
        path.append(.paywall)
        analyticsService.track(.paywallViewed)
    }

    func continueFromReviewPrompt() {
        if path.last == .reviewPrompt {
            _ = path.popLast()
        }
        showPaywall()
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
        guard let currentOffering else {
            return nil
        }

        switch selectedProduct {
        case .weekly:
            return currentOffering.weekly
            ?? currentOffering.availablePackages.first(where: { $0.packageType == .weekly })
            ?? currentOffering.availablePackages.first(where: { $0.storeProduct.productIdentifier == selectedProduct.revenueCatProductID })
        case .yearly:
            return currentOffering.annual
            ?? currentOffering.availablePackages.first(where: { $0.packageType == .annual })
            ?? currentOffering.availablePackages.first(where: { $0.storeProduct.productIdentifier == selectedProduct.revenueCatProductID })
        }
    }

    func resetFlow() {
        path = []
        hasUnlockedPlan = false
        result = nil
        plan = nil
        selectedGoal = .improveSleep
        chronotype = .nightOwl
        sleepLatency = .under30
        nightAwakenings = .once
        consistency = .inconsistent
        weekendDrift = .twoToThree
        eveningState = .mentallyBusy
        windDownStyle = .nothing
        bedtime = Self.defaultBedtime
        wakeTime = Self.defaultWakeTime
        energyLevel = .low
        disruption = .lateNights
        motivation = .ready
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
