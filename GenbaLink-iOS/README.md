# GenbaLink iOS Client

An "Invisible Demand" capture tool powered by on-device MLX AI (Qwen2.5-3B-Instruct).

## Prerequisites
- Xcode 15+
- iOS 17+ (Simulator or Device)
- Device with A-series or M-series chip (for smooth MLX inference)

## Setup
1. Open `GenbaLinkClient/GenbaLinkClient.xcodeproj` in Xcode.
2. Ensure Swift Packages are resolved:
   - `mlx-swift` (https://github.com/ml-explore/mlx-swift)
3. Select a destination (Simulator or iPhone).
4. Build and Run (Cmd+R).

## Features

### 1. Capture (Store Floor)
- Identify customer requests.
- **"Analyze with AI"**: Uses local MLX model to extract JSON attributes (Category, Color, Size).
- Save locally via SwiftData.

### 2. Dashboard (Manager)
- Review captured signals.
- **"Sync to Corporate"**: Pushes batched signals to the backend API (`http://localhost:5045`).

## Architecture
- **Views**: SwiftUI (CaptureView, DashboardView)
- **Services**:
  - `LLMService`: Handles MLX model loading and inference.
  - `NetworkService`: Handles JSON batch sync.
- **Models**: `DemandSignal` (SwiftData entity).
