import Foundation
import AVFoundation

@MainActor
class TtsService: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking: Bool = false

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(text: String, langCode: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Stop any current utterance
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate

        let bcp47 = getBcp47Locale(code: langCode)
        if let voice = AVSpeechSynthesisVoice(language: bcp47) {
            utterance.voice = voice
        } else if let fallbackVoice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = fallbackVoice
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .duckOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session for TTS: \(error)")
        }

        isSpeaking = true
        synthesizer.speak(utterance)
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }

    // MARK: - AVSpeechSynthesizerDelegate
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
        }
    }

    private func getBcp47Locale(code: String) -> String {
        switch code.lowercased() {
        case "en": return "en-US"
        case "vi": return "vi-VN"
        case "es": return "es-ES"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "ja": return "ja-JP"
        case "ko": return "ko-KR"
        case "zh": return "zh-CN"
        case "it": return "it-IT"
        case "pt": return "pt-PT"
        case "ru": return "ru-RU"
        case "ar": return "ar-SA"
        case "hi": return "hi-IN"
        case "id": return "id-ID"
        case "th": return "th-TH"
        case "tr": return "tr-TR"
        case "pl": return "pl-PL"
        case "nl": return "nl-NL"
        case "sv": return "sv-SE"
        case "el": return "el-GR"
        case "cs": return "cs-CZ"
        case "da": return "da-DK"
        case "fi": return "fi-FI"
        case "no": return "nb-NO"
        case "uk": return "uk-UA"
        case "he": return "he-IL"
        case "hu": return "hu-HU"
        case "ro": return "ro-RO"
        case "sk": return "sk-SK"
        case "ca": return "ca-ES"
        case "hr": return "hr-HR"
        case "ms": return "ms-MY"
        case "tl": return "fil-PH"
        case "bn": return "bn-BD"
        case "ur": return "ur-PK"
        case "fa": return "fa-IR"
        default: return code
        }
    }
}
