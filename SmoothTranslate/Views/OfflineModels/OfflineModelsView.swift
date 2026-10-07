import SwiftUI

struct OfflineModelsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var translationService: TranslationService

    @State private var searchQuery: String = ""

    var filteredLanguages: [LanguageItem] {
        if searchQuery.isEmpty {
            return LanguageCatalog.allLanguages
        } else {
            return LanguageCatalog.allLanguages.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.nativeName.localizedCaseInsensitiveContains(searchQuery) ||
                $0.code.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }

    var totalStorageMB: Int {
        translationService.downloadedModels.count * 30
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Storage Overview Card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("On-Device Offline Engine")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppColors.darkText)
                            Text("Fast, private & operates without cellular data")
                                .font(.system(size: 12))
                                .foregroundColor(AppColors.subtitleText)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(totalStorageMB) MB")
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundColor(AppColors.blueText)
                            Text("\(translationService.downloadedModels.count) installed")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(AppColors.subtitleText)
                        }
                    }

                    ProgressView(value: Double(translationService.downloadedModels.count), total: 50.0)
                        .tint(AppColors.yellowDark)
                }
                .padding(16)
                .background(AppColors.yellowLight.opacity(0.8))
                .cornerRadius(18)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.subtitleText)
                    TextField("Search offline language packages...", text: $searchQuery)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    if !searchQuery.isEmpty {
                        Button {
                            searchQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.subtitleText)
                        }
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                // Language Packages List
                List {
                    ForEach(filteredLanguages) { lang in
                        let isDownloaded = translationService.isModelDownloaded(lang.code)
                        let isDownloading = translationService.downloadingModels.contains(lang.code)

                        HStack(spacing: 14) {
                            Text(lang.flagEmoji)
                                .font(.system(size: 26))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(lang.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.darkText)
                                Text(lang.nativeName)
                                    .font(.system(size: 13))
                                    .foregroundColor(AppColors.subtitleText)
                            }

                            Spacer()

                            if isDownloading {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Downloading...")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.subtitleText)
                                }
                            } else if isDownloaded {
                                HStack(spacing: 10) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 13))
                                        Text("Ready")
                                            .font(.system(size: 12, weight: .bold))
                                    }
                                    .foregroundColor(AppColors.successGreen)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppColors.successGreen.opacity(0.12))
                                    .cornerRadius(10)

                                    if lang.code != "en" { // English is default
                                        Button {
                                            translationService.deleteModel(lang.code)
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 14))
                                                .foregroundColor(AppColors.destructiveRed)
                                                .padding(6)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                            } else {
                                Button {
                                    Task {
                                        await translationService.downloadModel(lang.code)
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "icloud.and.arrow.down")
                                            .font(.system(size: 14))
                                        Text("30 MB")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundColor(AppColors.blueText)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(AppColors.blueCapsuleLight.opacity(0.35))
                                    .cornerRadius(12)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Offline Models")
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
        }
    }
}
