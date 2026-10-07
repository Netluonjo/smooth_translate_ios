import Foundation

struct LanguageItem: Identifiable, Hashable, Codable {
    var id: String { code }
    let code: String
    let name: String
    let nativeName: String
    let flagEmoji: String
    var isDownloaded: BooleanState = .idle
    var isDownloading: Bool = false
    var downloadProgress: Double = 0.0

    enum BooleanState: Codable {
        case downloaded
        case idle
    }

    var localeIdentifier: String {
        switch code.lowercased() {
        case "en": return "en_US"
        case "vi": return "vi_VN"
        case "es": return "es_ES"
        case "fr": return "fr_FR"
        case "de": return "de_DE"
        case "ja": return "ja_JP"
        case "ko": return "ko_KR"
        case "zh": return "zh_CN"
        case "it": return "it_IT"
        case "pt": return "pt_PT"
        case "ru": return "ru_RU"
        case "ar": return "ar_SA"
        case "hi": return "hi_IN"
        case "id": return "id_ID"
        case "th": return "th_TH"
        case "tr": return "tr_TR"
        case "pl": return "pl_PL"
        case "nl": return "nl_NL"
        case "sv": return "sv_SE"
        case "el": return "el_GR"
        case "cs": return "cs_CZ"
        case "da": return "da_DK"
        case "fi": return "fi_FI"
        case "no": return "nb_NO"
        case "uk": return "uk_UA"
        case "he": return "he_IL"
        case "hu": return "hu_HU"
        case "ro": return "ro_RO"
        case "sk": return "sk_SK"
        case "ca": return "ca_ES"
        case "hr": return "hr_HR"
        case "ms": return "ms_MY"
        case "tl": return "fil_PH"
        case "bn": return "bn_BD"
        case "ur": return "ur_PK"
        case "fa": return "fa_IR"
        default: return code
        }
    }
}

enum LanguageCatalog {
    static let allLanguages: [LanguageItem] = [
        LanguageItem(code: "en", name: "English", nativeName: "English", flagEmoji: "🇺🇸", isDownloaded: .downloaded),
        LanguageItem(code: "vi", name: "Vietnamese", nativeName: "Tiếng Việt", flagEmoji: "🇻🇳", isDownloaded: .downloaded),
        LanguageItem(code: "es", name: "Spanish", nativeName: "Español", flagEmoji: "🇪🇸"),
        LanguageItem(code: "fr", name: "French", nativeName: "Français", flagEmoji: "🇫🇷"),
        LanguageItem(code: "de", name: "German", nativeName: "Deutsch", flagEmoji: "🇩🇪"),
        LanguageItem(code: "ja", name: "Japanese", nativeName: "日本語", flagEmoji: "🇯🇵"),
        LanguageItem(code: "ko", name: "Korean", nativeName: "한국어", flagEmoji: "🇰🇷"),
        LanguageItem(code: "zh", name: "Chinese", nativeName: "中文", flagEmoji: "🇨🇳"),
        LanguageItem(code: "it", name: "Italian", nativeName: "Italiano", flagEmoji: "🇮🇹"),
        LanguageItem(code: "pt", name: "Portuguese", nativeName: "Português", flagEmoji: "🇵🇹"),
        LanguageItem(code: "ru", name: "Russian", nativeName: "Русский", flagEmoji: "🇷🇺"),
        LanguageItem(code: "ar", name: "Arabic", nativeName: "العربية", flagEmoji: "🇸🇦"),
        LanguageItem(code: "hi", name: "Hindi", nativeName: "हिन्दी", flagEmoji: "🇮🇳"),
        LanguageItem(code: "id", name: "Indonesian", nativeName: "Bahasa Indonesia", flagEmoji: "🇮🇩"),
        LanguageItem(code: "th", name: "Thai", nativeName: "ไทย", flagEmoji: "🇹🇭"),
        LanguageItem(code: "tr", name: "Turkish", nativeName: "Türkçe", flagEmoji: "🇹🇷"),
        LanguageItem(code: "pl", name: "Polish", nativeName: "Polski", flagEmoji: "🇵🇱"),
        LanguageItem(code: "nl", name: "Dutch", nativeName: "Nederlands", flagEmoji: "🇳🇱"),
        LanguageItem(code: "sv", name: "Swedish", nativeName: "Svenska", flagEmoji: "🇸🇪"),
        LanguageItem(code: "el", name: "Greek", nativeName: "Ελληνικά", flagEmoji: "🇬🇷"),
        LanguageItem(code: "cs", name: "Czech", nativeName: "Čeština", flagEmoji: "🇨🇿"),
        LanguageItem(code: "da", name: "Danish", nativeName: "Dansk", flagEmoji: "🇩🇰"),
        LanguageItem(code: "fi", name: "Finnish", nativeName: "Suomi", flagEmoji: "🇫🇮"),
        LanguageItem(code: "no", name: "Norwegian", nativeName: "Norsk", flagEmoji: "🇳🇴"),
        LanguageItem(code: "uk", name: "Ukrainian", nativeName: "Українська", flagEmoji: "🇺🇦"),
        LanguageItem(code: "he", name: "Hebrew", nativeName: "עברית", flagEmoji: "🇮🇱"),
        LanguageItem(code: "hu", name: "Hungarian", nativeName: "Magyar", flagEmoji: "🇭🇺"),
        LanguageItem(code: "ro", name: "Romanian", nativeName: "Română", flagEmoji: "🇷🇴"),
        LanguageItem(code: "sk", name: "Slovak", nativeName: "Slovenčina", flagEmoji: "🇸🇰"),
        LanguageItem(code: "ca", name: "Catalan", nativeName: "Català", flagEmoji: "🇦🇩"),
        LanguageItem(code: "hr", name: "Croatian", nativeName: "Hrvatski", flagEmoji: "🇭🇷"),
        LanguageItem(code: "ms", name: "Malay", nativeName: "Bahasa Melayu", flagEmoji: "🇲🇾"),
        LanguageItem(code: "tl", name: "Tagalog", nativeName: "Filipino", flagEmoji: "🇵🇭"),
        LanguageItem(code: "bn", name: "Bengali", nativeName: "বাংলা", flagEmoji: "🇧🇩"),
        LanguageItem(code: "ur", name: "Urdu", nativeName: "اردو", flagEmoji: "🇵🇰"),
        LanguageItem(code: "fa", name: "Persian", nativeName: "فارسی", flagEmoji: "🇮🇷")
    ]

    static let defaultSource = allLanguages[0] // English
    static let defaultTarget = allLanguages[1] // Vietnamese

    static func getByCode(_ code: String) -> LanguageItem {
        allLanguages.first { $0.code.lowercased() == code.lowercased() }
            ?? LanguageItem(code: code, name: code.uppercased(), nativeName: code.uppercased(), flagEmoji: "🌐")
    }
}
