import SwiftUI
import StoreKit
import Foundation

struct SleepResetFlowView: View {
    @State private var viewModel: SleepResetViewModel = SleepResetViewModel()

    var body: some View {
        Group {
            if viewModel.hasUnlockedPlan {
                SleepDashboardView(viewModel: viewModel)
            } else {
                NavigationStack(path: $viewModel.path) {
                    SleepWelcomeView(viewModel: viewModel)
                        .navigationDestination(for: SleepResetStep.self) { step in
                            switch step {
                            case .welcome:
                                SleepWelcomeView(viewModel: viewModel)
                            case .goals:
                                SleepGoalsView(viewModel: viewModel)
                            case .chronotype:
                                SleepChronotypeView(viewModel: viewModel)
                            case .sleepLatency:
                                SleepLatencyView(viewModel: viewModel)
                            case .nightAwakenings:
                                SleepNightAwakeningsView(viewModel: viewModel)
                            case .consistency:
                                SleepConsistencyView(viewModel: viewModel)
                            case .weekendDrift:
                                SleepWeekendDriftView(viewModel: viewModel)
                            case .eveningState:
                                SleepEveningStateView(viewModel: viewModel)
                            case .windDownStyle:
                                SleepWindDownStyleView(viewModel: viewModel)
                            case .bedtime:
                                SleepBedtimeView(viewModel: viewModel)
                            case .wakeTime:
                                SleepWakeTimeView(viewModel: viewModel)
                            case .energyLevel:
                                SleepEnergyLevelView(viewModel: viewModel)
                            case .disruption:
                                SleepDisruptionView(viewModel: viewModel)
                            case .motivation:
                                SleepMotivationView(viewModel: viewModel)
                            case .analyzing:
                                SleepAnalyzingView(viewModel: viewModel)
                            case .result:
                                SleepResultView(viewModel: viewModel)
                            case .reviewPrompt:
                                SleepReviewPromptView(viewModel: viewModel)
                            case .paywall:
                                SleepPaywallView(viewModel: viewModel)
                            case .dashboard:
                                SleepDashboardView(viewModel: viewModel)
                            }
                        }
                }
            }
        }
        .tint(.white)
    }
}

private struct SleepWelcomeView: View {
    let viewModel: SleepResetViewModel

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .midnight)

            VStack(alignment: .leading, spacing: 0) {
                SleepTopProgressBar(progress: 0.12)
                    .padding(.top, 8)

                Spacer()

                VStack(alignment: .leading, spacing: 18) {
                    Text("Sleep better in a calmer rhythm")
                        .font(.system(.largeTitle, design: .default, weight: .regular))
                        .foregroundStyle(.white)

                    Text("Answer a few quick questions and get a clear reset path for tonight, tomorrow morning, and the week ahead.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                VStack(spacing: 14) {
                    SleepGlassFeatureCard(
                        icon: "moon.haze.fill",
                        title: "Fast reset score",
                        subtitle: "See how off your sleep rhythm feels right now"
                    )

                    SleepGlassFeatureCard(
                        icon: "sparkles",
                        title: "One calm plan",
                        subtitle: "Get a bedtime target, wake target, and grounded next steps"
                    )
                }

                Spacer()

                Button("Get Started") {
                    viewModel.start()
                }
                .buttonStyle(SleepPrimaryButtonStyle())
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SleepGoalsView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        SleepQuestionScreen(
            viewModel: viewModel,
            variant: .harbor,
            title: "What is your primary goal?",
            subtitle: "We’ll shape your reset around the outcome that matters most to you.",
            ctaTitle: "Next",
            isCTAEnabled: viewModel.selectedGoal != nil
        ) {
            VStack(spacing: 12) {
                ForEach(SleepGoal.allCases) { goal in
                    SleepChoiceRow(
                        title: goal.rawValue,
                        subtitle: goal.subtitle,
                        icon: goal.icon,
                        isSelected: viewModel.selectedGoal == goal
                    ) {
                        viewModel.selectedGoal = goal
                    }
                }
            }
        } action: {
            viewModel.continueFromGoals()
        }
    }
}

private struct SleepChronotypeView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        SleepQuestionScreen(
            viewModel: viewModel,
            variant: .harbor,
            title: "Which one sounds most like you?",
            subtitle: "This helps us match your plan to your natural rhythm instead of fighting it.",
            ctaTitle: "Next",
            isCTAEnabled: viewModel.chronotype != nil
        ) {
            VStack(spacing: 12) {
                ForEach(SleepChronotype.allCases) { option in
                    SleepChoiceRow(
                        title: option.rawValue,
                        subtitle: option.subtitle,
                        icon: option.icon,
                        isSelected: viewModel.chronotype == option
                    ) {
                        viewModel.chronotype = option
                    }
                }
            }
        } action: {
            viewModel.continueFromChronotype()
        }
    }
}

private struct SleepLatencyView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        SleepQuestionScreen(
            viewModel: viewModel,
            variant: .harbor,
            title: "How long does it usually take you to fall asleep?",
            subtitle: "Pick the answer that feels true most nights.",
            ctaTitle: "Next",
            isCTAEnabled: viewModel.sleepLatency != nil
        ) {
            VStack(spacing: 12) {
                ForEach(SleepLatency.allCases) { option in
                    SleepChoiceRow(
                        title: option.rawValue,
                        subtitle: option.subtitle,
                        icon: option.icon,
                        isSelected: viewModel.sleepLatency == option
                    ) {
                        viewModel.sleepLatency = option
                    }
                }
            }
        } action: {
            viewModel.continueFromSleepLatency()
        }
    }
}

