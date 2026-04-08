import SwiftUI

struct SleepResetFlowView: View {
    @State private var viewModel: SleepResetViewModel = SleepResetViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.path) {
            SleepWelcomeView(viewModel: viewModel)
                .navigationDestination(for: SleepResetStep.self) { step in
                    switch step {
                    case .welcome:
                        SleepWelcomeView(viewModel: viewModel)
                    case .goals:
                        SleepGoalsView(viewModel: viewModel)
                    case .input:
                        SleepInputView(viewModel: viewModel)
                    case .analyzing:
                        SleepAnalyzingView()
                    case .result:
                        SleepResultView(viewModel: viewModel)
                    case .paywall:
                        SleepPaywallView(viewModel: viewModel)
                    case .dashboard:
                        SleepDashboardView(viewModel: viewModel)
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
            SleepBackdropView(variant: .warm)

            VStack(alignment: .leading, spacing: 0) {
                SleepTopProgressBar(progress: 0.14)
                    .padding(.top, 8)

                Spacer()

                VStack(alignment: .leading, spacing: 18) {
                    Text("Reset your sleep rhythm")
                        .font(.system(.largeTitle, design: .default, weight: .regular))
                        .foregroundStyle(.white)

                    Text("Get a fast personalized sleep reset score and see the exact plan to feel normal again.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                VStack(spacing: 16) {
                    SleepGlassFeatureCard(
                        icon: "moon.stars.fill",
                        title: "Fast score reveal",
                        subtitle: "A dramatic sleep score you can understand in seconds"
                    )

                    SleepGlassFeatureCard(
                        icon: "alarm.fill",
                        title: "Targeted reset plan",
                        subtitle: "Tonight's bedtime, tomorrow's wake target, and recovery steps"
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
    let viewModel: SleepResetViewModel

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .warm)

            VStack(alignment: .leading, spacing: 0) {
                SleepTopProgressBar(progress: 0.34)
                    .padding(.top, 8)

                Spacer(minLength: 28)

                Text("What is your current primary goal?")
                    .font(.system(.largeTitle, design: .default, weight: .regular))
                    .foregroundStyle(.white)
                    .padding(.bottom, 34)

                LazyVGrid(columns: columns, spacing: 14) {
                    SleepGoalCard(icon: "moon.zzz.fill", title: "Improve sleep", subtitle: "Wake up feeling steady", isSelected: true)
                    SleepGoalCard(icon: "scope", title: "Improve focus", subtitle: "Clear the brain fog", isSelected: false)
                    SleepGoalCard(icon: "wind", title: "Reduce stress", subtitle: "Settle your nights", isSelected: false)
                    SleepGoalCard(icon: "bolt.heart.fill", title: "Boost energy", subtitle: "Recover your mornings", isSelected: false)
                }

                Spacer()

                Button("Next") {
                    viewModel.continueFromGoals()
                }
                .buttonStyle(SleepPrimaryButtonStyle())
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SleepInputView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .cool)

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    SleepDualProgressHeader(progress: 0.62)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("What's your target bedtime?")
                            .font(.system(.largeTitle, design: .default, weight: .regular))
                            .foregroundStyle(.white)

                        Text("A more regular bedtime helps your body clock settle faster.")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.62))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    SleepWheelCard(title: "Set Your Bedtime") {
                        DatePicker("Bedtime", selection: $viewModel.bedtime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .colorScheme(.dark)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("What time do you usually wake up?")
                            .font(.title2.weight(.medium))
                            .foregroundStyle(.white)

                        SleepWheelCard(title: "Set Your Wake Time") {
                            DatePicker("Wake time", selection: $viewModel.wakeTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .colorScheme(.dark)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("How is your energy today?")
                            .font(.title2.weight(.medium))
                            .foregroundStyle(.white)

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(EnergyLevel.allCases) { level in
                                Button {
                                    viewModel.energyLevel = level
                                } label: {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(level.rawValue)
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                        Text(energySubtitle(for: level))
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.55))
                                            .multilineTextAlignment(.leading)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
                                    .padding(18)
                                    .background(
                                        viewModel.energyLevel == level ? .white.opacity(0.18) : .white.opacity(0.08),
                                        in: .rect(cornerRadius: 28)
                                    )
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 28)
                                            .strokeBorder(.white.opacity(viewModel.energyLevel == level ? 0.34 : 0.16), lineWidth: 1)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("What's disrupting your sleep most?")
                            .font(.title2.weight(.medium))
                            .foregroundStyle(.white)

                        ForEach(SleepDisruption.allCases) { disruption in
                            Button {
                                viewModel.disruption = disruption
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: viewModel.disruption == disruption ? "checkmark.circle.fill" : "circle")
                                        .font(.title3)
                                        .foregroundStyle(.white)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(disruption.rawValue)
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                        Text(disruption.headline)
                                            .font(.subheadline)
                                            .foregroundStyle(.white.opacity(0.58))
                                    }

                                    Spacer()
                                }
                                .padding(18)
                                .background(.white.opacity(0.08), in: .rect(cornerRadius: 26))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 26)
                                        .strokeBorder(.white.opacity(0.14), lineWidth: 1)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                        Task {
                            await viewModel.analyze()
                        }
                    } label: {
                        HStack(spacing: 10) {
                            if viewModel.isAnalyzing {
                                ProgressView()
                                    .tint(Color.black.opacity(0.75))
                            }
                            Text(viewModel.isAnalyzing ? "Customizing..." : "Next")
                        }
                    }
                    .buttonStyle(SleepPrimaryButtonStyle())
                    .disabled(viewModel.isAnalyzing)

                    Text("Don't worry, you can change it later")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.42))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func energySubtitle(for level: EnergyLevel) -> String {
        switch level {
        case .depleted:
            "You are running on empty"
        case .low:
            "You feel behind all day"
        case .okay:
            "You are functioning, not thriving"
        case .strong:
            "You still have solid momentum"
        }
    }
}

private struct SleepAnalyzingView: View {
    @State private var pulseOpacity: Double = 0.42

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .cool)

            VStack {
                Spacer()

                Text("Customizing...")
                    .font(.system(.title, design: .default, weight: .regular))
                    .foregroundStyle(.white.opacity(pulseOpacity))

                Spacer()
            }
        }
        .task {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseOpacity = 0.9
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
            SleepBackdropView(variant: .violet)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let result = viewModel.result {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your sleep reset score")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.58))

                            Text("\(result.score)")
                                .font(.system(size: 108, weight: .bold, design: .default))
                                .foregroundStyle(.white)
                                .contentTransition(.numericText())

                            Text(result.title)
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(.white)

                            Text(result.summary)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.68))
                                .fixedSize(horizontal: false, vertical: true)

                            Text(result.recoveryOutlook)
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .padding(24)
                        .background(.white.opacity(0.08), in: .rect(cornerRadius: 34))
                        .overlay {
                            RoundedRectangle(cornerRadius: 34)
                                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                        }

                        ForEach(result.pillars) { pillar in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label(pillar.title, systemImage: pillar.icon)
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("\(pillar.value)")
                                        .font(.headline)
                                        .foregroundStyle(.white.opacity(0.72))
                                }

                                Capsule()
                                    .fill(.white.opacity(0.12))
                                    .frame(height: 10)
                                    .overlay(alignment: .leading) {
                                        Capsule()
                                            .fill(.white)
                                            .frame(width: max(CGFloat(pillar.value) * 2.4, 24), height: 10)
                                    }
                            }
                            .padding(18)
                            .background(.white.opacity(0.08), in: .rect(cornerRadius: 26))
                            .overlay {
                                RoundedRectangle(cornerRadius: 26)
                                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Main driver")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.58))
                            Text(viewModel.disruption.headline)
                                .font(.title3.weight(.medium))
                                .foregroundStyle(.white)
                        }
                        .padding(18)
                        .background(.white.opacity(0.08), in: .rect(cornerRadius: 26))
                        .overlay {
                            RoundedRectangle(cornerRadius: 26)
                                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                        }

                        Button("Unlock My Reset Plan") {
                            viewModel.showPaywall()
                        }
                        .buttonStyle(SleepPrimaryButtonStyle())
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 26)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}

