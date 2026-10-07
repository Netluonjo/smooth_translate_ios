import SwiftUI

struct LanguageCapsuleBar: View {
    @Binding var sourceLanguage: LanguageItem
    @Binding var targetLanguage: LanguageItem

    @State private var showingSourcePicker = false
    @State private var showingTargetPicker = false
    @State private var rotationAngle: Double = 0.0

    var body: some View {
        HStack(spacing: 8) {
            // Source Language Capsule
            Button {
                showingSourcePicker = true
            } label: {
                HStack(spacing: 8) {
                    Text(sourceLanguage.flagEmoji)
                        .font(.system(size: 20))
                    Text(sourceLanguage.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.darkText)
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.subtitleText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
            }

            // Swap Button with 180 degree rotation animation
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    rotationAngle += 180.0
                    let temp = sourceLanguage
                    sourceLanguage = targetLanguage
                    targetLanguage = temp
                }
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.blueText)
                    .rotationEffect(.degrees(rotationAngle))
                    .padding(10)
                    .background(AppColors.blueCapsuleLight.opacity(0.4))
                    .clipShape(Circle())
            }

            // Target Language Capsule
            Button {
                showingTargetPicker = true
            } label: {
                HStack(spacing: 8) {
                    Text(targetLanguage.flagEmoji)
                        .font(.system(size: 20))
                    Text(targetLanguage.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.darkText)
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppColors.subtitleText)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.04), radius: 5, x: 0, y: 2)
            }
        }
        .sheet(isPresented: $showingSourcePicker) {
            LanguagePickerSheet(
                title: "Source Language",
                selectedLanguage: sourceLanguage
            ) { selected in
                sourceLanguage = selected
            }
        }
        .sheet(isPresented: $showingTargetPicker) {
            LanguagePickerSheet(
                title: "Target Language",
                selectedLanguage: targetLanguage
            ) { selected in
                targetLanguage = selected
            }
        }
    }
}
