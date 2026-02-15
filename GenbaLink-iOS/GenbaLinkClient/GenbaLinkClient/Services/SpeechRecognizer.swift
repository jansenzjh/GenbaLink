
import Foundation
import Speech
import AVFoundation
import Combine

class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var errorMessage: String?
    @Published var localeIdentifier: String = "en-US"
    
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    break
                case .denied:
                    self.errorMessage = "Speech recognition authorization denied."
                case .restricted:
                    self.errorMessage = "Speech recognition restricted on this device."
                case .notDetermined:
                    self.errorMessage = "Speech recognition not yet authorized."
                @unknown default:
                    self.errorMessage = "Unknown authorization status."
                }
            }
        }
    }
    
    func startTranscribing() {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        guard let speechRecognizer = recognizer, speechRecognizer.isAvailable else {
            self.errorMessage = "Speech recognizer is not available for \(localeIdentifier)."
            return
        }
        
        do {
            try startRecording(with: speechRecognizer)
            isRecording = true
            errorMessage = nil
        } catch {
            self.errorMessage = "Failed to start recording: \(error.localizedDescription)"
        }
    }
    
    func stopTranscribing() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    private func startRecording(with speechRecognizer: SFSpeechRecognizer) throws {
        // Cancel existing task if any
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep correct reference to self in closure
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            var isFinal = false
            
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.isRecording = false
            }
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
}