private struct SleepNightAwakeningsView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        SleepQuestionScreen(
            viewModel: viewModel,
            variant: .harbor,
            title: "How often do you wake up during the night?",
            subtitle: "A more broken night usually needs a calmer, steadier plan.",
            ctaTitle: "Next",
            isCTAEnabled: viewModel.nightAwakenings != nil
        ) {
            VStack(spacing: 12) {
                ForEach(NightAwakenings.allCases) { option in
                    SleepChoiceRow(
                        title: option.rawValue,
                        subtitle: option.subtitle,
                        icon: option.icon,
                        isSelected: viewModel.nightAwakenings == option
                    ) {
                        viewModel.nightAwakenings = option
                    }
                }
            }
        } action: {
            viewModel.continueFromNightAwakenings()
        }
    }
}

private struct SleepConsistencyView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        SleepQuestionScreen(
            viewModel: viewModel,
            variant: .aurora,
            title: "How consistent is your sleep schedule?",
            subtitle: "Consistency is one of the fastest ways to recover your rhythm.",
            ctaTitle: "Next",
            isCTAEnabled: viewModel.consistency != nil
        ) {
            VStack(spacing: 12) {
                ForEach(SleepConsistency.allCases) { option in
                    SleepChoiceRow(
                        title: option.rawValue,
                        subtitle: option.subtitle,
                        icon: option.icon,
                        isSelected: viewModel.consistency == option
                    ) {
                        viewModel.consistency = option
                    }
                }
            }
        } action: {
            viewModel.continueFromConsistency()
        }
    }
}

private struct SleepWeekendDriftView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        SleepQuestionScreen(
            viewModel: viewModel,
            variant: .aurora,
            title: "How much later do you go to bed or wake up on weekends?",
            subtitle: "Weekend drift is one of the biggest reasons a reset never fully sticks.",
            ctaTitle: "Next",
            isCTAEnabled: viewModel.weekendDrift != nil
        ) {
            VStack(spacing: 12) {
                ForEach(WeekendDrift.allCases) { option in
                    SleepChoiceRow(
                        title: option.rawValue,
                        subtitle: option.subtitle,
                        icon: option.icon,
                        isSelected: viewModel.weekendDrift == option
                    ) {
                        viewModel.weekendDrift = option
                    }
                }
            }
        } action: {
            viewModel.continueFromWeekendDrift()
        }
    }
}

private struct SleepEveningStateView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        SleepQuestionScreen(
            viewModel: viewModel,
            variant: .aurora,
            title: "How do you usually feel in the evening?",
            subtitle: "We use this to decide whether your plan should calm your mind, your body, or both.",
            ctaTitle: "Next",
            isCTAEnabled: viewModel.eveningState != nil
        ) {
            VStack(spacing: 12) {
                ForEach(EveningState.allCases) { option in
                    SleepChoiceRow(
                        title: option.rawValue,
                        subtitle: option.subtitle,
                        icon: option.icon,
                        isSelected: viewModel.eveningState == option
                    ) {
                        viewModel.eveningState = option
                    }
                }
            }
        } action: {
            viewModel.continueFromEveningState()
        }
    }
}

private struct SleepWindDownStyleView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        SleepQuestionScreen(
            viewModel: viewModel,
            variant: .dawn,
            title: "What kind of wind-down feels most realistic for you?",
            subtitle: "We’ll lead with the transition you’re most likely to actually do tonight.",
            ctaTitle: "Next",
            isCTAEnabled: viewModel.windDownStyle != nil
        ) {
            VStack(spacing: 12) {
                ForEach(WindDownStyle.allCases) { option in
                    SleepChoiceRow(
                        title: option.rawValue,
                        subtitle: option.subtitle,
                        icon: option.icon,
                        isSelected: viewModel.windDownStyle == option
                    ) {
                        viewModel.windDownStyle = option
                    }
                }
            }
        } action: {
            viewModel.continueFromWindDownStyle()
        }
    }
}

