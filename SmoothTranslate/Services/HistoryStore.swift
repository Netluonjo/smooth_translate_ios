import Foundation

@MainActor
class HistoryStore: ObservableObject {
    @Published var records: [TranslationRecord] = []

    private let storageKey = "smooth_translate_history_records"

    init() {
        loadHistory()
    }

    func addRecord(sourceLang: String, targetLang: String, originalText: String, translatedText: String) {
        guard !originalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !translatedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Avoid adding duplicate immediate record
        if let first = records.first, first.originalText == originalText && first.translatedText == translatedText {
            return
        }

        let newRecord = TranslationRecord(
            sourceLang: sourceLang,
            targetLang: targetLang,
            originalText: originalText,
            translatedText: translatedText
        )
        records.insert(newRecord, at: 0)
        saveHistory()
    }

    func toggleFavorite(id: UUID) {
        if let index = records.firstIndex(where: { $0.id == id }) {
            records[index].isFavorite.toggle()
            saveHistory()
        }
    }

    func deleteRecord(id: UUID) {
        records.removeAll { $0.id == id }
        saveHistory()
    }

    func clearAll() {
        records.removeAll()
        saveHistory()
    }

    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([TranslationRecord].self, from: data) {
            records = decoded
        }
    }
}
