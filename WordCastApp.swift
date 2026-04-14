import SwiftUI

@main
struct WordCastApp: App {
    @StateObject private var store = WordCastStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
