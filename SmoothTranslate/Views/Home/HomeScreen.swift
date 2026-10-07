import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var translationService: TranslationService
    @EnvironmentObject private var historyStore: HistoryStore
    @EnvironmentObject private var ttsService: TtsService

    @State private var showingSettings = false
    @State private var showingOfflineModels = false
    @State private var showingHistory = false

    // Navigation triggers
    @State private var navText = false
    @State private var navPhoto = false
    @State private var navVoice = false
    @State private var navFaceToFace = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header Bar
                    HStack {
                        HStack(spacing: 12) {
                            Image("ic_app_logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 38, height: 38)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)

                            Text("Translate")
                                .font(.system(size: 26, weight: .black))
                                .foregroundColor(AppColors.darkText)
                        }

                        Spacer()

                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(AppColors.darkText)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.top, 8)

                    // Offline Banner
                    Button {
                        showingOfflineModels = true
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.yellowPrimary)
                                    .frame(width: 44, height: 44)
                                Image(systemName: "icloud.and.arrow.down.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(AppColors.darkText)
                            }

                            VStack(alignment: .leading, spacing: 3) {
                                Text("Offline On-Device Engine")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(AppColors.darkText)
                                Text("\(translationService.downloadedModels.count) language pack(s) ready offline")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.subtitleText)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppColors.subtitleText)
                        }
                        .padding(14)
                        .background(AppColors.yellowLight)
                        .cornerRadius(20)
                        .shadow(color: AppColors.yellowDark.opacity(0.12), radius: 6, x: 0, y: 3)
                    }

                    // 2x2 Tool Cards Grid
                    VStack(spacing: 14) {
                        HStack(spacing: 14) {
                            ToolCard(
                                title: "Text",
                                imageName: "ic_tool_text",
                                startColor: AppColors.cardGreenStart,
                                endColor: AppColors.cardGreenEnd
                            ) {
                                navText = true
                            }

                            ToolCard(
                                title: "Photo",
                                imageName: "ic_tool_photo",
                                startColor: AppColors.cardBlueStart,
                                endColor: AppColors.cardBlueEnd
                            ) {
                                navPhoto = true
                            }
                        }

                        HStack(spacing: 14) {
                            ToolCard(
                                title: "Voice",
                                imageName: "ic_tool_voice",
                                startColor: AppColors.cardOrangeStart,
                                endColor: AppColors.cardOrangeEnd
                            ) {
                                navVoice = true
                            }

                            ToolCard(
                                title: "Chat",
                                imageName: "ic_tool_chat",
                                startColor: AppColors.cardPurpleStart,
                                endColor: AppColors.cardPurpleEnd
                            ) {
                                navFaceToFace = true
                            }
                        }
                    }

                    // 100% Free Offline Info Box
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("100% Free Offline Data")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(AppColors.darkText)
                            Spacer()
                            Button("Manage") {
                                showingOfflineModels = true
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppColors.yellowDark)
                        }

                        Text("On-device neural translation engine runs completely offline with zero server requirement. Enjoy unlimited translation, full privacy, and zero data roaming costs.")
                            .font(.system(size: 12))
                            .lineSpacing(4)
                            .foregroundColor(AppColors.subtitleText)
                    }
                    .padding(18)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)

                    // Recent History Section (if available)
                    if !historyStore.records.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Translations")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppColors.darkText)
                                Spacer()
                                Button("See All") {
                                    showingHistory = true
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.blueText)
                            }

                            ForEach(historyStore.records.prefix(3)) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Text(LanguageCatalog.getByCode(item.sourceLang).flagEmoji)
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppColors.subtitleText)
                                            Text(LanguageCatalog.getByCode(item.targetLang).flagEmoji)
                                        }
                                        .font(.system(size: 12))

                                        Text(item.originalText)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.darkText)
                                            .lineLimit(1)

                                        Text(item.translatedText)
                                            .font(.system(size: 13))
                                            .foregroundColor(AppColors.subtitleText)
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Button {
                                        ttsService.speak(text: item.translatedText, langCode: item.targetLang)
                                    } label: {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.system(size: 15))
                                            .foregroundColor(AppColors.blueCapsule)
                                            .padding(8)
                                    }
                                }
                                .padding(12)
                                .background(Color.white)
                                .cornerRadius(14)
                                .shadow(color: Color.black.opacity(0.02), radius: 3, x: 0, y: 1)
                            }
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            .background(AppColors.lightBg.ignoresSafeArea())
            .navigationDestination(isPresented: $navText) {
                TextTranslateView()
            }
            .navigationDestination(isPresented: $navPhoto) {
                PhotoTranslateView()
            }
            .navigationDestination(isPresented: $navVoice) {
                VoiceTranslateView()
            }
            .navigationDestination(isPresented: $navFaceToFace) {
                FaceToFaceView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingOfflineModels) {
                OfflineModelsView()
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView()
            }
        }
    }
}
