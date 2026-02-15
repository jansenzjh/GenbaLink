import SwiftUI
import SwiftData

struct CaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var llmService: LLMService
    
    @FocusState private var isInputFocused: Bool
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var input: String = ""
    @State private var extractedCategory: String = ""
    @State private var extractedColor: String = ""
    @State private var extractedSize: String = ""
    @State private var isAnalyzing: Bool = false
    @State private var showingAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Language Selection")) {
                    Picker("Recognition Language", selection: $speechRecognizer.localeIdentifier) {
                        Text("English").tag("en-US")
                        Text("Japanese").tag("ja-JP")
                        Text("Chinese").tag("zh-CN")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("Store Feedback")) {
                    TextField("Tap to edit or hold button to speak...", text: $input, axis: .vertical)
                        .lineLimit(3...6)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .focused($isInputFocused)
                    
                    VStack {
                        Button(action: {}) {
                            Image(systemName: speechRecognizer.isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .foregroundColor(speechRecognizer.isRecording ? .red : .blue)
                        }
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if !speechRecognizer.isRecording {
                                        isInputFocused = false
                                        speechRecognizer.startTranscribing()
                                    }
                                }
                                .onEnded { _ in
                                    speechRecognizer.stopTranscribing()
                                }
                        )
                        
                        Text(speechRecognizer.isRecording ? "Release to convert" : "Hold to record")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                    
                    Button(action: analyze) {
                        if llmService.isLoading {
                            ProgressView()
                        } else {
                            Text("Analyze with AI")
                        }
                    }
                    .disabled(input.isEmpty || llmService.isLoading || !llmService.modelLoaded)
                }
                
                if !extractedCategory.isEmpty {
                    Section(header: Text("Extracted Attributes")) {
                        HStack {
                            Text("Category")
                            Spacer()
                            TextField("Category", text: $extractedCategory)
                                .multilineTextAlignment(.trailing)
                                .focused($isInputFocused)
                        }
                        HStack {
                            Text("Color")
                            Spacer()
                            TextField("Color", text: $extractedColor)
                                .multilineTextAlignment(.trailing)
                                .focused($isInputFocused)
                        }
                        HStack {
                            Text("Size")
                            Spacer()
                            TextField("Size", text: $extractedSize)
                                .multilineTextAlignment(.trailing)
                                .focused($isInputFocused)
                        }
                        
                        Button("Save Signal") {
                            saveSignal()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                Section(header: Text("Model Status")) {
                    Text(llmService.statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if !llmService.modelLoaded {
                        Button("Load Model") {
                            Task {
                                await llmService.loadModel()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Capture Demand")
            .onTapGesture {
                isInputFocused = false
            }
            .alert("Signals Saved", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    resetForm()
                }
            }
            .onChange(of: speechRecognizer.transcript) { oldValue, newValue in
                if !newValue.isEmpty {
                    input = newValue
                }
            }
        }
    }
    
    private func analyze() {
        Task {
            let (category, color, size) = await llmService.extractAttributes(from: input)
            extractedCategory = category
            extractedColor = color
            extractedSize = size
        }
    }
    
    private func saveSignal() {
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
    
    private func resetForm() {
        input = ""
        extractedCategory = ""
        extractedColor = ""
        extractedSize = ""
    }
}
