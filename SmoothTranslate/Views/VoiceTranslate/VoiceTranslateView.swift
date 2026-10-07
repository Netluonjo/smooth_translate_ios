import SwiftUI

struct VoiceTranslateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var translationService: TranslationService
    @EnvironmentObject private var ttsService: TtsService
    @EnvironmentObject private var historyStore: HistoryStore

    @StateObject private var speechRecognizer = SpeechRecognizerService()

    @State private var sourceLanguage: LanguageItem = LanguageCatalog.defaultSource
    @State private var targetLanguage: LanguageItem = LanguageCatalog.defaultTarget

    @State private var spokenText: String = ""
    @State private var translatedText: String = ""
    @State private var isTranslating: Bool = false
    @State private var isPulsing: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    speechRecognizer.stopListening()
                    ttsService.stop()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(AppColors.darkText)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                }

                Spacer()

                Text("Voice Translate")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.darkText)

                Spacer()

                Circle()
                    .fill(Color.clear)
                    .frame(width: 38, height: 38)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Language Selector Bar
                    LanguageCapsuleBar(
                        sourceLanguage: $sourceLanguage,
                        targetLanguage: $targetLanguage
                    )

                    // Spoken Transcript Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(sourceLanguage.name)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppColors.subtitleText)

                            Spacer()

                            if speechRecognizer.isListening {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(AppColors.destructiveRed)
                                        .frame(width: 8, height: 8)
                                    Text("Listening...")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(AppColors.destructiveRed)
                                }
                            }
                        }

                        let displayText = speechRecognizer.isListening
                            ? (!speechRecognizer.recognizedText.isEmpty ? speechRecognizer.recognizedText : "Listening to your voice...")
                            : (!spokenText.isEmpty ? spokenText : "Tap the microphone below and speak naturally")

                        Text(displayText)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(spokenText.isEmpty && !speechRecognizer.isListening ? AppColors.subtitleText.opacity(0.7) : AppColors.darkText)
                            .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
                    }
                    .padding(18)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)

                    // Translated Result Card
                    if !translatedText.isEmpty || isTranslating {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(targetLanguage.name)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppColors.blueText)

                                Spacer()

                                if !translatedText.isEmpty {
                                    Button {
                                        ttsService.speak(text: translatedText, langCode: targetLanguage.code)
                                    } label: {
                                        Image(systemName: ttsService.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                                            .foregroundColor(AppColors.blueCapsule)
                                            .padding(6)
                                    }

                                    Button {
                                        UIPasteboard.general.string = translatedText
                                    } label: {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(AppColors.subtitleText)
                                            .padding(6)
                                    }
                                }
                            }

                            if isTranslating && translatedText.isEmpty {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("Translating...")
                                        .font(.system(size: 14))
                                        .foregroundColor(AppColors.subtitleText)
                                }
                                .padding(.vertical, 10)
                            } else {
                                Text(translatedText)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(AppColors.darkText)
                                    .lineSpacing(4)
                            }
                        }
                        .padding(18)
                        .background(AppColors.yellowLight.opacity(0.6))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.yellowContainer, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }

            // Bottom Voice Area with Soundwave Visualizer & Mic
            VStack(spacing: 16) {
                // Waveform
                SoundwaveVisualizer(
                    isListening: speechRecognizer.isListening,
                    audioLevel: speechRecognizer.audioLevel,
                    barColor: speechRecognizer.isListening ? AppColors.yellowDark : AppColors.subtitleText.opacity(0.4)
                )

                // Large Mic Button
                ZStack {
                    if speechRecognizer.isListening {
                        Circle()
                            .stroke(AppColors.yellowPrimary.opacity(0.4), lineWidth: 4)
                            .frame(width: 96, height: 96)
                            .scaleEffect(isPulsing ? 1.25 : 1.0)
                            .opacity(isPulsing ? 0.0 : 1.0)
                            .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: isPulsing)
                    }

                    Button {
                        toggleListening()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: speechRecognizer.isListening
                                            ? [AppColors.destructiveRed, Color(hex: 0xDC2626)]
                                            : [AppColors.yellowPrimary, AppColors.yellowDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 76, height: 76)
                                .shadow(
                                    color: (speechRecognizer.isListening ? AppColors.destructiveRed : AppColors.yellowDark).opacity(0.4),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )

                            Image(systemName: speechRecognizer.isListening ? "stop.fill" : "mic.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(speechRecognizer.isListening ? .white : AppColors.darkText)
                        }
                    }
                }

                Text(speechRecognizer.isListening ? "Tap to finish listening" : "Tap to Speak")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.subtitleText)
            }
            .padding(.bottom, 24)
            .padding(.top, 10)
        }
        .background(AppColors.lightBg.ignoresSafeArea())
        .navigationBarHidden(true)
        .onDisappear {
            speechRecognizer.stopListening()
            ttsService.stop()
        }
    }

    private func toggleListening() {
        if speechRecognizer.isListening {
            speechRecognizer.stopListening()
            isPulsing = false
            if !speechRecognizer.recognizedText.isEmpty {
                spokenText = speechRecognizer.recognizedText
                translateSpeech(spokenText)
            }
        } else {
            speechRecognizer.requestPermissions { allowed in
                guard allowed else { return }
                spokenText = ""
                translatedText = ""
                isPulsing = true
                speechRecognizer.startListening(
                    langCode: sourceLanguage.code,
                    onResult: { text in
                        spokenText = text
                        translateSpeech(text)
                    },
                    onError: { _ in
                        isPulsing = false
                    }
                )
            }
        }
    }

    private func translateSpeech(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isTranslating = true

        Task {
            let result = await translationService.translate(
                text: text,
                from: sourceLanguage.code,
                to: targetLanguage.code
            )

            isTranslating = false
            switch result {
            case .success(let translated):
                self.translatedText = translated
                historyStore.addRecord(
                    sourceLang: sourceLanguage.code,
                    targetLang: targetLanguage.code,
                    originalText: text,
                    translatedText: translated
                )
                // Auto read out translated speech
                ttsService.speak(text: translated, langCode: targetLanguage.code)
            case .failure(let error):
                self.translatedText = "Error: \(error.localizedDescription)"
            }
        }
    }
}