private struct SleepBedtimeView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .harbor)

            SleepFixedStepContainer(maxWidth: 620) {
                SleepTopProgressBar(progress: viewModel.onboardingProgress)
                    .padding(.top, 8)

                Spacer(minLength: 16)

                VStack(alignment: .leading, spacing: 10) {
                    Text("What's your target bedtime?")
                        .font(.system(.largeTitle, design: .default, weight: .regular))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)

                    Text("Pick the time you want your body to start settling into consistently.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                }

                Spacer(minLength: 16)

                SleepWheelCard(title: "Target Bedtime") {
                    DatePicker("Bedtime", selection: $viewModel.bedtime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                }

                Spacer(minLength: 16)

                Button("Next") {
                    viewModel.continueFromBedtime()
                }
                .buttonStyle(SleepPrimaryButtonStyle())
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SleepWakeTimeView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .harbor)

            SleepFixedStepContainer(maxWidth: 620) {
                SleepTopProgressBar(progress: viewModel.onboardingProgress)
                    .padding(.top, 8)

                Spacer(minLength: 16)

                VStack(alignment: .leading, spacing: 10) {
                    Text("What time do you usually wake up?")
                        .font(.system(.largeTitle, design: .default, weight: .regular))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)

                    Text("This helps shape a plan you can actually stick with tomorrow.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                }

                Spacer(minLength: 16)

                SleepWheelCard(title: "Wake Time") {
                    DatePicker("Wake time", selection: $viewModel.wakeTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                }

                Spacer(minLength: 16)

                Button("Next") {
                    viewModel.continueFromWakeTime()
                }
                .buttonStyle(SleepPrimaryButtonStyle())
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SleepEnergyLevelView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        SleepQuestionScreen(
            viewModel: viewModel,
            variant: .dawn,
            title: "How is your daytime energy right now?",
            subtitle: "This helps estimate how hard your current rhythm is pulling on recovery.",
            ctaTitle: "Next",
            isCTAEnabled: viewModel.energyLevel != nil
        ) {
            VStack(spacing: 12) {
                ForEach(EnergyLevel.allCases) { option in
                    SleepChoiceRow(
                        title: option.rawValue,
                        subtitle: option.subtitle,
                        icon: option.icon,
                        isSelected: viewModel.energyLevel == option
                    ) {
                        viewModel.energyLevel = option
                    }
                }
            }
        } action: {
            viewModel.continueFromEnergyLevel()
        }
    }
}

private struct SleepDisruptionView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .aurora)

            SleepFixedStepContainer(maxWidth: 620) {
                SleepTopProgressBar(progress: viewModel.onboardingProgress)
                    .padding(.top, 8)

                Spacer(minLength: 12)

                VStack(alignment: .leading, spacing: 10) {
                    Text("What's disrupting your sleep most?")
                        .font(.system(.largeTitle, design: .default, weight: .regular))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)

                    Text("Pick the biggest reason your rhythm feels off right now.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.68))
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                }

                Spacer(minLength: 12)

                VStack(spacing: 10) {
                    ForEach(SleepDisruption.allCases) { disruption in
                        SleepDisruptionRow(disruption: disruption, isSelected: viewModel.disruption == disruption) {
                            viewModel.disruption = disruption
                        }
                    }
                }

                Spacer(minLength: 12)

                Button("Next") {
                    viewModel.continueFromDisruption()
                }
                .buttonStyle(SleepPrimaryButtonStyle())
                .disabled(viewModel.disruption == nil)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SleepMotivationView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        SleepQuestionScreen(
            viewModel: viewModel,
            variant: .dawn,
            title: "How committed are you to resetting this right now?",
            subtitle: "The more urgent this feels, the more direct we can make your plan.",
            ctaTitle: viewModel.isAnalyzing ? "Customizing..." : "See My Score",
            isCTAEnabled: viewModel.motivation != nil
        ) {
            VStack(spacing: 12) {
                ForEach(MotivationLevel.allCases) { option in
                    SleepChoiceRow(
                        title: option.rawValue,
                        subtitle: option.subtitle,
                        icon: option.icon,
                        isSelected: viewModel.motivation == option
                    ) {
                        viewModel.motivation = option
                    }
                }
            }
        } action: {
            viewModel.continueFromMotivation()
        }
    }
}

private struct SleepAnalyzingView: View {
    let viewModel: SleepResetViewModel
    @State private var pulseOpacity: Double = 0.42
    @State private var displayedProgress: Double = 0
    @State private var messageIndex: Int = 0

    private let messages: [String] = [
        "Reading your sleep rhythm",
        "Building tonight's breathwork focus",
        "Shaping a calmer bedtime target",
        "Finalizing your reset plan"
    ]

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .aurora)

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 18) {
                    Text("Customizing your reset")
                        .font(.system(.title, design: .default, weight: .regular))
                        .foregroundStyle(.white.opacity(pulseOpacity))

                    Text(viewModel.personalizationSummary)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)

                    VStack(alignment: .leading, spacing: 12) {
                        ProgressView(value: displayedProgress)
                            .tint(.white)

                        HStack {
                            Text(messages[messageIndex])
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white)
                            Spacer()
                            Text(displayedProgress, format: .percent.precision(.fractionLength(0)))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(18)
                    .background(.white.opacity(0.08), in: .rect(cornerRadius: 24))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                    }
                    .padding(.horizontal, 28)
                }

                Spacer()
            }
        }
        .task {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseOpacity = 0.9
            }
        }
        .task {
            for step in 1...28 {
                guard !Task.isCancelled else { return }
                do {
                    try await Task.sleep(for: .milliseconds(100))
                } catch {
                    return
                }

                let progress: Double = min(Double(step) / 28.0, 1)
                let nextMessageIndex: Int = min(max(Int(progress * Double(messages.count)) - 1, 0), messages.count - 1)
                withAnimation(.smooth(duration: 0.18)) {
                    displayedProgress = progress
                    messageIndex = nextMessageIndex
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SleepResultView: View {
    let viewModel: SleepResetViewModel

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .slate)

            VStack(alignment: .leading, spacing: 18) {
                SleepTopProgressBar(progress: 0.92)
                    .padding(.top, 8)

                Spacer(minLength: 12)

                if let result = viewModel.result {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your sleep reset score")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.58))

                        Text("\(result.score)")
                            .font(.system(size: 96, weight: .bold, design: .default))
                            .foregroundStyle(.white)
                            .contentTransition(.numericText())

                        Text(result.title)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)

                        Text(result.summary)
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(24)
                    .background(.white.opacity(0.08), in: .rect(cornerRadius: 34))
                    .overlay {
                        RoundedRectangle(cornerRadius: 34)
                            .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                    }

                    HStack(spacing: 12) {
                        ForEach(result.pillars) { pillar in
                            VStack(alignment: .leading, spacing: 10) {
                                Image(systemName: pillar.icon)
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Text("\(pillar.value)")
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(.white)
                                Text(pillar.title)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.58))
                            }
                            .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
                            .padding(16)
                            .background(.white.opacity(0.08), in: .rect(cornerRadius: 24))
                            .overlay {
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Main driver")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.58))
                        Text(viewModel.disruption?.headline ?? "Your reset plan is calibrated around the biggest source of sleep friction right now.")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.white)
                        Text(result.recoveryOutlook)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.68))
                    }
                    .padding(18)
                    .background(.white.opacity(0.08), in: .rect(cornerRadius: 24))
                    .overlay {
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                    }

                    Spacer(minLength: 0)

                    Button("Unlock My Reset Plan") {
                        viewModel.showReviewPrompt()
                    }
                    .buttonStyle(SleepPrimaryButtonStyle())
                }
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

