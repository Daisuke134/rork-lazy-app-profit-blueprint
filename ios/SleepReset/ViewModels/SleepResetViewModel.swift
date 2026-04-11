import Foundation
import Observation

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
    var isAnalyzing: Bool = false
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

    func purchaseSelectedPlan() {
        analyticsService.track(.checkoutStarted, properties: ["product": selectedProduct.title])
        hasUnlockedPlan = true
        analyticsService.track(.subscriptionPurchased, properties: ["product": selectedProduct.title])
        path = [.dashboard]
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
