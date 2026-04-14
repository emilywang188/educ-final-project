import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: WordCastStore
    @State private var selection: AppTab = .today

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                ZStack(alignment: .bottom) {
                    NavigationStack {
                        content
                            .toolbar(.hidden, for: .navigationBar)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    GlassTabBar(selection: $selection)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                }
                .background(Theme.background)
            } else {
                NavigationStack {
                    OnboardingView()
                }
            }
        }
        .onAppear {
            store.loadTodayIfNeeded()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch selection {
        case .today:
            TodayView()
        case .review:
            ReviewView()
        case .library:
            LibraryView()
        case .settings:
            SettingsView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(WordCastStore.preview)
    }
}