private struct SleepReviewPromptView: View {
    let viewModel: SleepResetViewModel
    @Environment(\.requestReview) private var requestReview
    @AppStorage("hasRequestedSleepResetReview") private var hasRequestedSleepResetReview: Bool = false

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .dawn)

            VStack(alignment: .leading, spacing: 18) {
                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Give us a rating")
                        .font(.system(.largeTitle, design: .default, weight: .bold))
                        .foregroundStyle(.white)

                    Text("How are you enjoying Sleep Reset so far? A quick rating helps us keep improving your nightly reset experience.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 14) {
                    SleepTimelineRow(icon: "star.bubble.fill", title: "Quick favor", subtitle: "The App Store rating prompt should appear automatically on this screen.")
                    SleepTimelineRow(icon: "checkmark.seal.fill", title: "Your plan is ready", subtitle: "After rating, continue to unlock the reset plan prepared from your answers.")
                }
                .padding(20)
                .background(.white.opacity(0.08), in: .rect(cornerRadius: 28))
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                }

                Spacer()

                Button("Continue") {
                    viewModel.continueFromReviewPrompt()
                }
                .buttonStyle(SleepPrimaryButtonStyle())
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            guard !hasRequestedSleepResetReview else {
                return
            }

            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                return
            }

            requestReview()
            hasRequestedSleepResetReview = true
        }
    }
}

private struct SleepPaywallView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .dawn)

            ViewThatFits(in: .vertical) {
                paywallLayout(spacing: 14, titleFont: .system(.largeTitle, design: .default, weight: .bold), subtitleFont: .body, featurePadding: 16)
                paywallLayout(spacing: 10, titleFont: .system(.title, design: .default, weight: .bold), subtitleFont: .subheadline, featurePadding: 14)
            }
            .frame(maxWidth: 620, maxHeight: .infinity)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .task {
            if viewModel.currentOffering == nil {
                await viewModel.loadOffering()
            }
        }
        .alert("Subscription Error", isPresented: Binding(
            get: { viewModel.paywallErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.clearPaywallError()
                }
            }
        )) {
            Button("OK") {
                viewModel.clearPaywallError()
            }
        } message: {
            Text(viewModel.paywallErrorMessage ?? "")
        }
    }

    private func paywallLayout(spacing: CGFloat, titleFont: Font, subtitleFont: Font, featurePadding: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Unlock your reset plan")
                    .font(titleFont)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text("One subscription unlocks tonight’s bedtime target, guided breathwork, and tomorrow’s recovery steps.")
                    .font(subtitleFont)
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(3)
                    .minimumScaleFactor(0.82)
            }

            VStack(alignment: .leading, spacing: 10) {
                SleepTimelineRow(icon: "bed.double.fill", title: "Tonight", subtitle: "Exact bedtime target and wind-down timing")
                SleepTimelineRow(icon: "wind", title: "Breathwork", subtitle: "A guided session to settle your body before bed")
                SleepTimelineRow(icon: "sun.max.fill", title: "Tomorrow", subtitle: "Wake guidance that keeps the reset going")
            }
            .padding(featurePadding)
            .background(.white.opacity(0.08), in: .rect(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
            }

            VStack(spacing: 10) {
                ForEach(SubscriptionProduct.allCases) { product in
                    SubscriptionOptionCard(
                        product: product,
                        isSelected: viewModel.selectedProduct == product
                    ) {
                        viewModel.selectedProduct = product
                    }
                }
            }

            Spacer(minLength: 8)

            Button {
                Task {
                    await viewModel.purchaseSelectedPlan()
                }
            } label: {
                HStack(spacing: 10) {
                    if viewModel.isPurchasing {
                        ProgressView()
                            .tint(.black.opacity(0.72))
                    }

                    Text(viewModel.isPurchasing ? "Processing..." : purchaseButtonTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .buttonStyle(SleepAccentButtonStyle())
            .disabled(viewModel.isPurchasing || viewModel.isLoadingProducts)

            HStack(spacing: 10) {
                Link("Privacy Policy", destination: AppLegal.privacyPolicyURL)

                Text("•")
                    .foregroundStyle(.white.opacity(0.36))

                Link("Terms of Use", destination: AppLegal.termsOfUseURL)

                Text("•")
                    .foregroundStyle(.white.opacity(0.36))

                Button("Restore Purchases") {
                    Task {
                        await viewModel.restorePurchases()
                    }
                }
                .disabled(viewModel.isPurchasing)
            }
            .buttonStyle(.plain)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white.opacity(0.72))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .frame(maxWidth: .infinity)
        }
    }

    private var purchaseButtonTitle: String {
        switch viewModel.selectedProduct {
        case .weekly:
            "Continue with $12.99/week"
        case .yearly:
            "Continue with $49.99/year"
        }
    }
}

