import SwiftUI
import SwiftData

struct CaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var llmService: LLMService
    
    @State private var input: String = ""
    @State private var extractedCategory: String = ""
    @State private var extractedColor: String = ""
    @State private var extractedSize: String = ""
    @State private var isAnalyzing: Bool = false
    @State private var showingAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Store Feedback")) {
                    TextField("What did the customer ask for?", text: $input, axis: .vertical)
                        .lineLimit(3...6)
                    
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
                        }
                        HStack {
                            Text("Color")
                            Spacer()
                            TextField("Color", text: $extractedColor)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack {
                            Text("Size")
                            Spacer()
                            TextField("Size", text: $extractedSize)
                                .multilineTextAlignment(.trailing)
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
            .alert("Signals Saved", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    resetForm()
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
