import SwiftUI

struct MicButton: View {
    let isRecording: Bool
    let onStart: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80) // Slightly larger hit area
                .foregroundColor(isRecording ? .red : .blue)
                .contentShape(Circle()) // Ensures the whole circle is tappable
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isRecording {
                                onStart()
                            }
                        }
                        .onEnded { _ in
                            if isRecording {
                                onStop()
                            }
                        }
                )
            
            Text(isRecording ? "Release to convert" : "Hold to record")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
}