private struct SubscriptionOptionCard: View {
    let product: SubscriptionProduct
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(product.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)

                        if product == .yearly {
                            Text("BEST")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.black.opacity(0.72))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(.white, in: .capsule)
                        }
                    }

                    Text(product.subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.64))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Text(product.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? .white.opacity(0.16) : .white.opacity(0.08), in: .rect(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(.white.opacity(isSelected ? 0.24 : 0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SleepDashboardView: View {
    let viewModel: SleepResetViewModel

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                SleepHomeView(viewModel: viewModel)
            }

            Tab("Plan", systemImage: "moon.fill") {
                SleepPlanView(viewModel: viewModel)
            }

            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis") {
                SleepProgressView(viewModel: viewModel)
            }

            Tab("Settings", systemImage: "gearshape.fill") {
                SleepSettingsView(viewModel: viewModel)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

private struct SleepHomeView: View {
    let viewModel: SleepResetViewModel
    @State private var isShowingBreathwork: Bool = false

    var body: some View {
        let insight = viewModel.breathworkInsight

        NavigationStack {
            ZStack {
                SleepBackdropView(variant: .slate)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Good evening")
                                .font(.system(.largeTitle, design: .default, weight: .bold))
                                .foregroundStyle(.white)

                            Text(insight.completedToday ? "You already checked in tonight. Keep the streak alive tomorrow." : "One guided breathwork session to help you settle tonight.")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.58))
                        }

                        VStack(alignment: .leading, spacing: 18) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Tonight’s reset")
                                        .font(.headline)
                                        .foregroundStyle(.white.opacity(0.58))

                                    Text("6 calm cycles")
                                        .font(.system(.title, design: .default, weight: .bold))
                                        .foregroundStyle(.white)

                                    Text("Inhale for 4, hold for 4, exhale for 6. The whole session takes about two minutes.")
                                        .font(.body)
                                        .foregroundStyle(.white.opacity(0.72))
                                        .fixedSize(horizontal: false, vertical: true)
                                }

                                Spacer(minLength: 12)

                                Image(systemName: "wind")
                                    .font(.system(size: 34, weight: .medium))
                                    .foregroundStyle(.white)
                                    .frame(width: 62, height: 62)
                                    .background(.white.opacity(0.10), in: .circle)
                            }

                            VStack(spacing: 10) {
                                SessionMetricRow(title: "Best for", value: "Winding down before bed")
                                SessionMetricRow(title: "Breathing pattern", value: "4 · 4 · 6")
                                SessionMetricRow(title: "Current streak", value: "\(insight.currentStreak) day\(insight.currentStreak == 1 ? "" : "s")")
                            }

                            Button(insight.completedToday ? "Do Another Session" : "Start Breathwork") {
                                isShowingBreathwork = true
                            }
                            .buttonStyle(SleepPrimaryButtonStyle())
                        }
                        .padding(22)
                        .background(.white.opacity(0.08), in: .rect(cornerRadius: 30))
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
                                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                        }

                        HStack(spacing: 12) {
                            HomeStatCard(title: "Today", value: insight.completedToday ? "Done" : "Open", subtitle: insight.completedToday ? "Breathwork logged" : "No session yet")
                            HomeStatCard(title: "Streak", value: "\(insight.currentStreak)", subtitle: "days in a row")
                            HomeStatCard(title: "This week", value: "\(insight.completedDaysThisWeek)/7", subtitle: "days completed")
                        }

                        if let plan = viewModel.plan {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("From your plan")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.58))

                                Text("Be in bed by \(plan.bedtimeTarget)")
                                    .font(.title2.weight(.semibold))
                                    .foregroundStyle(.white)

                                Text("Wake at \(plan.wakeTarget) tomorrow to keep the rhythm moving in the right direction.")
                                    .font(.body)
                                    .foregroundStyle(.white.opacity(0.70))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(20)
                            .background(.white.opacity(0.06), in: .rect(cornerRadius: 26))
                            .overlay {
                                RoundedRectangle(cornerRadius: 26)
                                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(isPresented: $isShowingBreathwork) {
            BreathworkSessionView(isPresented: $isShowingBreathwork, viewModel: viewModel)
        }
    }
}

