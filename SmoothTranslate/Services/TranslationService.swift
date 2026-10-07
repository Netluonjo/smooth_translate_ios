import Foundation

@MainActor
class TranslationService: ObservableObject {
    @Published var downloadedModels: Set<String> = ["en", "vi"]
    @Published var downloadingModels: Set<String> = []
    @Published var isTranslating: Bool = false

    private let userDefaultsKey = "smooth_translate_downloaded_models"

    init() {
        if let saved = UserDefaults.standard.stringArray(forKey: userDefaultsKey) {
            downloadedModels = Set(saved)
        } else {
            downloadedModels = ["en", "vi"]
            saveDownloadedModels()
        }
    }

    private func saveDownloadedModels() {
        UserDefaults.standard.set(Array(downloadedModels), forKey: userDefaultsKey)
    }

    func isModelDownloaded(_ code: String) -> Bool {
        downloadedModels.contains(code.lowercased())
    }

    func downloadModel(_ code: String) async {
        let codeLower = code.lowercased()
        downloadingModels.insert(codeLower)
        // Simulate downloading offline neural pack (~30MB)
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        downloadingModels.remove(codeLower)
        downloadedModels.insert(codeLower)
        saveDownloadedModels()
    }

    func deleteModel(_ code: String) {
        let codeLower = code.lowercased()
        guard codeLower != "en" else { return } // Keep English as base
        downloadedModels.remove(codeLower)
        saveDownloadedModels()
    }

    func translate(text: String, from sourceLang: String, to targetLang: String) async -> Result<String, Error> {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .success("") }

        if sourceLang.lowercased() == targetLang.lowercased() {
            return .success(trimmed)
        }

        isTranslating = true
        defer { isTranslating = false }

        // Fast offline dictionary matching for common phrases
        if let direct = OfflineDictionary.lookup(text: trimmed, from: sourceLang, to: targetLang) {
            return .success(direct)
        }

        // Online API fallback (MyMemory API - free, no API key required, highly reliable for general translations)
        do {
            let encodedText = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
            let pair = "\(sourceLang)|\(targetLang)"
            let urlString = "https://api.mymemory.translated.net/get?q=\(encodedText)&langpair=\(pair)"

            if let url = URL(string: urlString) {
                var request = URLRequest(url: url)
                request.timeoutInterval = 5.0
                let (data, response) = try await URLSession.shared.data(for: request)

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let responseData = json["responseData"] as? [String: Any],
                       let translatedText = responseData["translatedText"] as? String,
                       !translatedText.isEmpty {
                        return .success(translatedText)
                    }
                }
            }
        } catch {
            // Fallback to phrase-level generator if network timeout
        }

        // Final offline fallback approximation
        let fallback = OfflineDictionary.translateWords(text: trimmed, from: sourceLang, to: targetLang)
        return .success(fallback)
    }
}

// MARK: - Built-in Offline Dictionary
enum OfflineDictionary {
    private static let phrases: [String: [String: String]] = [
        "hello": [
            "vi": "Xin chào", "en": "Hello", "es": "Hola", "fr": "Bonjour",
            "de": "Hallo", "ja": "こんにちは", "ko": "안녕하세요", "zh": "你好",
            "it": "Ciao", "ru": "Привет", "th": "สวัสดี"
        ],
        "xin chào": [
            "en": "Hello", "es": "Hola", "fr": "Bonjour", "ja": "こんにちは",
            "ko": "안녕하세요", "zh": "你好", "ru": "Привет", "th": "สวัสดี"
        ],
        "thank you": [
            "vi": "Cảm ơn bạn", "en": "Thank you", "es": "Gracias", "fr": "Merci",
            "de": "Danke", "ja": "ありがとうございます", "ko": "감사합니다", "zh": "谢谢",
            "it": "Grazie", "ru": "Спасибо", "th": "ขอบคุณ"
        ],
        "cảm ơn": [
            "en": "Thank you", "es": "Gracias", "fr": "Merci", "ja": "ありがとうございます",
            "ko": "감사합니다", "zh": "谢谢", "ru": "Спасибо"
        ],
        "how are you": [
            "vi": "Bạn khỏe không?", "en": "How are you?", "es": "¿Cómo estás?", "fr": "Comment allez-vous?",
            "de": "Wie geht es dir?", "ja": "お元気ですか？", "ko": "어떻게 지내세요?", "zh": "你好吗？"
        ],
        "bạn khỏe không": [
            "en": "How are you?", "es": "¿Cómo estás?", "fr": "Comment allez-vous?",
            "ja": "お元気ですか？", "ko": "잘 지내세요?", "zh": "你好吗？"
        ],
        "goodbye": [
            "vi": "Tạm biệt", "en": "Goodbye", "es": "Adiós", "fr": "Au revoir",
            "de": "Auf Wiedersehen", "ja": "さようなら", "ko": "안녕히 가세요", "zh": "再见"
        ],
        "tạm biệt": [
            "en": "Goodbye", "es": "Adiós", "fr": "Au revoir", "ja": "さようなら",
            "ko": "안녕히 계세요", "zh": "再见"
        ],
        "where is the bathroom": [
            "vi": "Nhà vệ sinh ở đâu?", "en": "Where is the bathroom?", "es": "¿Dónde está el baño?",
            "fr": "Où sont les toilettes?", "ja": "トイレはどこですか？", "zh": "洗手间在哪里？"
        ],
        "nhà vệ sinh ở đâu": [
            "en": "Where is the bathroom?", "es": "¿Dónde está el baño?", "fr": "Où sont les toilettes?",
            "ja": "トイレはどこですか？", "zh": "洗手间在哪里？"
        ],
        "how much is this": [
            "vi": "Cái này giá bao nhiêu?", "en": "How much is this?", "es": "¿Cuánto cuesta esto?",
            "fr": "Combien ça coûte?", "ja": "これはいくらですか？", "zh": "这个多少钱？"
        ],
        "cái này bao nhiêu tiền": [
            "en": "How much is this?", "es": "¿Cuánto cuesta esto?", "fr": "Combien ça coûte?",
            "ja": "これはいくらですか？", "zh": "这个多少钱？"
        ]
    ]

    static func lookup(text: String, from: String, to: String) -> String? {
        let key = text.lowercased().trimmingCharacters(in: .punctuationCharacters)
        if let translations = phrases[key], let target = translations[to.lowercased()] {
            return target
        }
        return nil
    }

    static func translateWords(text: String, from: String, to: String) -> String {
        let words = text.components(separatedBy: .whitespaces)
        var translated: [String] = []
        for word in words {
            let clean = word.lowercased().trimmingCharacters(in: .punctuationCharacters)
            if let direct = phrases[clean]?[to.lowercased()] {
                translated.append(direct)
            } else {
                translated.append(word)
            }
        }
        return translated.joined(separator: " ")
    }
}