private struct SleepPaywallView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
            SleepBackdropView(variant: .green)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Button {
                        if !viewModel.path.isEmpty {
                            _ = viewModel.path.popLast()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(.white.opacity(0.06), in: .circle)
                            .overlay {
                                Circle()
                                    .strokeBorder(.green.opacity(0.45), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 6)

                    VStack(spacing: 14) {
                        Text("A Better Night Starts Here.")
                            .font(.system(.largeTitle, design: .default, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)

                        HStack(spacing: 14) {
                            SleepStatBadge(title: "App Store", subtitle: "Sleep Favorite")
                            SleepStatBadge(title: "5 STARS", subtitle: "Reset-friendly")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)

                    SleepTimelineCard(plan: viewModel.plan)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Membership")
                            .font(.title.weight(.medium))
                            .foregroundStyle(.white)

                        PaywallBenefitRow(icon: "moon.zzz.fill", title: "Unlimited reset plans", subtitle: "Keep adjusting bedtime and wake targets as your schedule changes")
                        PaywallBenefitRow(icon: "list.bullet.clipboard.fill", title: "Step-by-step night routine", subtitle: "Concrete wind-down and morning recovery actions")
                        PaywallBenefitRow(icon: "chart.line.uptrend.xyaxis", title: "Track your rebound", subtitle: "See how your sleep reset score improves over the week")
                    }
                    .padding(20)
                    .background(.white.opacity(0.08), in: .rect(cornerRadius: 30))
                    .overlay {
                        RoundedRectangle(cornerRadius: 30)
                            .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                    }

                    VStack(spacing: 12) {
                        ForEach(SubscriptionProduct.allCases) { product in
                            SubscriptionOptionCard(
                                product: product,
                                isSelected: viewModel.selectedProduct == product
                            ) {
                                viewModel.selectedProduct = product
                            }
                        }
                    }

                    Text(selectedPricingLine)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.55))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)

                    Button("Continue") {
                        viewModel.purchaseSelectedPlan()
                    }
                    .buttonStyle(SleepAccentButtonStyle())
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private var selectedPricingLine: String {
        switch viewModel.selectedProduct {
        case .weekly:
            "$9.99/week. Cancel anytime in Settings."
        case .yearly:
            "$39.99/year. Best value for long-term consistency."
        }
    }
}

