import SwiftUI

struct LanguagePickerSheet: View {
    let title: String
    let selectedLanguage: LanguageItem
    let onSelect: (LanguageItem) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var searchQuery: String = ""
    @EnvironmentObject private var translationService: TranslationService

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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.subtitleText)
                    TextField("Search language...", text: $searchQuery)
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
                .padding(.vertical, 10)

                List {
                    ForEach(filteredLanguages) { lang in
                        let isSelected = lang.code == selectedLanguage.code
                        let isDownloaded = translationService.isModelDownloaded(lang.code)

                        Button {
                            onSelect(lang)
                            dismiss()
                        } label: {
                            HStack(spacing: 14) {
                                Text(lang.flagEmoji)
                                    .font(.system(size: 26))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lang.name)
                                        .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? AppColors.blueText : AppColors.darkText)
                                    Text(lang.nativeName)
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColors.subtitleText)
                                }

                                Spacer()

                                if isDownloaded {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.down.circle.fill")
                                            .font(.system(size: 12))
                                        Text("Offline")
                                            .font(.system(size: 11, weight: .semibold))
                                    }
                                    .foregroundColor(AppColors.successGreen)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(AppColors.successGreen.opacity(0.12))
                                    .cornerRadius(12)
                                }

                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppColors.blueCapsule)
                                        .font(.system(size: 20))
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.darkText)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
