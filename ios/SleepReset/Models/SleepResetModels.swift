import Foundation

nonisolated enum SleepResetStep: Hashable {
    case welcome
    case goals
    case chronotype
    case sleepLatency
    case nightAwakenings
    case consistency
    case weekendDrift
    case eveningState
    case windDownStyle
    case bedtime
    case wakeTime
    case energyLevel
    case disruption
    case motivation
    case analyzing
    case result
    case reviewPrompt
    case paywall
    case dashboard
}

nonisolated enum SleepGoal: String, CaseIterable, Identifiable, Sendable {
    case improveSleep = "Improve sleep"
    case fallAsleepFaster = "Fall asleep faster"
    case calmAnxiousNights = "Calm anxious nights"
    case wakeWithEnergy = "Wake with energy"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .improveSleep:
            "moon.zzz.fill"
        case .fallAsleepFaster:
            "sparkles"
        case .calmAnxiousNights:
            "wind"
        case .wakeWithEnergy:
            "sun.max.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .improveSleep:
            "Build a steadier rhythm"
        case .fallAsleepFaster:
            "Spend less time lying awake"
        case .calmAnxiousNights:
            "Settle your body before bed"
        case .wakeWithEnergy:
            "Feel clearer in the morning"
        }
    }
}

nonisolated enum SleepChronotype: String, CaseIterable, Identifiable, Sendable {
    case earlyBird = "Early bird"
    case balanced = "Balanced"
    case nightOwl = "Night owl"
    case allOver = "All over the place"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .earlyBird:
            "sunrise.fill"
        case .balanced:
            "circle.lefthalf.filled"
        case .nightOwl:
            "moon.stars.fill"
        case .allOver:
            "shuffle"
        }
    }

    var subtitle: String {
        switch self {
        case .earlyBird:
            "You naturally get sleepy earlier"
        case .balanced:
            "You can hold a decent routine"
        case .nightOwl:
            "You come alive later at night"
        case .allOver:
            "Your schedule changes a lot"
        }
    }
}

nonisolated enum SleepLatency: String, CaseIterable, Identifiable, Sendable {
    case under15 = "Under 15 min"
    case under30 = "15–30 min"
    case under60 = "30–60 min"
    case over60 = "Over 1 hour"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .under15:
            "bolt.fill"
        case .under30:
            "clock.fill"
        case .under60:
            "hourglass"
        case .over60:
            "hourglass.bottomhalf.filled"
        }
    }

    var subtitle: String {
        switch self {
        case .under15:
            "You usually fall asleep quickly"
        case .under30:
            "You need a little time to settle"
        case .under60:
            "Falling asleep is often a struggle"
        case .over60:
            "You spend a long time lying awake"
        }
    }

    var scoreModifier: Int {
        switch self {
        case .under15: 8
        case .under30: 2
        case .under60: -8
        case .over60: -16
        }
    }
}

nonisolated enum NightAwakenings: String, CaseIterable, Identifiable, Sendable {
    case rarely = "Rarely"
    case once = "About once"
    case twoOrThree = "2–3 times"
    case often = "A lot"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .rarely:
            "checkmark.circle.fill"
        case .once:
            "1.circle.fill"
        case .twoOrThree:
            "3.circle.fill"
        case .often:
            "exclamationmark.circle.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .rarely:
            "Your sleep is mostly uninterrupted"
        case .once:
            "You have an occasional wake-up"
        case .twoOrThree:
            "Broken sleep is becoming normal"
        case .often:
            "Your nights feel fragmented"
        }
    }

    var scoreModifier: Int {
        switch self {
        case .rarely: 6
        case .once: 0
        case .twoOrThree: -8
        case .often: -14
        }
    }
}

nonisolated enum SleepConsistency: String, CaseIterable, Identifiable, Sendable {
    case lockedIn = "Locked in"
    case mostlySteady = "Mostly steady"
    case inconsistent = "Inconsistent"
    case chaotic = "Chaotic"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .lockedIn:
            "checkmark.seal.fill"
        case .mostlySteady:
            "calendar"
        case .inconsistent:
            "calendar.badge.exclamationmark"
        case .chaotic:
            "waveform.path.badge.minus"
        }
    }

    var subtitle: String {
        switch self {
        case .lockedIn:
            "Bedtime and wake time rarely move"
        case .mostlySteady:
            "You drift a little but not much"
        case .inconsistent:
            "Your schedule moves around often"
        case .chaotic:
            "Every day feels different"
        }
    }

    var scoreModifier: Int {
        switch self {
        case .lockedIn: 10
        case .mostlySteady: 3
        case .inconsistent: -8
        case .chaotic: -16
        }
    }
}