private struct SubscriptionOptionCard: View {
    let product: SubscriptionProduct
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(product.title)
                            .font(.headline)
                            .foregroundStyle(.white)

                        if product == .yearly {
                            Text("BEST VALUE")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.black.opacity(0.72))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.white, in: .capsule)
                        }
                    }

                    Text(product.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.58))
                }

                Spacer()

                Text(product.rawValue)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(18)
            .background(isSelected ? .white.opacity(0.14) : .white.opacity(0.08), in: .rect(cornerRadius: 26))
            .overlay {
                RoundedRectangle(cornerRadius: 26)
                    .strokeBorder(.white.opacity(isSelected ? 0.24 : 0.10), lineWidth: 1)
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

    private let quickActions: [(String, String)] = [
        ("Wind Down", "leaf.fill"),
        ("Breathwork", "wind"),
        ("Sleep Tracker", "moon.zzz.fill")
    ]

    private let topics: [String] = [
        "✨ Daily Reset",
        "☾ Sleep",
        "📖 Improve Focus",
        "💨 Breathwork",
        "🌿 Emotion Regulation",
        "🛁 Recovery"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                SleepBackdropView(variant: .violet)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Good day")
                                .font(.system(.largeTitle, design: .default, weight: .bold))
                                .foregroundStyle(.white)

                            Text("S M T W T F S")
                                .font(.headline)
                                .tracking(6)
                                .foregroundStyle(.white.opacity(0.48))
                        }

                        HStack(spacing: 14) {
                            ForEach(quickActions, id: \.0) { action in
                                VStack(alignment: .leading, spacing: 18) {
                                    Image(systemName: action.1)
                                        .font(.title2)
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text(action.0)
                                        .font(.title3.weight(.medium))
                                        .foregroundStyle(.white.opacity(0.82))
                                }
                                .padding(18)
                                .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
                                .background(.white.opacity(0.08), in: .rect(cornerRadius: 28))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 28)
                                        .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Today")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.42))

                            Text(todayQuote)
                                .font(.title2)
                                .foregroundStyle(.white)
                                .fixedSize(horizontal: false, vertical: true)

                            Text("A calmer night starts with a smaller shift.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.42))
                        }
                        .padding(20)
                        .background(.white.opacity(0.06), in: .rect(cornerRadius: 30))
                        .overlay(alignment: .trailing) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.75), Color.green.opacity(0.72)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 128, height: 128)
                                .blur(radius: 1)
                                .padding(.trailing, 10)
                                .allowsHitTesting(false)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
                                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                        }

                        ScrollView(.horizontal) {
                            HStack(spacing: 10) {
                                ForEach(topics, id: \.self) { topic in
                                    Text(topic)
                                        .font(.headline)
                                        .foregroundStyle(.white.opacity(0.92))
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 12)
                                        .background(.white.opacity(0.08), in: .capsule)
                                        .overlay {
                                            Capsule()
                                                .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                                        }
                                }
                            }
                        }
                        .contentMargins(.horizontal, 0)
                        .scrollIndicators(.hidden)

                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Quiet the mind")
                                    .font(.largeTitle.weight(.medium))
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.8))
                            }

                            ScrollView(.horizontal) {
                                HStack(spacing: 16) {
                                    SleepArtworkCard(title: "Moon cycle") {
                                        LinearGradient(
                                            colors: [Color.black, Color(red: 0.20, green: 0.15, blue: 0.18)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .overlay {
                                            HStack(spacing: 14) {
                                                ForEach(0..<5, id: \.self) { index in
                                                    Image(systemName: moonSymbol(for: index))
                                                        .font(.system(size: 24))
                                                        .foregroundStyle(.orange.opacity(0.88))
                                                }
                                            }
                                            .allowsHitTesting(false)
                                        }
                                    }

                                    SleepArtworkCard(title: "Still water") {
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.92), Color.orange.opacity(0.30)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.brown.opacity(0.85))
                                                .frame(width: 82, height: 16)
                                                .rotationEffect(.degrees(-8))
                                                .offset(y: 18)
                                                .allowsHitTesting(false)
                                        }
                                    }
                                }
                            }
                            .contentMargins(.horizontal, 0)
                            .scrollIndicators(.hidden)
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
    }

    private var todayQuote: String {
        "If you want to quiet the anxiety of life, return to rhythm, breath, and rest."
    }

    private func moonSymbol(for index: Int) -> String {
        switch index {
        case 0:
            "moonphase.waxing.crescent"
        case 1:
            "moonphase.first.quarter"
        case 2:
            "moonphase.waxing.gibbous"
        case 3:
            "moonphase.full.moon"
        default:
            "moonphase.waning.gibbous"
        }
    }
}

