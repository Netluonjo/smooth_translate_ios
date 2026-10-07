import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var historyStore: HistoryStore

    @AppStorage("auto_play_voice") private var autoPlayVoice: Bool = true
    @AppStorage("wifi_only_download") private var wifiOnlyDownload: Bool = true
    @AppStorage("haptic_feedback") private var hapticFeedback: Bool = true

    @State private var showingHistory: Bool = false
    @State private var showingOfflineModels: Bool = false
    @State private var showClearHistoryAlert: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Translation Preferences")) {
                    Toggle(isOn: $autoPlayVoice) {
                        HStack(spacing: 12) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(AppColors.blueCapsule)
                            Text("Auto-play voice translation")
                        }
                    }

                    Toggle(isOn: $wifiOnlyDownload) {
                        HStack(spacing: 12) {
                            Image(systemName: "wifi")
                                .foregroundColor(AppColors.cardGreenEnd)
                            Text("Download models over Wi-Fi only")
                        }
                    }

                    Toggle(isOn: $hapticFeedback) {
                        HStack(spacing: 12) {
                            Image(systemName: "iphone.radiowaves.left.and.right")
                                .foregroundColor(AppColors.cardOrangeEnd)
                            Text("Haptic feedback on tap")
                        }
                    }
                }

                Section(header: Text("Data & Storage")) {
                    Button {
                        showingOfflineModels = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "icloud.and.arrow.down.fill")
                                .foregroundColor(AppColors.yellowDark)
                            Text("Offline Language Models")
                                .foregroundColor(AppColors.darkText)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.subtitleText)
                        }
                    }

                    Button {
                        showingHistory = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(AppColors.cardPurpleEnd)
                            Text("Translation History")
                                .foregroundColor(AppColors.darkText)
                            Spacer()
                            Text("\(historyStore.records.count)")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.subtitleText)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.subtitleText)
                        }
                    }

                    Button(role: .destructive) {
                        showClearHistoryAlert = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "trash")
                                .foregroundColor(AppColors.destructiveRed)
                            Text("Clear All History")
                                .foregroundColor(AppColors.destructiveRed)
                        }
                    }
                }

                Section(header: Text("About Smooth Translate")) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Smooth Translate iOS")
                            .foregroundColor(AppColors.subtitleText)
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundColor(AppColors.subtitleText)
                    }

                    HStack {
                        Text("Engine")
                        Spacer()
                        Text("On-Device Vision & Speech")
                            .foregroundColor(AppColors.subtitleText)
                    }

                    HStack {
                        Text("Privacy")
                        Spacer()
                        Text("100% Offline & Private")
                            .foregroundColor(AppColors.successGreen)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.darkText)
                    .fontWeight(.semibold)
                }
            }
            .alert("Clear Translation History?", isPresented: $showClearHistoryAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    historyStore.clearAll()
                }
            } message: {
                Text("This action will remove all saved translations from your device.")
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