private struct SleepPlanView: View {
    let viewModel: SleepResetViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                SleepBackdropView(variant: .slate)

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if let plan = viewModel.plan {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tonight's target")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.58))
                                Text(plan.bedtimeTarget)
                                    .font(.system(.largeTitle, design: .default, weight: .bold))
                                    .foregroundStyle(.white)
                                Text("Wake at \(plan.wakeTarget) tomorrow.")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.82))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(24)
                            .background(.white.opacity(0.08), in: .rect(cornerRadius: 32))
                            .overlay {
                                RoundedRectangle(cornerRadius: 32)
                                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                            }

                            ForEach(plan.sections) { section in
                                HStack(spacing: 16) {
                                    Image(systemName: section.icon)
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                        .frame(width: 52, height: 52)
                                        .background(.white.opacity(0.08), in: .circle)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(section.title)
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                        Text(section.subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.58))
                                    }

                                    Spacer()
                                }
                                .padding(18)
                                .background(.white.opacity(0.08), in: .rect(cornerRadius: 26))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 26)
                                        .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Plan")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct SleepProgressView: View {
    let viewModel: SleepResetViewModel

    var body: some View {
        let insight = viewModel.breathworkInsight

        NavigationStack {
            ZStack {
                SleepBackdropView(variant: .slate)

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(insight.totalSessions == 0 ? "Finish your first breathwork session and your progress will appear here." : "Your breathwork habit is starting to stack up.")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)

                        HStack(spacing: 12) {
                            ProgressSummaryCard(title: "Current streak", value: "\(insight.currentStreak)", subtitle: "days")
                            ProgressSummaryCard(title: "Best streak", value: "\(insight.longestStreak)", subtitle: "days")
                            ProgressSummaryCard(title: "Sessions", value: "\(insight.totalSessions)", subtitle: "total")
                        }

                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(viewModel.progressPoints) { point in
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.white.opacity(0.88))
                                        .frame(width: 38, height: CGFloat(point.score))
                                    Text(point.day)
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.55))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                }
                                .frame(maxWidth: .infinity, alignment: .bottom)
                            }
                        }
                        .padding(24)
                        .background(.white.opacity(0.08), in: .rect(cornerRadius: 30))
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
                                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Last 7 days")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.58))

                            ForEach(insight.recentDays) { day in
                                HStack(spacing: 14) {
                                    Image(systemName: day.didComplete ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(day.didComplete ? .white : .white.opacity(0.4))

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(day.label)
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                        Text(day.didComplete ? "\(day.sessionCount) session\(day.sessionCount == 1 ? "" : "s") completed" : "No breathwork logged")
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.6))
                                    }

                                    Spacer()
                                }
                            }
                        }
                        .padding(20)
                        .background(.white.opacity(0.08), in: .rect(cornerRadius: 26))
                        .overlay {
                            RoundedRectangle(cornerRadius: 26)
                                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                        }

                        if let result = viewModel.result {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Current benchmark")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.58))
                                Text("Score \(result.score)")
                                    .font(.title.bold())
                                    .foregroundStyle(.white)
                                Text(result.recoveryOutlook)
                                    .font(.body)
                                    .foregroundStyle(.white.opacity(0.65))
                            }
                            .padding(20)
                            .background(.white.opacity(0.08), in: .rect(cornerRadius: 26))
                            .overlay {
                                RoundedRectangle(cornerRadius: 26)
                                    .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 28)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct ProgressSummaryCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.58))
            Text(value)
                .font(.title.weight(.semibold))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.58))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.08), in: .rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct HomeStatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.58))
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.58))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.white.opacity(0.08), in: .rect(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct SleepSettingsView: View {
    let viewModel: SleepResetViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Subscription") {
                    LabeledContent("Status", value: viewModel.hasUnlockedPlan ? "Premium" : "Locked")
                    LabeledContent("Selected plan", value: viewModel.selectedProduct.title)
                }

                Section("Support") {
                    LabeledContent("Privacy", value: "Sleep data stays on-device")

                    Link("Privacy Policy", destination: AppLegal.privacyPolicyURL)
                    Link("Terms of Use", destination: AppLegal.termsOfUseURL)

                    Button("Restore Purchases") {
                        Task {
                            await viewModel.restorePurchases()
                        }
                    }
                }

                Section {
                    Button("Start Over") {
                        viewModel.resetFlow()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SleepBackdropView(variant: .slate))
            .navigationTitle("Settings")
        }
    }
}

private enum AppLegal {
    static let privacyPolicyURL: URL = URL(string: "https://paste.rs/c6Z6L")!
    static let termsOfUseURL: URL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let termsOfUseDescriptionURL: String = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
}

private struct SleepQuestionScreen<Content: View>: View {
    let viewModel: SleepResetViewModel
    let variant: SleepBackdropVariant
    let title: String
    let subtitle: String
    let ctaTitle: String
    let isCTAEnabled: Bool
    @ViewBuilder let content: Content
    let action: () -> Void

    var body: some View {
        ZStack {
            SleepBackdropView(variant: variant)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    SleepTopProgressBar(progress: viewModel.onboardingProgress)
                        .padding(.top, 8)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(title)
                            .font(.system(.largeTitle, design: .default, weight: .regular))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(subtitle)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.68))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 18)

                    content

                    Button(ctaTitle, action: action)
                        .buttonStyle(SleepPrimaryButtonStyle())
                        .disabled(!isCTAEnabled)
                        .padding(.top, 4)
                }
                .frame(maxWidth: 620, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 22)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SleepFixedStepContainer<Content: View>: View {
    let maxWidth: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: maxWidth, alignment: .leading)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 22)
        .padding(.bottom, 20)
    }
}