nonisolated enum WeekendDrift: String, CaseIterable, Identifiable, Sendable {
    case underHour = "Less than 1 hour"
    case oneToTwo = "1–2 hours"
    case twoToThree = "2–3 hours"
    case overThree = "3+ hours"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .underHour:
            "arrow.left.and.right.circle.fill"
        case .oneToTwo:
            "arrow.left.and.right.circle"
        case .twoToThree:
            "arrow.trianglehead.2.clockwise.rotate.90"
        case .overThree:
            "arrow.clockwise.circle.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .underHour:
            "Your weekends look close to weekdays"
        case .oneToTwo:
            "You sleep in a little"
        case .twoToThree:
            "Your rhythm shifts noticeably"
        case .overThree:
            "Weekends fully throw your timing off"
        }
    }

    var scoreModifier: Int {
        switch self {
        case .underHour: 7
        case .oneToTwo: 0
        case .twoToThree: -8
        case .overThree: -14
        }
    }
}

nonisolated enum EveningState: String, CaseIterable, Identifiable, Sendable {
    case calm = "Calm"
    case mentallyBusy = "Mentally busy"
    case overstimulated = "Overstimulated"
    case stressed = "Stressed"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .calm:
            "leaf.fill"
        case .mentallyBusy:
            "brain.head.profile"
        case .overstimulated:
            "sparkles"
        case .stressed:
            "waveform.path.ecg"
        }
    }

    var subtitle: String {
        switch self {
        case .calm:
            "Your body can downshift fairly easily"
        case .mentallyBusy:
            "Your mind keeps replaying the day"
        case .overstimulated:
            "Screens, work, or social energy keep you wired"
        case .stressed:
            "Your nervous system feels revved up"
        }
    }

    var scoreModifier: Int {
        switch self {
        case .calm: 8
        case .mentallyBusy: -2
        case .overstimulated: -8
        case .stressed: -12
        }
    }
}

nonisolated enum WindDownStyle: String, CaseIterable, Identifiable, Sendable {
    case breathwork = "Breathwork"
    case reading = "Reading"
    case stretching = "Stretching"
    case nothing = "Honestly, nothing"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .breathwork:
            "wind"
        case .reading:
            "book.closed.fill"
        case .stretching:
            "figure.cooldown"
        case .nothing:
            "bed.double.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .breathwork:
            "You like a guided body-based reset"
        case .reading:
            "A quieter transition helps you land"
        case .stretching:
            "Movement helps you release tension"
        case .nothing:
            "You usually go straight from life into bed"
        }
    }
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

    var icon: String {
        switch self {
        case .jetLag:
            "airplane"
        case .lateNights:
            "moon.stars.fill"
        case .shiftWork:
            "clock.arrow.trianglehead.counterclockwise.rotate.90"
        case .stress:
            "waveform.path.ecg"
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

    var icon: String {
        switch self {
        case .depleted:
            "battery.0percent"
        case .low:
            "battery.25percent"
        case .okay:
            "battery.75percent"
        case .strong:
            "battery.100percent"
        }
    }

    var subtitle: String {
        switch self {
        case .depleted:
            "You are pushing through fumes"
        case .low:
            "Your mornings feel heavy"
        case .okay:
            "You function, but not at your best"
        case .strong:
            "You still have some lift during the day"
        }
    }
}

nonisolated enum MotivationLevel: String, CaseIterable, Identifiable, Sendable {
    case justCurious = "Just curious"
    case ready = "Ready to improve"
    case veryCommitted = "Very committed"
    case desperate = "I need this now"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .justCurious:
            "eyes"
        case .ready:
            "figure.walk"
        case .veryCommitted:
            "target"
        case .desperate:
            "flame.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .justCurious:
            "You are exploring what might help"
        case .ready:
            "You want a realistic plan"
        case .veryCommitted:
            "You are ready to follow through"
        case .desperate:
            "You need relief fast"
        }
    }
}

nonisolated enum SubscriptionProduct: String, CaseIterable, Identifiable, Sendable {
    case weekly = "Weekly"
    case yearly = "Yearly"

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
            "3 days free, then weekly billing"
        case .yearly:
            "3 days free, then yearly billing"
        }
    }

    var trialBadge: String {
        "3 days free"
    }

    var displayPrice: String {
        switch self {
        case .weekly:
            "$12.99/week"
        case .yearly:
            "$49.99/year"
        }
    }

    var revenueCatProductID: String {
        switch self {
        case .weekly:
            "sleepreset_weekly"
        case .yearly:
            "sleepreset_yearly"
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

nonisolated struct BreathworkSession: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    let completedAt: Date
    let completedCycles: Int
    let totalCycles: Int
    let durationSeconds: Int
}

nonisolated struct ProgressDay: Identifiable, Hashable, Sendable {
    let id: Date
    let date: Date
    let label: String
    let didComplete: Bool
    let sessionCount: Int
}

nonisolated struct ProgressPoint: Identifiable, Hashable, Sendable {
    let id: UUID = UUID()
    let day: String
    let score: Int
}

nonisolated struct BreathworkInsight: Hashable, Sendable {
    let currentStreak: Int
    let longestStreak: Int
    let completedDaysThisWeek: Int
    let totalSessions: Int
    let totalMinutes: Int
    let completedToday: Bool
    let recentDays: [ProgressDay]
}

nonisolated enum OnboardingQuestion: Hashable, Sendable {
    case goal
    case chronotype
    case sleepLatency
    case nightAwakenings
    case consistency
    case weekendDrift
    case eveningState
    case windDownStyle
    case energyLevel
    case disruption
    case motivation
}
