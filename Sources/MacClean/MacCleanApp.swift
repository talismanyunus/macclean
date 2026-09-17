import SwiftUI

@main
struct MacCleanApp: App {
    @StateObject private var cleaner = CleanerViewModel()
    @StateObject private var langManager = LanguageManager.shared
    @State private var showOnboarding: Bool = !UserDefaults.standard.bool(forKey: "MacClean.onboardingComplete")

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cleaner)
                .environmentObject(langManager)
                .frame(minWidth: 980, minHeight: 700)
                .sheet(isPresented: $showOnboarding) {
                    OnboardingView {
                        UserDefaults.standard.set(true, forKey: "MacClean.onboardingComplete")
                        showOnboarding = false
                    }
                    .environmentObject(langManager)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