private struct SleepPlanView: View {
    let viewModel: SleepResetViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                SleepBackdropView(variant: .violet)

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
        NavigationStack {
            ZStack {
                SleepBackdropView(variant: .violet)

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Your score is moving in the right direction.")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)

                        HStack(alignment: .bottom, spacing: 12) {
                            ForEach(viewModel.progressPoints) { point in
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.white.opacity(0.88))
                                        .frame(width: 44, height: CGFloat(point.score) * 1.4)
                                    Text(point.day)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.55))
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(24)
                        .background(.white.opacity(0.08), in: .rect(cornerRadius: 30))
                        .overlay {
                            RoundedRectangle(cornerRadius: 30)
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
                    LabeledContent("Restore purchases", value: "Coming next")
                }

                Section {
                    Button("Start Over") {
                        viewModel.resetFlow()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(SleepBackdropView(variant: .violet))
            .navigationTitle("Settings")
        }
    }
}

private struct SleepTopProgressBar: View {
    let progress: CGFloat

    var body: some View {
        Capsule()
            .fill(.white.opacity(0.18))
            .frame(height: 2)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.85))
                    .frame(width: max(progress, 0.05) * 320, height: 2)
            }
    }
}

private struct SleepDualProgressHeader: View {
    let progress: CGFloat

    var body: some View {
        HStack(spacing: 14) {
            Capsule()
                .fill(.white.opacity(0.85))
                .frame(height: 2)

            Capsule()
                .fill(.white.opacity(0.16))
                .frame(height: 2)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.32))
                        .frame(width: max(progress, 0.1) * 150, height: 2)
                }

            Spacer(minLength: 0)

            Text("Skip")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.62))
        }
    }
}

