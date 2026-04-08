import Foundation

nonisolated enum SleepResetStep: Hashable {
    case welcome
    case goals
    case input
    case analyzing
    case result
    case paywall
    case dashboard
}

nonisolated enum SleepDisruption: String, CaseIterable, Identifiable, Sendable {
    case jetLag = "Jet lag"
    case lateNights = "Late nights"
    case shiftWork = "Shift work"
    case stress = "Stress"

    var id: String { rawValue }

    var headline: String {
        switch self {
        case .jetLag:
            "Your body clock is dragging behind"
        case .lateNights:
            "Your bedtime rhythm is drifting later"
        case .shiftWork:
            "Your schedule is fighting your sleep window"
        case .stress:
            "Your system looks wired instead of settled"
        }
    }
}

nonisolated enum EnergyLevel: String, CaseIterable, Identifiable, Sendable {
    case depleted = "Depleted"
    case low = "Low"
    case okay = "Okay"
    case strong = "Strong"

    var id: String { rawValue }

    var scoreModifier: Int {
        switch self {
        case .depleted: -18
        case .low: -10
        case .okay: 0
        case .strong: 8
        }
    }
}

nonisolated enum SubscriptionProduct: String, CaseIterable, Identifiable, Sendable {
    case weekly = "$9.99/week"
    case yearly = "$39.99/year"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weekly:
            "Weekly Reset"
        case .yearly:
            "Yearly Reset"
        }
    }

    var subtitle: String {
        switch self {
        case .weekly:
            "Best for immediate recovery"
        case .yearly:
            "Best value for staying consistent"
        }
    }
}

nonisolated struct ScorePillar: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let value: Int
    let icon: String
}

nonisolated struct SleepResetResult: Hashable, Sendable {
    let score: Int
    let title: String
    let summary: String
    let recoveryOutlook: String
    let pillars: [ScorePillar]
}

nonisolated struct ResetPlanSection: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
}

nonisolated struct ResetPlan: Hashable, Sendable {
    let bedtimeTarget: String
    let wakeTarget: String
    let sections: [ResetPlanSection]
}

nonisolated struct ProgressPoint: Identifiable, Hashable, Sendable {
    let id: UUID = UUID()
    let day: String
    let score: Int
}
