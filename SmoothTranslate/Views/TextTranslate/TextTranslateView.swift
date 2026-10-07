import SwiftUI

struct TextTranslateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var translationService: TranslationService
    @EnvironmentObject private var historyStore: HistoryStore
    @EnvironmentObject private var ttsService: TtsService

    @State private var sourceLanguage: LanguageItem = LanguageCatalog.defaultSource
    @State private var targetLanguage: LanguageItem = LanguageCatalog.defaultTarget
    @State private var inputText: String = ""
    @State private var translatedText: String = ""
    @State private var isTranslating: Bool = false
    @State private var showCopiedToast: Bool = false
    @State private var showingHistory: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                Button {
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

                Text("Text Translate")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.darkText)

                Spacer()

                Button {
                    showingHistory = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppColors.darkText)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                }
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

                    // Input Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(sourceLanguage.name)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppColors.subtitleText)

                            Spacer()

                            if !inputText.isEmpty {
                                Button {
                                    inputText = ""
                                    translatedText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppColors.subtitleText)
                                }
                            }
                        }

                        ZStack(alignment: .topLeading) {
                            if inputText.isEmpty {
                                Text("Enter or paste text here to translate...")
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.subtitleText.opacity(0.6))
                                    .padding(.top, 8)
                                    .padding(.leading, 4)
                            }

                            TextEditor(text: $inputText)
                                .font(.system(size: 16))
                                .frame(minHeight: 120)
                                .scrollContentBackground(.hidden)
                        }

                        // Bottom Action Row in Input
                        HStack {
                            Button {
                                if let string = UIPasteboard.general.string {
                                    inputText = string
                                    executeTranslation()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "doc.on.clipboard")
                                    Text("Paste")
                                }
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(AppColors.blueText)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(AppColors.blueCapsuleLight.opacity(0.3))
                                .cornerRadius(8)
                            }

                            Spacer()

                            Text("\(inputText.count) chars")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.subtitleText)

                            Button {
                                executeTranslation()
                            } label: {
                                HStack(spacing: 6) {
                                    if isTranslating {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                    }
                                    Text("Translate")
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppColors.blueCapsule)
                                .cornerRadius(12)
                            }
                            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTranslating)
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)

                    // Translated Result Card
                    if !translatedText.isEmpty || isTranslating {
                        VStack(alignment: .leading, spacing: 14) {
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
                                        withAnimation {
                                            showCopiedToast = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            showCopiedToast = false
                                        }
                                    } label: {
                                        Image(systemName: "doc.on.doc")
                                            .foregroundColor(AppColors.subtitleText)
                                            .padding(6)
                                    }

                                    ShareLink(item: translatedText) {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundColor(AppColors.subtitleText)
                                            .padding(6)
                                    }
                                }
                            }

                            if isTranslating && translatedText.isEmpty {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("Translating offline...")
                                        .font(.system(size: 15))
                                        .foregroundColor(AppColors.subtitleText)
                                }
                                .padding(.vertical, 16)
                            } else {
                                Text(translatedText)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(AppColors.darkText)
                                    .lineSpacing(4)
                                    .frame(maxWidth: .infinity, alignment: .leading)
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
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .background(AppColors.lightBg.ignoresSafeArea())
        .navigationBarHidden(true)
        .overlay(alignment: .bottom) {
            if showCopiedToast {
                Text("Copied to clipboard")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(AppColors.darkText.opacity(0.9))
                    .cornerRadius(20)
                    .padding(.bottom, 30)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
        }
    }

    private func executeTranslation() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isTranslating = true

        Task {
            let result = await translationService.translate(
                text: inputText,
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
                    originalText: inputText,
                    translatedText: translated
                )
            case .failure(let error):
                self.translatedText = "Translation error: \(error.localizedDescription)"
            }
        }
    }
}
