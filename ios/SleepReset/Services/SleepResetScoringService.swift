import Foundation

nonisolated struct SleepResetScoringService {
    func score(
        bedtime: Date,
        wakeTime: Date,
        energyLevel: EnergyLevel,
        disruption: SleepDisruption,
        chronotype: SleepChronotype,
        sleepLatency: SleepLatency,
        nightAwakenings: NightAwakenings,
        consistency: SleepConsistency,
        weekendDrift: WeekendDrift,
        eveningState: EveningState,
        motivation: MotivationLevel
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

        let chronotypeModifier: Int
        switch chronotype {
        case .earlyBird:
            chronotypeModifier = bedtimeHour < 23 ? 4 : -4
        case .balanced:
            chronotypeModifier = 2
        case .nightOwl:
            chronotypeModifier = bedtimeHour >= 23 ? 2 : -4
        case .allOver:
            chronotypeModifier = -8
        }

        let motivationModifier: Int
        switch motivation {
        case .justCurious:
            motivationModifier = 0
        case .ready:
            motivationModifier = 2
        case .veryCommitted:
            motivationModifier = 4
        case .desperate:
            motivationModifier = -3
        }

        let rawScore: Int = 82
            - bedtimeDrift
            - durationPenalty
            - disruptionPenalty
            + energyLevel.scoreModifier
            + sleepLatency.scoreModifier
            + nightAwakenings.scoreModifier
            + consistency.scoreModifier
            + weekendDrift.scoreModifier
            + eveningState.scoreModifier
            + chronotypeModifier
            + motivationModifier
        let score: Int = min(max(rawScore, 24), 96)

        let pillars: [ScorePillar] = [
            ScorePillar(id: "timing", title: "Timing", value: min(max(100 - bedtimeDrift * 2 + consistency.scoreModifier + weekendDrift.scoreModifier, 18), 98), icon: "moon.zzz.fill"),
            ScorePillar(id: "duration", title: "Depth", value: min(max(100 - durationPenalty * 2 + sleepLatency.scoreModifier + nightAwakenings.scoreModifier, 20), 98), icon: "bed.double.fill"),
            ScorePillar(id: "recovery", title: "Recovery", value: min(max(score + energyLevel.scoreModifier / 2 + motivationModifier, 20), 98), icon: "sun.max.fill")
        ]

        let title: String
        let summary: String
        let recoveryOutlook: String

        switch score {
        case ..<45:
            title = "Your schedule needs a hard reset"
            summary = "Your sleep rhythm looks fragmented, which usually shows up as foggy mornings, heavy evenings, and a body that never fully settles."
            recoveryOutlook = "A tighter wind-down and a cleaner wake anchor can start pulling things back within the next two nights."
        case ..<65:
            title = "You are close, but still off rhythm"
            summary = "You have enough structure to recover, but timing drift, activation at night, or broken sleep are still stealing a lot of energy."
            recoveryOutlook = "A more deliberate evening routine should make tomorrow feel noticeably smoother."
        default:
            title = "Your rhythm is recoverable fast"
            summary = "The foundation is there. You mostly need sharper consistency and a calmer runway into sleep so your system can lock back in."
            recoveryOutlook = "A clean reset tonight should help you wake up steadier tomorrow and keep momentum through the week."
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
        disruption: SleepDisruption,
        windDownStyle: WindDownStyle,
        eveningState: EveningState
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

        let windDownStep: ResetPlanSection
        switch windDownStyle {
        case .breathwork:
            windDownStep = ResetPlanSection(id: "breathwork", title: "Lead with breathwork", subtitle: "Use your guided breathing session 20 minutes before bed to lower physical tension.", icon: "wind")
        case .reading:
            windDownStep = ResetPlanSection(id: "reading", title: "Switch to low-stimulation reading", subtitle: "Trade scrolling for 10 quiet minutes of reading so your mind can narrow its focus.", icon: "book.closed.fill")
        case .stretching:
            windDownStep = ResetPlanSection(id: "stretching", title: "Downshift with light movement", subtitle: "A short stretch helps tell your body the workday is over.", icon: "figure.cooldown")
        case .nothing:
            windDownStep = ResetPlanSection(id: "ritual", title: "Add a real wind-down", subtitle: "Right now you go straight from life into bed, so even a tiny ritual will make a visible difference.", icon: "sparkles")
        }

        let eveningStep: ResetPlanSection
        switch eveningState {
        case .calm:
            eveningStep = ResetPlanSection(id: "protect", title: "Protect the calm", subtitle: "Keep the last 30 minutes dim, quiet, and low-friction so you stay settled.", icon: "leaf.fill")
        case .mentallyBusy:
            eveningStep = ResetPlanSection(id: "minddump", title: "Clear the mental tabs", subtitle: "Do a quick brain dump before bed so your thoughts stop looping once the lights are off.", icon: "brain.head.profile")
        case .overstimulated:
            eveningStep = ResetPlanSection(id: "declutter", title: "Reduce stimulation fast", subtitle: "Step away from fast-moving content and bright screens earlier than you think you need to.", icon: "sparkles")
        case .stressed:
            eveningStep = ResetPlanSection(id: "downregulate", title: "Calm the nervous system", subtitle: "Aim for slower exhales, lower lighting, and less decision-making during the final hour.", icon: "waveform.path.ecg")
        }

        let sections: [ResetPlanSection] = [
            ResetPlanSection(id: "bedtime", title: "Be in bed by \(bedtimeTarget)", subtitle: "This is your fastest route back to a stable wake-up tomorrow.", icon: "bed.double.circle.fill"),
            firstStep,
            windDownStep,
            eveningStep,
            ResetPlanSection(id: "wake", title: "Protect \(wakeTarget)", subtitle: "Wake at the same time tomorrow even if tonight is imperfect.", icon: "alarm.fill")
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
