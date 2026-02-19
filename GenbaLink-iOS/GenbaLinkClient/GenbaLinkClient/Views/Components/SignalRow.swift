import SwiftUI
import Combine

struct SignalRow: View {
    let signal: DemandSignal
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(signal.rawInput)
                .font(.headline)
            HStack {
                Text(signal.extractedCategory)
                Text("•")
                Text(signal.extractedColor)
                Text("•")
                Text(signal.extractedSize)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}