private struct SleepTopProgressBar: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(.white.opacity(0.16))
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.88))
                        .frame(width: max(proxy.size.width * progress, 24), height: 2)
                }
        }
        .frame(height: 2)
    }
}

private struct SleepChoiceRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(isSelected ? 0.18 : 0.08), in: .circle)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.58))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            .padding(18)
            .background(isSelected ? .white.opacity(0.16) : .white.opacity(0.08), in: .rect(cornerRadius: 24))
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(.white.opacity(isSelected ? 0.24 : 0.12), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SleepDisruptionRow: View {
    let disruption: SleepDisruption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        SleepChoiceRow(
            title: disruption.rawValue,
            subtitle: disruption.headline,
            icon: disruption.icon,
            isSelected: isSelected,
            action: action
        )
    }
}

private struct SleepGlassFeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(.white.opacity(0.08), in: .circle)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(18)
        .background(.white.opacity(0.08), in: .rect(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct SleepWheelCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title3.weight(.medium))
                .foregroundStyle(.white.opacity(0.58))

            content
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 18)
        .background(.white.opacity(0.08), in: .rect(cornerRadius: 30))
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct SleepTimelineCard: View {
    let plan: ResetPlan?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your plan preview")
                .font(.headline)
                .foregroundStyle(.white)

            SleepTimelineRow(icon: "lock.fill", title: "Tonight", subtitle: "Exact bedtime target and wind-down routine")
            SleepTimelineRow(icon: "sunrise.fill", title: "Tomorrow", subtitle: "Wake guidance to keep the reset going")
            SleepTimelineRow(icon: "waveform.path.ecg", title: "This week", subtitle: weeklyPreviewText)
        }
        .padding(18)
        .background(.white.opacity(0.08), in: .rect(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }

    private var weeklyPreviewText: String {
        if let plan {
            return "Built around your target bedtime of \(plan.bedtimeTarget)"
        }

        return "Built around a steadier cadence as your rhythm settles"
    }
}

private struct SleepTimelineRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.64))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }
}

private struct PaywallBenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(.white.opacity(0.06), in: .circle)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.white.opacity(0.08), in: .rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct SessionMetricRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.58))

            Spacer(minLength: 12)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.white.opacity(0.06), in: .rect(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
        }
    }
}

private struct BreathworkSessionView: View {
    @Binding var isPresented: Bool
    let viewModel: SleepResetViewModel
    @State private var currentPhaseIndex: Int = 0
    @State private var completedCycles: Int = 0
    @State private var secondsRemaining: Int = 4
    @State private var isSessionRunning: Bool = false
    @State private var hasRecordedCompletion: Bool = false

    private let phases: [(title: String, seconds: Int, symbol: String)] = [
        ("Inhale", 4, "arrow.up.circle.fill"),
        ("Hold", 4, "pause.circle.fill"),
        ("Exhale", 6, "arrow.down.circle.fill")
    ]
    private let totalCycles: Int = 6

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .midnight)

            VStack(spacing: 28) {
                HStack {
                    Button("Close") {
                        isPresented = false
                    }
                    .buttonStyle(.plain)
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.72))

                    Spacer()

                    Text("Breathwork")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.72))

                    Spacer()

                    Text("\(completedCycles)/\(totalCycles)")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.72))
                }

                Spacer()

                VStack(spacing: 18) {
                    Image(systemName: currentPhase.symbol)
                        .font(.system(size: 44, weight: .medium))
                        .foregroundStyle(.white)
                        .symbolEffect(.pulse)

                    Text(currentPhase.title)
                        .font(.system(.largeTitle, design: .default, weight: .bold))
                        .foregroundStyle(.white)

                    Text("\(secondsRemaining)")
                        .font(.system(size: 88, weight: .bold, design: .default))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())

                    Text(sessionCaption)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .background(.white.opacity(0.08), in: .rect(cornerRadius: 34))
                .overlay {
                    RoundedRectangle(cornerRadius: 34)
                        .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                }

                VStack(spacing: 12) {
                    ProgressView(value: progressValue)
                        .tint(.white)

                    Text(progressLabel)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.62))
                }

                Spacer()

                Button(primaryButtonTitle) {
                    if isSessionComplete {
                        isPresented = false
                    } else {
                        isSessionRunning.toggle()
                    }
                }
                .buttonStyle(SleepPrimaryButtonStyle())
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
        .task {
            while !Task.isCancelled {
                guard isSessionRunning, !isSessionComplete else {
                    do {
                        try await Task.sleep(for: .milliseconds(200))
                    } catch {
                        return
                    }
                    continue
                }

                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    return
                }

                guard isSessionRunning else {
                    continue
                }

                tickSession()
            }
        }
    }

    private var currentPhase: (title: String, seconds: Int, symbol: String) {
        phases[currentPhaseIndex]
    }

    private var progressValue: Double {
        let totalPhaseCount: Int = totalCycles * phases.count
        let completedPhaseCount: Int = completedCycles * phases.count + currentPhaseIndex
        return Double(completedPhaseCount) / Double(totalPhaseCount)
    }

    private var progressLabel: String {
        if isSessionComplete {
            return "Session complete"
        }

        return "Cycle \(completedCycles + 1) of \(totalCycles)"
    }

    private var sessionCaption: String {
        if isSessionComplete {
            return "Nice. Your breath is slower, your exhale is longer, and your body has a calmer runway into sleep."
        }

        return "Follow the count and let your shoulders drop on every exhale."
    }

    private var primaryButtonTitle: String {
        if isSessionComplete {
            return "Done"
        }

        return isSessionRunning ? "Pause" : (completedCycles == 0 && currentPhaseIndex == 0 ? "Begin Session" : "Resume")
    }

    private var completedDurationSeconds: Int {
        completedCycles * phases.reduce(0) { $0 + $1.seconds }
    }

    private var isSessionComplete: Bool {
        completedCycles >= totalCycles
    }

    private func tickSession() {
        guard !isSessionComplete else {
            isSessionRunning = false
            return
        }

        if secondsRemaining > 1 {
            secondsRemaining -= 1
            return
        }

        if currentPhaseIndex < phases.count - 1 {
            currentPhaseIndex += 1
            secondsRemaining = phases[currentPhaseIndex].seconds
            return
        }

        completedCycles += 1

        if completedCycles >= totalCycles {
            isSessionRunning = false
            secondsRemaining = 0
            currentPhaseIndex = phases.count - 1
            if !hasRecordedCompletion {
                hasRecordedCompletion = true
                viewModel.recordBreathworkSession(
                    completedCycles: completedCycles,
                    totalCycles: totalCycles,
                    durationSeconds: completedDurationSeconds
                )
            }
            return
        }

        currentPhaseIndex = 0
        secondsRemaining = phases[0].seconds
    }
}

