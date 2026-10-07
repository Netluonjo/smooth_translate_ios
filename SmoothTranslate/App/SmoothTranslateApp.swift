import SwiftUI

@main
struct SmoothTranslateApp: App {
    @StateObject private var translationService = TranslationService()
    @StateObject private var historyStore = HistoryStore()
    @StateObject private var ttsService = TtsService()

    var body: some Scene {
        WindowGroup {
            HomeScreen()
                .environmentObject(translationService)
                .environmentObject(historyStore)
                .environmentObject(ttsService)
                .preferredColorScheme(.light) // Elegant premium light theme
        }
    }
}
