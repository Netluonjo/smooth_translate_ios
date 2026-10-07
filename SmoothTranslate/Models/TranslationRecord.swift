import Foundation

struct TranslationRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let sourceLang: String
    let targetLang: String
    let originalText: String
    let translatedText: String
    var timestamp: Date = Date()
    var isFavorite: Bool = false
}