private struct SleepGoalCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: icon)
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(isSelected ? .black.opacity(0.82) : .white)

            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(isSelected ? .black.opacity(0.82) : .white.opacity(0.82))
                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .black.opacity(0.55) : .white.opacity(0.38))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 210, alignment: .topLeading)
        .background(cardBackground, in: .rect(cornerRadius: 30))
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(isSelected ? .white.opacity(0.26) : .white.opacity(0.16), lineWidth: 1)
        }
    }

    private var cardBackground: some ShapeStyle {
        isSelected ? AnyShapeStyle(.white.opacity(0.9)) : AnyShapeStyle(.white.opacity(0.08))
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
                .font(.title2.weight(.medium))
                .foregroundStyle(.white.opacity(0.55))

            content
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 24)
        .background(.white.opacity(0.08), in: .rect(cornerRadius: 30))
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct SleepStatBadge: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.65))
        }
    }
}

private struct SleepTimelineCard: View {
    let plan: ResetPlan?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SleepTimelineRow(icon: "lock.fill", title: "Today", subtitle: "Unlock tonight's bedtime target and full reset plan.")
            SleepTimelineRow(icon: "bell.fill", title: "Tomorrow", subtitle: "Use your wake target and keep the rebound going.")
            SleepTimelineRow(icon: "checkmark.shield.fill", title: "This week", subtitle: plan?.bedtimeTarget ?? "Adjust your target as your schedule stabilizes.")
        }
        .padding(20)
        .background(.white.opacity(0.08), in: .rect(cornerRadius: 30))
        .overlay {
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(.white.opacity(0.10), lineWidth: 1)
        }
    }
}

private struct SleepTimelineRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }
}

private struct PaywallBenefitRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.yellow.opacity(0.78))
                .frame(width: 44, height: 44)
                .background(.white.opacity(0.06), in: .circle)

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
            .foregroundStyle(.black.opacity(0.55))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(.white.opacity(configuration.isPressed ? 0.90 : 0.98), in: .capsule)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.86), value: configuration.isPressed)
    }
}

private struct SleepAccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(red: 0.97, green: 0.74, blue: 0.29).opacity(configuration.isPressed ? 0.88 : 1), in: .capsule)
            .scaleEffect(configuration.isPressed ? 0.99 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.86), value: configuration.isPressed)
    }
}

private struct SleepBackdropView: View {
    let variant: SleepBackdropVariant

    init(variant: SleepBackdropVariant = .warm) {
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
                colors: [.white.opacity(0.08), .clear, .black.opacity(0.22)],
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
    case warm
    case cool
    case violet
    case green

    var colors: [Color] {
        switch self {
        case .warm:
            [Color(red: 0.26, green: 0.23, blue: 0.20), Color(red: 0.23, green: 0.21, blue: 0.19), Color(red: 0.11, green: 0.11, blue: 0.13)]
        case .cool:
            [Color(red: 0.18, green: 0.23, blue: 0.21), Color(red: 0.11, green: 0.15, blue: 0.16), Color(red: 0.08, green: 0.09, blue: 0.11)]
        case .violet:
            [Color(red: 0.20, green: 0.16, blue: 0.18), Color(red: 0.17, green: 0.14, blue: 0.15), Color(red: 0.10, green: 0.10, blue: 0.11)]
        case .green:
            [Color(red: 0.17, green: 0.24, blue: 0.15), Color(red: 0.18, green: 0.22, blue: 0.15), Color(red: 0.10, green: 0.14, blue: 0.11)]
        }
    }

    var topGlow: Color {
        switch self {
        case .warm:
            .white.opacity(0.14)
        case .cool:
            .green.opacity(0.18)
        case .violet:
            .orange.opacity(0.10)
        case .green:
            .green.opacity(0.24)
        }
    }

    var bottomGlow: Color {
        switch self {
        case .warm:
            .white.opacity(0.08)
        case .cool:
            .cyan.opacity(0.10)
        case .violet:
            .green.opacity(0.18)
        case .green:
            .yellow.opacity(0.10)
        }
    }
}

#Preview {
    SleepResetFlowView()
}
