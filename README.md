# Smooth Translate (iOS)

Ứng dụng phiên dịch đa năng cao cấp (All-in-One Translator) chuẩn theo mẫu iOS [Smooth Translate](https://apps.apple.com/us/app/smooth-translate/id6758365838?l=vi), được xây dựng bằng **SwiftUI**, chạy **On-Device / 100% Offline** sử dụng **Apple Vision OCR**, **Apple Speech Recognition** và **AVSpeechSynthesizer (TTS)**.

---

## 🌟 Tính năng nổi bật

### 1. 🟢 Dịch văn bản (Text Translate)
- Bộ chọn ngôn ngữ dạng capsule bo cong chuẩn phong cách iOS hiện đại kèm cờ quốc gia.
- Nút đảo chiều ngôn ngữ thông minh với hiệu ứng xoay 180° mượt mà.
- Thao tác một chạm: Dán nhanh (Paste từ Clipboard), Xoá nhanh (Clear), Đếm ký tự.
- Thẻ kết quả dịch với tính năng phát âm tự nhiên (TTS), sao chép (Copy), chia sẻ (Share) và lưu danh sách yêu thích.

### 2. 🔵 Dịch qua Ảnh & Camera (Photo & Camera Translate)
- Chọn ảnh nhanh từ Thư viện (PhotosUI) hoặc quét tài liệu.
- Nhận diện văn bản quang học (OCR) trực tiếp trên máy bằng **Apple Vision framework (`VNRecognizeTextRequest`)** không cần internet.
- Tự động dịch văn bản được trích xuất sang ngôn ngữ đích kèm thẻ kết quả trực quan.

### 3. 🟠 Dịch giọng nói (Voice Translate)
- Tích hợp **Apple Speech framework (`SFSpeechRecognizer`)** nhận diện giọng nói tức thì.
- Hiệu ứng sóng âm thanh động (**Soundwave Visualizer**) đồng bộ theo biên độ âm thanh thời gian thực.
- Vòng xung lực động (Pulsating rings) quanh nút Micro khi đang lắng nghe.
- Tự động phát âm kết quả dịch qua **`AVSpeechSynthesizer`**.

### 4. 🟣 Dịch đối thoại trực tiếp 2 người (Face-To-Face Chat)
- Thiết kế chia đôi màn hình độc đáo:
  - **Nửa trên xoay ngược 180°** hướng về phía người đối diện để họ đọc và tương tác dễ dàng.
  - **Nửa dưới hướng về phía bạn**.
- Mỗi bên có nút micro và bộ chọn ngôn ngữ độc lập.
- Đàm thoại song ngữ hai chiều liên tục theo thời gian thực kèm giọng đọc phát âm song song.

### 5. 📦 Quản lý gói ngôn ngữ Offline (Offline Models Manager)
- Quản lý gói ngôn ngữ offline cho hơn 50+ ngôn ngữ phổ biến trên thế giới.
- Hiển thị dung lượng lưu trữ trên thiết bị.
- Hỗ trợ tải một chạm và xoá gói bất cứ lúc nào.

### 6. 🕒 Lịch sử & Mục yêu thích (History & Favorites)
- Lưu trữ lịch sử dịch tự động trên máy (UserDefaults / JSON persistence).
- Lọc xem mục yêu thích, tìm kiếm nhanh và phát âm lại.

---

## 🛠 Công nghệ & Kiến trúc

- **Ngôn ngữ**: Swift 5.9+
- **Giao diện**: SwiftUI (iOS 16.0+)
- **Speech-to-Text**: `Speech.framework` (`SFSpeechRecognizer`, `AVAudioEngine`)
- **Text-to-Speech**: `AVFoundation.framework` (`AVSpeechSynthesizer`)
- **OCR / Nhận diện chữ**: `Vision.framework` (`VNRecognizeTextRequest`)
- **Kiến trúc**: MVVM + State Management (`@Published`, `ObservableObject`, `@EnvironmentObject`)

---

## 📁 Cấu trúc thư mục

```
smooth_translate_ios/
├── SmoothTranslate/
│   ├── App/
│   │   ├── SmoothTranslateApp.swift      # Entry point
│   │   └── Info.plist                     # Quyền truy cập Mic, Speech, Camera, Photo
│   ├── Models/
│   │   ├── LanguageItem.swift             # Danh mục 50+ ngôn ngữ, mã BCP-47, cờ emoji
│   │   └── TranslationRecord.swift        # Model lịch sử & mục yêu thích
│   ├── Services/
│   │   ├── TranslationService.swift       # Xử lý dịch thuật & quản lý gói offline
│   │   ├── SpeechRecognizerService.swift  # Thu âm & nhận diện giọng nói
│   │   ├── TtsService.swift               # Phát âm tự nhiên theo chuẩn ngôn ngữ
│   │   └── HistoryStore.swift             # Lưu trữ lịch sử dịch cục bộ
│   ├── Theme/
│   │   └── AppColors.swift                # Bảng màu chuẩn thiết kế gốc
│   ├── Views/
│   │   ├── Components/
│   │   │   ├── LanguageCapsuleBar.swift   # Thanh chọn & đảo ngôn ngữ
│   │   │   ├── LanguagePickerSheet.swift  # Bảng tìm kiếm chọn ngôn ngữ
│   │   │   ├── SoundwaveVisualizer.swift  # Sóng âm thanh động
│   │   │   └── ToolCard.swift             # Thẻ tính năng 2x2 gradient
│   │   ├── Home/
│   │   │   └── HomeScreen.swift           # Màn hình chính
│   │   ├── TextTranslate/
│   │   │   └── TextTranslateView.swift    # Dịch văn bản
│   │   ├── PhotoTranslate/
│   │   │   └── PhotoTranslateView.swift   # Dịch qua ảnh OCR
│   │   ├── VoiceTranslate/
│   │   │   └── VoiceTranslateView.swift   # Dịch giọng nói
│   │   ├── FaceToFace/
│   │   │   └── FaceToFaceView.swift       # Dịch đối thoại xoay 180°
│   │   ├── OfflineModels/
│   │   │   └── OfflineModelsView.swift    # Quản lý model offline
│   │   └── Settings/
│   │       ├── SettingsView.swift         # Cài đặt ứng dụng
│   │       └── HistoryView.swift          # Lịch sử dịch
│   └── Assets.xcassets/                   # Icons & hình ảnh ứng dụng
├── SmoothTranslate.xcodeproj/             # File dự án Xcode
├── Package.swift                          # Swift Package Manager manifest
└── README.md
```

---

## 🚀 Hướng dẫn mở & Chạy dự án

1. Mở file `SmoothTranslate.xcodeproj` bằng **Xcode 15+** trên macOS.
2. Chọn target **SmoothTranslate**.
3. Chọn thiết bị giả lập (Simulator) như **iPhone 15 Pro / iPhone 16** hoặc thiết bị thật.
4. Bấm **⌘ + R (Run)** để build và khởi chạy ứng dụng.
