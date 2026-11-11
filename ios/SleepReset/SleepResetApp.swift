//
//  SleepResetApp.swift
//  SleepReset
//
//  Created by Rork on April 3, 2026.
//

import SwiftUI
import SwiftData
import RevenueCat

@main
struct SleepResetApp: App {
    init() {
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY)
        #else
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY)
        #endif

        // Mixpanel (shared spec: kpi-churn-event-spec-2026-11-11 §3.2/§3.3).
        // Token is delivered via the INFOPLIST_KEY_MIXPANEL_TOKEN build setting
        // because this repo's Config type is generated outside the repo.
        AnalyticsService.shared.configure(token: Bundle.main.object(forInfoDictionaryKey: "MIXPANEL_TOKEN") as? String ?? "")
        // Link client events with RevenueCat's server-side rc_* events.
        if let distinctId = AnalyticsService.shared.distinctId {
            Purchases.shared.setAttributes(["$mixpanel_distinct_id": distinctId])
        }
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