private struct SleepArtworkCard<Artwork: View>: View {
    let title: String
    @ViewBuilder let artwork: Artwork

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Color.clear
                .frame(width: 230, height: 190)
                .overlay {
                    artwork
                        .allowsHitTesting(false)
                }
                .clipShape(.rect(cornerRadius: 26))

            Text(title)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.82))
                .padding(.horizontal, 6)
        }
    }
}

private struct SleepPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.weight(.medium))
            .foregroundStyle(.black.opacity(0.64))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(.white.opacity(configuration.isPressed ? 0.9 : 0.98), in: .capsule)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.86), value: configuration.isPressed)
    }
}

private struct SleepAccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.black.opacity(0.78))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(Color(red: 0.89, green: 0.93, blue: 0.96).opacity(configuration.isPressed ? 0.86 : 1), in: .capsule)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.86), value: configuration.isPressed)
    }
}

private struct SleepBackdropView: View {
    let variant: SleepBackdropVariant

    init(variant: SleepBackdropVariant = .midnight) {
        self.variant = variant
    }

    var body: some View {
        LinearGradient(
            colors: variant.colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Circle()
                .fill(variant.topGlow)
                .frame(width: 380, height: 380)
                .blur(radius: 110)
                .offset(x: 120, y: -210)
                .allowsHitTesting(false)
        }
        .overlay {
            Circle()
                .fill(variant.bottomGlow)
                .frame(width: 340, height: 340)
                .blur(radius: 120)
                .offset(x: -120, y: 330)
                .allowsHitTesting(false)
        }
        .overlay {
            LinearGradient(
                colors: [.white.opacity(0.05), .clear, .black.opacity(0.20)],
                startPoint: .top,
                endPoint: .bottom
            )
            .blendMode(.softLight)
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

private nonisolated enum SleepBackdropVariant {
    case midnight
    case harbor
    case aurora
    case slate
    case dawn

    var colors: [Color] {
        switch self {
        case .midnight:
            [Color(red: 0.07, green: 0.11, blue: 0.17), Color(red: 0.10, green: 0.14, blue: 0.22), Color(red: 0.04, green: 0.05, blue: 0.09)]
        case .harbor:
            [Color(red: 0.08, green: 0.18, blue: 0.22), Color(red: 0.07, green: 0.12, blue: 0.18), Color(red: 0.04, green: 0.08, blue: 0.12)]
        case .aurora:
            [Color(red: 0.13, green: 0.20, blue: 0.24), Color(red: 0.07, green: 0.11, blue: 0.14), Color(red: 0.05, green: 0.06, blue: 0.09)]
        case .slate:
            [Color(red: 0.13, green: 0.14, blue: 0.20), Color(red: 0.10, green: 0.11, blue: 0.16), Color(red: 0.05, green: 0.05, blue: 0.08)]
        case .dawn:
            [Color(red: 0.16, green: 0.20, blue: 0.27), Color(red: 0.10, green: 0.13, blue: 0.19), Color(red: 0.06, green: 0.07, blue: 0.11)]
        }
    }

    var topGlow: Color {
        switch self {
        case .midnight:
            .cyan.opacity(0.14)
        case .harbor:
            .mint.opacity(0.15)
        case .aurora:
            .teal.opacity(0.18)
        case .slate:
            .indigo.opacity(0.16)
        case .dawn:
            .white.opacity(0.16)
        }
    }

    var bottomGlow: Color {
        switch self {
        case .midnight:
            .indigo.opacity(0.14)
        case .harbor:
            .blue.opacity(0.12)
        case .aurora:
            .mint.opacity(0.10)
        case .slate:
            .cyan.opacity(0.10)
        case .dawn:
            .blue.opacity(0.12)
        }
    }
}

#Preview {
    SleepResetFlowView()
}
