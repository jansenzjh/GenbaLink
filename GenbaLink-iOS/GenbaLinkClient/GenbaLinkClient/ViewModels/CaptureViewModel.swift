import SwiftUI
import SwiftData
import Combine

@MainActor
class CaptureViewModel: ObservableObject {
    @Published var input: String = ""
    @Published var extractedCategory: String = ""
    @Published var extractedColor: String = ""
    @Published var extractedSize: String = ""
    @Published var showingAlert: Bool = false
    
    @Published var speechRecognizer = SpeechRecognizer()
    private let llmService: LLMService
    private var modelContext: ModelContext?
    private var cancellables = Set<AnyCancellable>()
    
    // To track text before the current recording session
    private var baseInput: String = ""
    
    init(llmService: LLMService, modelContext: ModelContext? = nil) {
        self.llmService = llmService
        self.modelContext = modelContext
        
        // 1. Forward updates from speechRecognizer to this ViewModel
        // This ensures UI updates (like the mic icon color/shape) happen immediately
        speechRecognizer.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        // 2. Sync transcript from speech recognizer to input by appending
        speechRecognizer.$transcript
            .receive(on: RunLoop.main)
            .sink { [weak self] newTranscript in
                guard let self = self else { return }
                // We update input whenever a transcript comes in, 
                // as long as it's not empty.
                if !newTranscript.isEmpty {
                    let separator = self.baseInput.isEmpty ? "" : " "
                    self.input = self.baseInput + separator + newTranscript
                }
            }
            .store(in: &cancellables)
    }
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    var isRecording: Bool {
        speechRecognizer.isRecording
    }
    
    var isLoading: Bool {
        llmService.isLoading
    }
    
    var modelLoaded: Bool {
        llmService.modelLoaded
    }
    
    var statusMessage: String {
        llmService.statusMessage
    }
    
    func startTranscribing() {
        // Capture current input as base before starting new recording
        baseInput = input
        speechRecognizer.startTranscribing()
    }
    
    func stopTranscribing() {
        speechRecognizer.stopTranscribing()
    }
    
    func analyze() async {
        let (category, color, size) = await llmService.extractAttributes(from: input)
        extractedCategory = category
        extractedColor = color
        extractedSize = size
    }
    
    func saveSignal() {
        guard let modelContext = modelContext else { return }
        
        let signal = DemandSignal(
            rawInput: input,
            category: extractedCategory,
            color: extractedColor,
            size: extractedSize
        )
        modelContext.insert(signal)
        try? modelContext.save()
        showingAlert = true
    }
    
    func resetForm() {
        input = ""
        baseInput = ""
        extractedCategory = ""
        extractedColor = ""
        extractedSize = ""
    }
    
    func clearInput() {
        input = ""
        baseInput = ""
    }
    
    func loadModel() async {
        await llmService.loadModel()
    }
}
