
## Project Name: GenbaLink

**Objective:** A "Genba-First" intelligence system using **.NET 10** and **On-Device MLX (Qwen 2.5)** to capture and aggregate "Invisible Demand."

### Phase 1: The High-Performance Core (.NET 10 / C#)

*Goal: Use the latest .NET 10 features for a high-concurrency aggregation engine.*

1. **Shared Domain Model:** Create `GenbaLink.Shared` using C# 14 features (like potential new record enhancements or interceptors) for the `ProductSku` and `DemandSignal`.
2. **Mock Inventory:** Initialize 50+ SKUs using Fast Retailing’s naming convention.
* *Focus:* High-performance collections (like `FrozenDictionary` introduced in earlier versions) to handle fast SKU lookups.


3. **The Aggregator API:** Build a .NET 10 Minimal API.
* **Logic:** Use the `DemandAggregator` service to buffer signals.
* **New in .NET 10:** Leverage any new performance optimizations for JSON serialization (System.Text.Json) to ensure the "Store-to-Cloud" sync is near-instant.



---

### Phase 2: The MLX Edge Collector (iOS / Swift / MLX)

*Goal: Implement "Silicon-Native" AI that runs 100% offline on the iPhone/iPad.*

1. **Model Loading:** Use **Swift Transformers** to load **Qwen2.5-3B-Instruct** (quantized for mobile).
2. **MLX Inference:** Implement the prompt logic using the **MLX Swift** framework to leverage the Apple Neural Engine (ANE).
* *Prompting:* "Extract SKU attributes (Color, Size, Category) from the following store feedback. Output JSON only."


3. **The "Genba" UI:** A SwiftUI interface focused on speed.
* **Capture View:** Real-time tokenization visualization (shows the AI is working locally).
* **Latency Monitor:** Displays "Tokens per second" to show off the MLX optimization.



---

### Phase 3: Strategic Aggregation & Sync

*Goal: Converting raw "Signals" into "Actions."*

1. **Local Buffer:** Use **SwiftData** to store the parsed JSON signals.
2. **The "Push" Strategy:** The app only syncs with the .NET 10 backend when a "Batch" is ready or an "Urgent" SKU is detected (e.g., a "Lost Sale" on a high-margin item).
3. **Manager Approval Flow:** A simple dashboard in the app to review what the MLX model extracted before sending it to the central server.

---

### Phase 4: Executive Interview Pitch

*Goal: Connecting the tech stack to the business.*

* **The MLX Story:** "By using **MLX Swift**, we achieve data privacy and zero latency. We don't need a GPU cluster in the cloud for every store; we use the hardware already in the associates' pockets."
* **The .NET 10 Story:** "The backend is built on **.NET 10**, designed for high-density container environments to keep infrastructure costs for 3,000+ stores as low as possible."
* **The "Zen-in" Story:** "GenbaLink empowers the floor staff to contribute directly to the global supply chain data pool."

---

## 5-Day "Distraction" Sprint (MLX + .NET 10 Edition)

| Day | Task | Technical Focus |
| --- | --- | --- |
| **1** | **Backend Foundation** | Setup .NET 10 Web API and the `ProductSku` Shared Library. |
| **2** | **MLX Setup** | Integrate **Swift Transformers** and load **Qwen2.5-3B** in the iOS project. |
| **3** | **Extraction Logic** | Fine-tune the prompt to get perfect SKU JSON from the MLX model. |
| **4** | **Aggregation Logic** | Write the C# `DemandAggregator` to handle the batching/threshold rules. |
| **5** | **The Pitch** | Create a "System Design" README and a 1-minute demo video of the local inference. |

