import SwiftUI
import SwiftData

struct CaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var llmService: LLMService
    @StateObject private var viewModel: CaptureViewModel
    
    @FocusState private var isInputFocused: Bool
    
    init(llmService: LLMService) {
        _viewModel = StateObject(wrappedValue: CaptureViewModel(llmService: llmService))
    }

    var body: some View {
        NavigationStack {
            Form {
                languageSelectionSection
                storeFeedbackSection
                extractedAttributesSection
                modelStatusSection
            }
            .navigationTitle("Capture Demand")
            .scrollDismissesKeyboard(.interactively)
            .alert("Signals Saved", isPresented: $viewModel.showingAlert) {
                Button("OK", role: .cancel) {
                    viewModel.resetForm()
                }
            }
            .onAppear {
                viewModel.setModelContext(modelContext)
            }
        }
    }
    
    private var languageSelectionSection: some View {
        Section(header: Text("Language Selection")) {
            Picker("Recognition Language", selection: $viewModel.speechRecognizer.localeIdentifier) {
                Text("English").tag("en-US")
                Text("Japanese").tag("ja-JP")
                Text("Chinese").tag("zh-CN")
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var storeFeedbackSection: some View {
        Section(header: Text("Store Feedback")) {
            ZStack(alignment: .bottomTrailing) {
                TextField("Tap to edit or hold button to speak...", text: $viewModel.input, axis: .vertical)
                    .lineLimit(3...6)
                    .padding()
                    .padding(.trailing, 32)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .focused($isInputFocused)
                
                if !viewModel.input.isEmpty && !viewModel.isRecording {
                    Button(action: {
                        viewModel.clearInput()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .padding(12)
                    }
                }
            }
            
            MicButton(
                isRecording: viewModel.isRecording,
                onStart: {
                    isInputFocused = false
                    viewModel.startTranscribing()
                },
                onStop: {
                    viewModel.stopTranscribing()
                }
            )
            
            Button(action: {
                Task {
                    await viewModel.analyze()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Analyze with AI")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.input.isEmpty || viewModel.isLoading || !viewModel.modelLoaded)
        }
    }
    
    private var extractedAttributesSection: some View {
        Group {
            if !viewModel.extractedCategory.isEmpty {
                Section(header: Text("Extracted Attributes")) {
                    attributeRow(label: "Category", text: $viewModel.extractedCategory)
                    attributeRow(label: "Color", text: $viewModel.extractedColor)
                    attributeRow(label: "Size", text: $viewModel.extractedSize)
                    
                    Button(action: viewModel.saveSignal) {
                        Text("Save Signal")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
    }
    
    private func attributeRow(label: String, text: Binding<String>) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField(label, text: text)
                .multilineTextAlignment(.trailing)
                .focused($isInputFocused)
        }
    }
    
    private var modelStatusSection: some View {
        Section(header: Text("Model Status")) {
            Text(viewModel.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if !viewModel.modelLoaded {
                Button(action: {
                    Task {
                        await viewModel.loadModel()
                    }
                }) {
                    Text("Load Model (Download AI)")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
