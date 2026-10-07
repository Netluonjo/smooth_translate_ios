import Foundation
import Speech
import AVFoundation

@MainActor
class SpeechRecognizerService: ObservableObject {
    @Published var isListening: Bool = false
    @Published var recognizedText: String = ""
    @Published var audioLevel: Float = 0.0
    @Published var errorMessage: String? = nil

    private var audioEngine = AVAudioEngine()
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            AVAudioSession.sharedInstance().requestRecordPermission { audioAllowed in
                DispatchQueue.main.async {
                    let allowed = (authStatus == .authorized) && audioAllowed
                    completion(allowed)
                }
            }
        }
    }

    func startListening(langCode: String, onResult: @escaping (String) -> Void, onError: @escaping (String) -> Void) {
        stopListening()
        errorMessage = nil

        let localeId = LanguageCatalog.getByCode(langCode).localeIdentifier
        let locale = Locale(identifier: localeId)
        speechRecognizer = SFSpeechRecognizer(locale: locale)

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            let error = "Speech recognizer is not available for \(langCode)"
            self.errorMessage = error
            onError(error)
            return
        }

        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            let error = "Failed to configure audio session: \(error.localizedDescription)"
            self.errorMessage = error
            onError(error)
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            onError("Unable to create recognition request")
            return
        }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)

            // Calculate RMS audio level for waveform visualizer
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameLength = UInt(buffer.frameLength)
            var sum: Float = 0
            for i in 0..<Int(frameLength) {
                sum += channelData[i] * channelData[i]
            }
            let rms = sqrt(sum / Float(frameLength))
            let normalized = min(max(rms * 10.0, 0.0), 1.0)

            DispatchQueue.main.async {
                self?.audioLevel = normalized
            }
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
        } catch {
            let error = "AudioEngine start failed: \(error.localizedDescription)"
            self.errorMessage = error
            onError(error)
            return
        }

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                let text = result.bestTranscription.formattedString
                self.recognizedText = text
                if result.isFinal {
                    onResult(text)
                    self.stopListening()
                }
            }

            if let error = error {
                if self.isListening {
                    self.errorMessage = error.localizedDescription
                    onError(error.localizedDescription)
                    self.stopListening()
                }
            }
        }
    }

    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        isListening = false
        audioLevel = 0.0
    }
}
