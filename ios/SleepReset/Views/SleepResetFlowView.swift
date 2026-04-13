import SwiftUI

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
                            case .bedtime:
                                SleepBedtimeView(viewModel: viewModel)
                            case .wakeTime:
                                SleepWakeTimeView(viewModel: viewModel)
                            case .disruption:
                                SleepDisruptionView(viewModel: viewModel)
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
        ZStack {
            SleepBackdropView(variant: .harbor)

            VStack(alignment: .leading, spacing: 0) {
                SleepTopProgressBar(progress: 0.30)
                    .padding(.top, 8)

                Spacer(minLength: 26)

                VStack(alignment: .leading, spacing: 10) {
                    Text("What is your primary goal?")
                        .font(.system(.largeTitle, design: .default, weight: .regular))
                        .foregroundStyle(.white)

                    Text("Choose the outcome you care about most right now.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.68))
                }

                Spacer(minLength: 24)

                VStack(spacing: 12) {
                    ForEach(SleepGoal.allCases) { goal in
                        SleepGoalRow(goal: goal, isSelected: viewModel.selectedGoal == goal) {
                            viewModel.selectedGoal = goal
                        }
                    }
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

private struct SleepBedtimeView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .harbor)

            VStack(alignment: .leading, spacing: 0) {
                SleepTopProgressBar(progress: 0.48)
                    .padding(.top, 8)

                Spacer(minLength: 24)

                VStack(alignment: .leading, spacing: 10) {
                    Text("What's your target bedtime?")
                        .font(.system(.largeTitle, design: .default, weight: .regular))
                        .foregroundStyle(.white)

                    Text("Pick the time you want your body to start settling into consistently.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 24)

                SleepWheelCard(title: "Target Bedtime") {
                    DatePicker("Bedtime", selection: $viewModel.bedtime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                }

                Spacer()

                Button("Next") {
                    viewModel.continueFromBedtime()
                }
                .buttonStyle(SleepPrimaryButtonStyle())
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SleepWakeTimeView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .harbor)

            VStack(alignment: .leading, spacing: 0) {
                SleepTopProgressBar(progress: 0.66)
                    .padding(.top, 8)

                Spacer(minLength: 24)

                VStack(alignment: .leading, spacing: 10) {
                    Text("What time do you usually wake up?")
                        .font(.system(.largeTitle, design: .default, weight: .regular))
                        .foregroundStyle(.white)

                    Text("This helps shape a plan you can actually stick with tomorrow.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 24)

                SleepWheelCard(title: "Wake Time") {
                    DatePicker("Wake time", selection: $viewModel.wakeTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                }

                Spacer()

                Button("Next") {
                    viewModel.continueFromWakeTime()
                }
                .buttonStyle(SleepPrimaryButtonStyle())
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SleepDisruptionView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .aurora)

            VStack(alignment: .leading, spacing: 0) {
                SleepTopProgressBar(progress: 0.82)
                    .padding(.top, 8)

                Spacer(minLength: 24)

                VStack(alignment: .leading, spacing: 10) {
                    Text("What's disrupting your sleep most?")
                        .font(.system(.largeTitle, design: .default, weight: .regular))
                        .foregroundStyle(.white)

                    Text("Pick the biggest reason your rhythm feels off right now.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 24)

                VStack(spacing: 12) {
                    ForEach(SleepDisruption.allCases) { disruption in
                        SleepDisruptionRow(disruption: disruption, isSelected: viewModel.disruption == disruption) {
                            viewModel.disruption = disruption
                        }
                    }
                }

                Spacer()

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
                        Text(viewModel.isAnalyzing ? "Customizing..." : "See My Score")
                    }
                }
                .buttonStyle(SleepPrimaryButtonStyle())
                .disabled(viewModel.isAnalyzing)
            }
            .padding(.horizontal, 22)
            .padding(.bottom, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct SleepAnalyzingView: View {
    @State private var pulseOpacity: Double = 0.42

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .aurora)

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
                        Text(viewModel.disruption.headline)
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
                        viewModel.showPaywall()
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

private struct SleepPaywallView: View {
    @Bindable var viewModel: SleepResetViewModel

    var body: some View {
        ZStack {
            SleepBackdropView(variant: .dawn)

            VStack(alignment: .leading, spacing: 12) {
                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Unlock your reset plan")
                        .font(.system(.title, design: .default, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text("Subscribe to open tonight’s plan, tomorrow’s wake guidance, and progress tracking.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }

                SleepTimelineCard(plan: viewModel.plan)

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

                Text(selectedPricingLine)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.64))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

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
                            .minimumScaleFactor(0.85)
                    }
                }
                .buttonStyle(SleepAccentButtonStyle())
                .disabled(viewModel.isPurchasing || viewModel.isLoadingProducts)

                HStack(spacing: 8) {
                    PaywallBenefitRow(icon: "bed.double.fill", title: "Tonight", subtitle: "Exact bedtime target")
                    PaywallBenefitRow(icon: "sun.max.fill", title: "Tomorrow", subtitle: "Wake guidance")
                }

                Button("Restore Purchases") {
                    Task {
                        await viewModel.restorePurchases()
                    }
                }
                .buttonStyle(.plain)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.68))
                .frame(maxWidth: .infinity)
                .disabled(viewModel.isPurchasing)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 16)
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

    private var purchaseButtonTitle: String {
        switch viewModel.selectedProduct {
        case .weekly:
            "Subscribe for $12.99/week"
        case .yearly:
            "Subscribe for $49.99/year"
        }
    }

    private var selectedPricingLine: String {
        switch viewModel.selectedProduct {
        case .weekly:
            "$12.99 per week. No trial. Auto-renews until canceled in Settings."
        case .yearly:
            "$49.99 per year. No trial. Lowest effective price for long-term reset support."
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

    private let quickActions: [(String, String)] = [
        ("Wind Down", "leaf.fill"),
        ("Breathwork", "wind"),
        ("Sleep Tracker", "moon.zzz.fill")
    ]

    private let topics: [String] = [
        "Daily Reset",
        "Deep Sleep",
        "Calm Evenings",
        "Breathwork",
        "Mind Quieting",
        "Morning Recovery"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                SleepBackdropView(variant: .slate)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Good evening")
                                .font(.system(.largeTitle, design: .default, weight: .bold))
                                .foregroundStyle(.white)

                            Text("Your next calm step is ready")
                                .font(.headline)
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
                                        .foregroundStyle(.white.opacity(0.84))
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

                            Text("A steadier night starts with a smaller shift.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.42))
                        }
                        .padding(20)
                        .background(.white.opacity(0.06), in: .rect(cornerRadius: 30))
                        .overlay(alignment: .trailing) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.7), Color.cyan.opacity(0.5)],
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
                                Text("Settle the mind")
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
                                            colors: [Color.black, Color(red: 0.16, green: 0.19, blue: 0.25)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .overlay {
                                            HStack(spacing: 14) {
                                                ForEach(0..<5, id: \.self) { index in
                                                    Image(systemName: moonSymbol(for: index))
                                                        .font(.system(size: 24))
                                                        .foregroundStyle(.cyan.opacity(0.85))
                                                }
                                            }
                                            .allowsHitTesting(false)
                                        }
                                    }

                                    SleepArtworkCard(title: "Still water") {
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.92), Color.cyan.opacity(0.26)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(.black.opacity(0.7))
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
        "If you want to soften the pressure of the day, return to rhythm, breath, and rest."
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
        NavigationStack {
            ZStack {
                SleepBackdropView(variant: .slate)

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

private struct SleepGoalRow: View {
    let goal: SleepGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: goal.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(isSelected ? 0.18 : 0.08), in: .circle)

                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.rawValue)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(goal.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.58))
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
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: disruption.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(isSelected ? 0.18 : 0.08), in: .circle)

                VStack(alignment: .leading, spacing: 4) {
                    Text(disruption.rawValue)
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text(disruption.headline)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.58))
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
