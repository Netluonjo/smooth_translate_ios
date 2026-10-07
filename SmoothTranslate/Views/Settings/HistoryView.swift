import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var historyStore: HistoryStore
    @EnvironmentObject private var ttsService: TtsService

    @State private var searchQuery: String = ""
    @State private var filterFavorites: Bool = false

    var filteredRecords: [TranslationRecord] {
        historyStore.records.filter { record in
            let matchesSearch = searchQuery.isEmpty ||
                record.originalText.localizedCaseInsensitiveContains(searchQuery) ||
                record.translatedText.localizedCaseInsensitiveContains(searchQuery)
            let matchesFavorite = !filterFavorites || record.isFavorite
            return matchesSearch && matchesFavorite
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search & Filter
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.subtitleText)
                        TextField("Search history...", text: $searchQuery)
                            .autocorrectionDisabled()
                        if !searchQuery.isEmpty {
                            Button {
                                searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AppColors.subtitleText)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)

                    Picker("Filter", selection: $filterFavorites) {
                        Text("All (\(historyStore.records.count))").tag(false)
                        Text("Favorites (\(historyStore.records.filter { $0.isFavorite }.count))").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

                if filteredRecords.isEmpty {
                    VStack(spacing: 14) {
                        Spacer()
                        Image(systemName: filterFavorites ? "heart.slash" : "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.subtitleText.opacity(0.5))
                        Text(filterFavorites ? "No favorite translations yet" : "No translation history yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.subtitleText)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredRecords) { record in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    HStack(spacing: 6) {
                                        Text(LanguageCatalog.getByCode(record.sourceLang).flagEmoji)
                                        Text(LanguageCatalog.getByCode(record.sourceLang).name)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(AppColors.subtitleText)
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 10))
                                            .foregroundColor(AppColors.subtitleText)
                                        Text(LanguageCatalog.getByCode(record.targetLang).flagEmoji)
                                        Text(LanguageCatalog.getByCode(record.targetLang).name)
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(AppColors.blueText)
                                    }

                                    Spacer()

                                    Button {
                                        historyStore.toggleFavorite(id: record.id)
                                    } label: {
                                        Image(systemName: record.isFavorite ? "heart.fill" : "heart")
                                            .foregroundColor(record.isFavorite ? AppColors.destructiveRed : AppColors.subtitleText)
                                            .font(.system(size: 16))
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }

                                Text(record.originalText)
                                    .font(.system(size: 15))
                                    .foregroundColor(AppColors.darkText)

                                Text(record.translatedText)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(AppColors.blueText)

                                HStack {
                                    Text(record.timestamp, style: .time)
                                        .font(.system(size: 11))
                                        .foregroundColor(AppColors.subtitleText.opacity(0.8))

                                    Spacer()

                                    Button {
                                        ttsService.speak(text: record.translatedText, langCode: record.targetLang)
                                    } label: {
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.blueCapsule)
                                            .padding(4)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())

                                    Button {
                                        UIPasteboard.general.string = record.translatedText
                                    } label: {
                                        Image(systemName: "doc.on.doc")
                                            .font(.system(size: 14))
                                            .foregroundColor(AppColors.subtitleText)
                                            .padding(4)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let item = filteredRecords[index]
                                historyStore.deleteRecord(id: item.id)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("History")
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
