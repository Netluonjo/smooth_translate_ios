import SwiftUI
import PhotosUI
import Vision

struct PhotoTranslateView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var translationService: TranslationService
    @EnvironmentObject private var ttsService: TtsService
    @EnvironmentObject private var historyStore: HistoryStore

    @State private var sourceLanguage: LanguageItem = LanguageCatalog.defaultSource
    @State private var targetLanguage: LanguageItem = LanguageCatalog.defaultTarget

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var recognizedText: String = ""
    @State private var translatedText: String = ""
    @State private var isProcessing: Bool = false
    @State private var statusMessage: String = "Select an image or capture a photo to translate"

    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
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

                Text("Photo Translate")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.darkText)

                Spacer()

                // Balance layout
                Circle()
                    .fill(Color.clear)
                    .frame(width: 38, height: 38)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Language Selector
                    LanguageCapsuleBar(
                        sourceLanguage: $sourceLanguage,
                        targetLanguage: $targetLanguage
                    )

                    // Image Display Area
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white)
                            .frame(height: 320)
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)

                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .cornerRadius(16)
                                .padding(10)
                        } else {
                            VStack(spacing: 14) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 54))
                                    .foregroundColor(AppColors.blueCapsule)

                                Text(statusMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(AppColors.subtitleText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                        }

                        if isProcessing {
                            ZStack {
                                Color.black.opacity(0.4)
                                    .cornerRadius(24)
                                VStack(spacing: 10) {
                                    ProgressView()
                                        .tint(.white)
                                        .scaleEffect(1.2)
                                    Text("Scanning & Translating...")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }

                    // Photo Picker & Action Controls
                    HStack(spacing: 14) {
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("Choose Photo")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(AppColors.darkText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        }

                        Button {
                            loadSampleImageForDemo()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                Text("Sample OCR")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.blueCapsule)
                            .cornerRadius(16)
                            .shadow(color: AppColors.blueCapsule.opacity(0.3), radius: 6, x: 0, y: 3)
                        }
                    }

                    // Translation Result Overlay Card
                    if !translatedText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Detected Text (\(sourceLanguage.name))")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppColors.subtitleText)
                                Spacer()
                            }

                            Text(recognizedText)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.darkText)
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            Divider()

                            HStack {
                                Text("Translation (\(targetLanguage.name))")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AppColors.blueText)

                                Spacer()

                                Button {
                                    ttsService.speak(text: translatedText, langCode: targetLanguage.code)
                                } label: {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .foregroundColor(AppColors.blueCapsule)
                                        .padding(4)
                                }

                                Button {
                                    UIPasteboard.general.string = translatedText
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundColor(AppColors.subtitleText)
                                        .padding(4)
                                }
                            }

                            Text(translatedText)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.darkText)
                                .lineSpacing(4)
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

                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .background(AppColors.lightBg.ignoresSafeArea())
        .navigationBarHidden(true)
        .onChange(of: selectedPhotoItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                    processImage(uiImage)
                }
            }
        }
    }

    private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        isProcessing = true
        statusMessage = "Analyzing text in image..."

        let request = VNRecognizeTextRequest { request, error in
            defer { isProcessing = false }

            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                statusMessage = "No text found in this image"
                return
            }

            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }

            let fullText = recognizedStrings.joined(separator: "\n")
            DispatchQueue.main.async {
                self.recognizedText = fullText
                if fullText.isEmpty {
                    self.statusMessage = "No readable text detected"
                } else {
                    self.translateRecognizedText(fullText)
                }
            }
        }

        request.recognitionLevel = .accurate
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    private func translateRecognizedText(_ text: String) {
        Task {
            let result = await translationService.translate(
                text: text,
                from: sourceLanguage.code,
                to: targetLanguage.code
            )

            switch result {
            case .success(let translated):
                self.translatedText = translated
                historyStore.addRecord(
                    sourceLang: sourceLanguage.code,
                    targetLang: targetLanguage.code,
                    originalText: text,
                    translatedText: translated
                )
            case .failure(let error):
                self.translatedText = "Translation error: \(error.localizedDescription)"
            }
        }
    }

    private func loadSampleImageForDemo() {
        // Create demo banner image with text
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 260))
        let img = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 400, height: 260))

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 22),
                .foregroundColor: UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0)
            ]
            let string = "Welcome to Smooth Translate!\nEnjoy fast and accurate on-device translation.\nHave a wonderful journey."
            (string as NSString).draw(in: CGRect(x: 20, y: 40, width: 360, height: 200), withAttributes: attrs)
        }

        selectedImage = img
        processImage(img)
    }
}
