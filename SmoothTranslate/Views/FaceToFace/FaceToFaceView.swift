import SwiftUI

struct FaceToFaceView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var translationService: TranslationService
    @EnvironmentObject private var ttsService: TtsService
    @EnvironmentObject private var historyStore: HistoryStore

    @StateObject private var speechRecognizer = SpeechRecognizerService()

    // Person A (Bottom user)
    @State private var userALang: LanguageItem = LanguageCatalog.defaultSource // English
    @State private var userASpoken: String = ""
    @State private var userATranslated: String = ""

    // Person B (Top user, rotated 180 degrees)
    @State private var userBLang: LanguageItem = LanguageCatalog.defaultTarget // Vietnamese
    @State private var userBSpoken: String = ""
    @State private var userBTranslated: String = ""

    @State private var activeSpeaker: ActiveSpeaker? = nil
    @State private var showingPickerA: Bool = false
    @State private var showingPickerB: Bool = false

    enum ActiveSpeaker {
        case userA
        case userB
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - TOP HALF (Person B - Rotated 180°)
            VStack {
                HStack {
                    Button {
                        showingPickerB = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(userBLang.flagEmoji)
                            Text(userBLang.name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.darkText)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppColors.subtitleText)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                    }

                    Spacer()

                    if !userBTranslated.isEmpty {
                        Button {
                            ttsService.speak(text: userBTranslated, langCode: userALang.code)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(AppColors.blueCapsule)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Conversation Box for B
                VStack(alignment: .leading, spacing: 8) {
                    if activeSpeaker == .userB && speechRecognizer.isListening {
                        Text(speechRecognizer.recognizedText.isEmpty ? "Listening to you..." : speechRecognizer.recognizedText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.darkText)
                    } else if !userBSpoken.isEmpty {
                        Text(userBSpoken)
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.subtitleText)
                    }

                    if !userATranslated.isEmpty {
                        Text(userATranslated)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.blueText)
                    } else if userBSpoken.isEmpty && activeSpeaker != .userB {
                        Text("Press the mic button below to speak")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.subtitleText.opacity(0.7))
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)

                // Mic Button for B
                Button {
                    toggleSpeaker(.userB)
                } label: {
                    ZStack {
                        Circle()
                            .fill(activeSpeaker == .userB && speechRecognizer.isListening ? AppColors.destructiveRed : AppColors.cardPurpleEnd)
                            .frame(width: 58, height: 58)
                            .shadow(color: AppColors.cardPurpleEnd.opacity(0.3), radius: 6, x: 0, y: 3)
                        Image(systemName: activeSpeaker == .userB && speechRecognizer.isListening ? "stop.fill" : "mic.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 12)
            }
            .frame(maxHeight: .infinity)
            .background(AppColors.yellowLight.opacity(0.3))
            .rotationEffect(.degrees(180)) // Inverted for the opposing user!

            // MARK: - MIDDLE CONTROL BAR
            HStack(spacing: 20) {
                Button {
                    speechRecognizer.stopListening()
                    ttsService.stop()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppColors.darkText)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                }

                Rectangle()
                    .fill(AppColors.borderGray)
                    .frame(height: 1)

                Button {
                    let temp = userALang
                    userALang = userBLang
                    userBLang = temp
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppColors.blueText)
                        .padding(10)
                        .background(AppColors.blueCapsuleLight.opacity(0.4))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))

            // MARK: - BOTTOM HALF (Person A - Facing Device Owner)
            VStack {
                HStack {
                    Button {
                        showingPickerA = true
                    } label: {
                        HStack(spacing: 6) {
                            Text(userALang.flagEmoji)
                            Text(userALang.name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppColors.darkText)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppColors.subtitleText)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
                    }

                    Spacer()

                    if !userATranslated.isEmpty {
                        Button {
                            ttsService.speak(text: userATranslated, langCode: userBLang.code)
                        } label: {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(AppColors.blueCapsule)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                // Conversation Box for A
                VStack(alignment: .leading, spacing: 8) {
                    if activeSpeaker == .userA && speechRecognizer.isListening {
                        Text(speechRecognizer.recognizedText.isEmpty ? "Listening to you..." : speechRecognizer.recognizedText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.darkText)
                    } else if !userASpoken.isEmpty {
                        Text(userASpoken)
                            .font(.system(size: 15))
                            .foregroundColor(AppColors.subtitleText)
                    }

                    if !userBTranslated.isEmpty {
                        Text(userBTranslated)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(AppColors.blueText)
                    } else if userASpoken.isEmpty && activeSpeaker != .userA {
                        Text("Press the mic button below to speak")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.subtitleText.opacity(0.7))
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)

                // Mic Button for A
                Button {
                    toggleSpeaker(.userA)
                } label: {
                    ZStack {
                        Circle()
                            .fill(activeSpeaker == .userA && speechRecognizer.isListening ? AppColors.destructiveRed : AppColors.cardBlueEnd)
                            .frame(width: 58, height: 58)
                            .shadow(color: AppColors.cardBlueEnd.opacity(0.3), radius: 6, x: 0, y: 3)
                        Image(systemName: activeSpeaker == .userA && speechRecognizer.isListening ? "stop.fill" : "mic.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 12)
            }
            .frame(maxHeight: .infinity)
            .background(AppColors.lightBg)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingPickerA) {
            LanguagePickerSheet(title: "Person A Language", selectedLanguage: userALang) { userALang = $0 }
        }
        .sheet(isPresented: $showingPickerB) {
            LanguagePickerSheet(title: "Person B Language", selectedLanguage: userBLang) { userBLang = $0 }
        }
    }

    private func toggleSpeaker(_ speaker: ActiveSpeaker) {
        if speechRecognizer.isListening && activeSpeaker == speaker {
            speechRecognizer.stopListening()
            if !speechRecognizer.recognizedText.isEmpty {
                handleSpeechFinished(text: speechRecognizer.recognizedText, speaker: speaker)
            }
            activeSpeaker = nil
        } else {
            speechRecognizer.stopListening()
            activeSpeaker = speaker
            let langCode = (speaker == .userA) ? userALang.code : userBLang.code

            speechRecognizer.requestPermissions { allowed in
                guard allowed else { return }
                speechRecognizer.startListening(
                    langCode: langCode,
                    onResult: { text in
                        handleSpeechFinished(text: text, speaker: speaker)
                    },
                    onError: { _ in
                        activeSpeaker = nil
                    }
                )
            }
        }
    }

    private func handleSpeechFinished(text: String, speaker: ActiveSpeaker) {
        activeSpeaker = nil
        if speaker == .userA {
            userASpoken = text
            Task {
                let res = await translationService.translate(text: text, from: userALang.code, to: userBLang.code)
                if case .success(let tr) = res {
                    userATranslated = tr
                    ttsService.speak(text: tr, langCode: userBLang.code)
                }
            }
        } else {
            userBSpoken = text
            Task {
                let res = await translationService.translate(text: text, from: userBLang.code, to: userALang.code)
                if case .success(let tr) = res {
                    userBTranslated = tr
                    ttsService.speak(text: tr, langCode: userALang.code)
                }
            }
        }
    }
}
