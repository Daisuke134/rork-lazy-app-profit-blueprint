import Foundation

nonisolated struct SleepResetScoringService {
    func score(
        bedtime: Date,
        wakeTime: Date,
        energyLevel: EnergyLevel,
        disruption: SleepDisruption
    ) -> SleepResetResult {
        let calendar: Calendar = Calendar.current
        let bedtimeHour: Int = calendar.component(.hour, from: bedtime)
        let bedtimeMinute: Int = calendar.component(.minute, from: bedtime)
        let wakeHour: Int = calendar.component(.hour, from: wakeTime)
        let wakeMinute: Int = calendar.component(.minute, from: wakeTime)

        let bedtimeValue: Int = bedtimeHour * 60 + bedtimeMinute
        let wakeValue: Int = wakeHour * 60 + wakeMinute
        let alignedBedtime: Int = bedtimeValue <= wakeValue ? bedtimeValue + 1_440 : bedtimeValue
        let durationMinutes: Int = alignedBedtime - wakeValue
        let sleepHours: Double = Double(durationMinutes) / 60.0

        let bedtimeDrift: Int = abs((bedtimeHour * 60 + bedtimeMinute) - (23 * 60)) / 8
        let durationPenalty: Int = Int(abs(sleepHours - 8.0) * 10)
        let disruptionPenalty: Int

        switch disruption {
        case .jetLag:
            disruptionPenalty = 14
        case .lateNights:
            disruptionPenalty = 12
        case .shiftWork:
            disruptionPenalty = 16
        case .stress:
            disruptionPenalty = 10
        }

        let rawScore: Int = 84 - bedtimeDrift - durationPenalty - disruptionPenalty + energyLevel.scoreModifier
        let score: Int = min(max(rawScore, 24), 96)

        let pillars: [ScorePillar] = [
            ScorePillar(id: "timing", title: "Timing", value: min(max(100 - bedtimeDrift * 2, 18), 98), icon: "moon.zzz.fill"),
            ScorePillar(id: "duration", title: "Duration", value: min(max(100 - durationPenalty * 2, 20), 98), icon: "bed.double.fill"),
            ScorePillar(id: "recovery", title: "Recovery", value: min(max(score + 6, 20), 98), icon: "sun.max.fill")
        ]

        let title: String
        let summary: String
        let recoveryOutlook: String

        switch score {
        case ..<45:
            title = "Your schedule needs a hard reset"
            summary = "Your sleep window is out of sync, which usually shows up as foggy mornings and heavy afternoons."
            recoveryOutlook = "A focused two-night reset can start pulling your rhythm back quickly."
        case ..<65:
            title = "You are close, but still off rhythm"
            summary = "Your sleep is landing, but the timing mismatch is still stealing energy and making mornings sticky."
            recoveryOutlook = "A tighter bedtime target should lift tomorrow morning noticeably."
        default:
            title = "Your rhythm is recoverable fast"
            summary = "You already have enough structure to rebound, but your sleep timing still needs sharper consistency."
            recoveryOutlook = "A clean reset tonight should help you wake up steadier tomorrow."
        }

        return SleepResetResult(
            score: score,
            title: title,
            summary: summary,
            recoveryOutlook: recoveryOutlook,
            pillars: pillars
        )
    }

    func plan(
        bedtime: Date,
        wakeTime: Date,
        disruption: SleepDisruption
    ) -> ResetPlan {
        let bedtimeTarget: String = formattedTime(from: Calendar.current.date(byAdding: .minute, value: -35, to: bedtime) ?? bedtime)
        let wakeTarget: String = formattedTime(from: wakeTime)

        let firstStep: ResetPlanSection
        switch disruption {
        case .jetLag:
            firstStep = ResetPlanSection(id: "anchor", title: "Light reset", subtitle: "Get outdoor light within 20 minutes of waking to shift your clock forward.", icon: "sun.horizon.fill")
        case .lateNights:
            firstStep = ResetPlanSection(id: "cutoff", title: "Cut the drift", subtitle: "Stop bright screens 45 minutes before target bedtime so sleep pressure can land.", icon: "moon.stars.fill")
        case .shiftWork:
            firstStep = ResetPlanSection(id: "buffer", title: "Build a buffer", subtitle: "Create a 30-minute transition ritual before bed so your body can downshift.", icon: "switch.2")
        case .stress:
            firstStep = ResetPlanSection(id: "decompress", title: "Drop your activation", subtitle: "Use a 10-minute brain dump and slow breathing before bed to lower alertness.", icon: "wind")
        }

        let sections: [ResetPlanSection] = [
            ResetPlanSection(id: "bedtime", title: "Be in bed by \(bedtimeTarget)", subtitle: "This is your fastest route back to a stable wake-up tomorrow.", icon: "bed.double.circle.fill"),
            firstStep,
            ResetPlanSection(id: "wake", title: "Protect \(wakeTarget)", subtitle: "Wake at the same time tomorrow even if tonight is imperfect.", icon: "alarm.fill"),
            ResetPlanSection(id: "caffeine", title: "Keep afternoon clean", subtitle: "No caffeine after 2 PM if you want tonight to stick.", icon: "cup.and.saucer.fill")
        ]

        return ResetPlan(bedtimeTarget: bedtimeTarget, wakeTarget: wakeTarget, sections: sections)
    }

    private func formattedTime(from date: Date) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
