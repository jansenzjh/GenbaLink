import Foundation
import Combine
import MLX
import MLXLLM
import MLXLMCommon
import Hub
import Tokenizers

class LLMService: ObservableObject {
    @Published var modelLoaded = false
    @Published var isLoading = false
    @Published var statusMessage = "Initializing..."
    
    private var modelContext: ModelContext?
    private let repoId = "mlx-community/Qwen2.5-3B-Instruct-4bit"
    
    func loadModel() async {
        if modelLoaded { return }
        
        do {
            let repo = Hub.Repo(id: repoId)
            
            await MainActor.run { self.statusMessage = "Downloading Model..." }
            
            let modelDirectory = try await Hub.snapshot(
                from: repo,
                matching: [
                    "config.json",
                    "*.safetensors",
                    "tokenizer.json",
                    "vocab.json",
                    "merges.txt",
                    "tokenizer_config.json",
                    "special_tokens_map.json",
                    "added_tokens.json",
                    "*.index.json"
                ]
            )
            
            await MainActor.run { self.statusMessage = "Loading weights..." }

            let configuration = ModelConfiguration(directory: modelDirectory)
            let context = try await MLXLMCommon.loadModel(configuration: configuration)
            
            await MainActor.run {
                self.modelContext = context
                self.modelLoaded = true
                self.statusMessage = "Model Ready (Qwen2.5-3B)"
            }
        } catch {
            print("Error loading model: \(error)")
            await MainActor.run { self.statusMessage = "Error: \(error.localizedDescription)" }
        }
    }
    
    func extractAttributes(from input: String) async -> (category: String, color: String, size: String) {
        guard let context = modelContext else { return ("Unknown", "Unknown", "Unknown") }
        
        let systemPrompt = "You are a retail assistant. Extract SKU attributes (Category, Color, Size) from the input. Output JSON only: {\"category\": \"...\", \"color\": \"...\", \"size\": \"...\"}."
        let prompt = "[INST] \(systemPrompt) \n\n Input: \(input) [/INST]"
        
        await MainActor.run { self.isLoading = true }
        
        do {
            // let parameters = GenerateParameters(maxTokens: 100, temperature: 0.1) // Low temp for JSON
            // Generate logic... simplified from reference
            let result = try await context.generateText(prompt: prompt, maxTokens: 100, temperature: 0.1)
            
            await MainActor.run { self.isLoading = false }
            
            // Parse JSON from result
            // This is a naive parser for the demo
            return parseJSON(result)
        } catch {
            print("Inference error: \(error)")
            await MainActor.run { self.isLoading = false }
            return ("Error", "Error", "Error")
        }
    }
    
    private func parseJSON(_ jsonString: String) -> (String, String, String) {
        // Naive parsing logic
        // Find { ... } block
        guard let start = jsonString.firstIndex(of: "{"),
              let end = jsonString.lastIndex(of: "}") else {
            return ("Unknown", "Unknown", "Unknown")
        }
        
        let json = String(jsonString[start...end])
        guard let data = json.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
            return ("Unknown", "Unknown", "Unknown")
        }
        
        return (
            dict["category"] ?? "Unknown",
            dict["color"] ?? "Unknown",
            dict["size"] ?? "Unknown"
        )
    }
}

// Extension to mimic `context.generate` for compilation context if library differs
extension ModelContext {
    func generateText(prompt: String, maxTokens: Int, temperature: Float) async throws -> String {
        let userInput = UserInput(prompt: prompt)
        let input = try await self.processor.prepare(input: userInput)
        let parameters = GenerateParameters(maxTokens: maxTokens, temperature: temperature)
        
        let result = try MLXLMCommon.generate(
            input: input,
            parameters: parameters,
            context: self
        ) { (tokens: [Int]) in
            return .more
        }
        
        return result.output
    }
}
