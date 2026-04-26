import CoreGraphics
import Foundation
import Observation
import RevenueCat

@Observable
@MainActor
final class SleepResetViewModel {
    var path: [SleepResetStep] = []
    var selectedGoal: SleepGoal?
    var chronotype: SleepChronotype?
    var sleepLatency: SleepLatency?
    var nightAwakenings: NightAwakenings?
    var consistency: SleepConsistency?
    var weekendDrift: WeekendDrift?
    var eveningState: EveningState?
    var windDownStyle: WindDownStyle?
    var bedtime: Date = SleepResetViewModel.defaultBedtime
    var wakeTime: Date = SleepResetViewModel.defaultWakeTime
    var energyLevel: EnergyLevel?
    var disruption: SleepDisruption?
    var motivation: MotivationLevel?
    var result: SleepResetResult?
    var plan: ResetPlan?
    var selectedProduct: SubscriptionProduct = .yearly
    var currentOffering: Offering?
    var isAnalyzing: Bool = false
    var isLoadingProducts: Bool = false
    var isPurchasing: Bool = false
    var paywallErrorMessage: String?
    var hasUnlockedPlan: Bool = false
    var breathworkSessions: [BreathworkSession] = []
    private var hasRequestedReviewPrompt: Bool = false

    private let scoringService: SleepResetScoringService = SleepResetScoringService()
    private let analyticsService: AnalyticsService = AnalyticsService()
    private let defaults: UserDefaults = .standard

    init() {
        analyticsService.track(.appOpen)
        loadBreathworkSessions()
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
            selectedGoal?.rawValue,
            chronotype?.rawValue,
            eveningState?.rawValue,
            disruption?.rawValue
        ]
        .compactMap { $0 }
        .joined(separator: " · ")
    }

    var breathworkInsight: BreathworkInsight {
        let calendar: Calendar = .current
        let sortedSessions: [BreathworkSession] = breathworkSessions.sorted { $0.completedAt > $1.completedAt }
        let groupedByDay: [Date: [BreathworkSession]] = Dictionary(grouping: sortedSessions) { session in
            calendar.startOfDay(for: session.completedAt)
        }
        let recentDays: [ProgressDay] = (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else {
                return nil
            }

            let dayStart: Date = calendar.startOfDay(for: date)
            let sessions: [BreathworkSession] = groupedByDay[dayStart] ?? []
            return ProgressDay(
                id: dayStart,
                date: dayStart,
                label: offset == 0 ? "Today" : dayStart.formatted(.dateTime.weekday(.abbreviated)),
                didComplete: !sessions.isEmpty,
                sessionCount: sessions.count
            )
        }
        let currentStreak: Int = streakCount(from: recentDays)
        let longestStreak: Int = longestStreakCount(for: groupedByDay.keys.sorted())
        let completedDaysThisWeek: Int = recentDays.filter(\.didComplete).count
        let totalSessions: Int = sortedSessions.count
        let totalMinutes: Int = sortedSessions.reduce(0) { partialResult, session in
            partialResult + Int((Double(session.durationSeconds) / 60.0).rounded(.up))
        }

        return BreathworkInsight(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            completedDaysThisWeek: completedDaysThisWeek,
            totalSessions: totalSessions,
            totalMinutes: totalMinutes,
            completedToday: recentDays.first?.didComplete ?? false,
            recentDays: recentDays
        )
    }

    var progressPoints: [ProgressPoint] {
        breathworkInsight.recentDays.reversed().map { day in
            ProgressPoint(day: day.label, score: day.didComplete ? max(28, day.sessionCount * 32) : 10)
        }
    }

    private var questionStepCount: Int {
        9
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
        default: 0
        }
    }

    func start() {
        path = [.goals]
    }

    func continueFromGoals() {
        guard selectedGoal != nil else { return }
        path.append(.chronotype)
    }

    func continueFromChronotype() {
        guard chronotype != nil else { return }
        path.append(.sleepLatency)
    }

    func continueFromSleepLatency() {
        guard sleepLatency != nil else { return }
        path.append(.nightAwakenings)
    }

    func continueFromNightAwakenings() {
        guard nightAwakenings != nil else { return }
        path.append(.consistency)
    }

    func continueFromConsistency() {
        guard consistency != nil else { return }
        path.append(.weekendDrift)
    }

    func continueFromWeekendDrift() {
        guard weekendDrift != nil else { return }
        path.append(.eveningState)
    }

    func continueFromEveningState() {
        guard eveningState != nil else { return }
        path.append(.windDownStyle)
    }

    func continueFromWindDownStyle() {
        guard windDownStyle != nil else { return }
        path.append(.bedtime)
    }

    func continueFromBedtime() {
        path.append(.wakeTime)
    }

    func continueFromWakeTime() {
        energyLevel = .okay
        disruption = .lateNights
        motivation = .ready
        showReviewPrompt()
    }

    func continueFromEnergyLevel() {
        guard energyLevel != nil else { return }
        path.append(.disruption)
    }

    func continueFromDisruption() {
        guard disruption != nil else { return }
        path.append(.motivation)
    }

    func continueFromMotivation() {
        guard motivation != nil else { return }
        analyticsService.track(.onboardingComplete)
        Task {
            await analyze()
        }
    }

    func analyze() async {
        guard
            let chronotype,
            let sleepLatency,
            let nightAwakenings,
            let consistency,
            let weekendDrift,
            let eveningState,
            let disruption,
            let motivation,
            let energyLevel
        else {
            return
        }

        isAnalyzing = true
        analyticsService.track(.scoreStarted)
        path.append(.analyzing)

        do {
            try await Task.sleep(for: .milliseconds(2800))
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
            windDownStyle: windDownStyle ?? .breathwork,
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
        analyticsService.track(.onboardingComplete)
        Task {
            await analyze()
        }
    }

    func shouldRequestReviewPrompt() -> Bool {
        guard !hasRequestedReviewPrompt else { return false }
        hasRequestedReviewPrompt = true
        return true
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

    func recordBreathworkSession(completedCycles: Int, totalCycles: Int, durationSeconds: Int) {
        let session = BreathworkSession(
            id: UUID(),
            completedAt: .now,
            completedCycles: completedCycles,
            totalCycles: totalCycles,
            durationSeconds: durationSeconds
        )
        breathworkSessions.insert(session, at: 0)
        persistBreathworkSessions()
    }

    func resetFlow() {
        path = []
        hasUnlockedPlan = false
        result = nil
        plan = nil
        selectedGoal = nil
        chronotype = nil
        sleepLatency = nil
        nightAwakenings = nil
        consistency = nil
        weekendDrift = nil
        eveningState = nil
        windDownStyle = nil
        bedtime = Self.defaultBedtime
        wakeTime = Self.defaultWakeTime
        energyLevel = nil
        disruption = nil
        motivation = nil
        selectedProduct = .yearly
        hasRequestedReviewPrompt = false
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

    private func streakCount(from recentDays: [ProgressDay]) -> Int {
        var streak: Int = 0
        for day in recentDays {
            guard day.didComplete else {
                break
            }
            streak += 1
        }
        return streak
    }

    private func longestStreakCount(for days: [Date]) -> Int {
        let calendar: Calendar = .current
        guard !days.isEmpty else {
            return 0
        }

        var longest: Int = 1
        var current: Int = 1

        for index in 1..<days.count {
            let previousDay: Date = days[index - 1]
            let day: Date = days[index]
            let difference: Int = calendar.dateComponents([.day], from: previousDay, to: day).day ?? 0

            if difference == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }

        return longest
    }

    private func loadBreathworkSessions() {
        guard let data = defaults.data(forKey: Self.breathworkSessionsKey) else {
            breathworkSessions = []
            return
        }

        do {
            breathworkSessions = try JSONDecoder().decode([BreathworkSession].self, from: data)
        } catch {
            breathworkSessions = []
        }
    }

    private func persistBreathworkSessions() {
        do {
            let data = try JSONEncoder().encode(breathworkSessions)
            defaults.set(data, forKey: Self.breathworkSessionsKey)
        } catch {
            return
        }
    }

    private static let breathworkSessionsKey: String = "sleepResetBreathworkSessions"

    private static var defaultBedtime: Date {
        let calendar: Calendar = Calendar.current
        return calendar.date(bySettingHour: 0, minute: 30, second: 0, of: .now) ?? .now
    }

    private static var defaultWakeTime: Date {
        let calendar: Calendar = Calendar.current
        return calendar.date(bySettingHour: 8, minute: 0, second: 0, of: .now) ?? .now
    }
}
