import SwiftUI

struct SoundwaveVisualizer: View {
    let isListening: Bool
    let audioLevel: Float // 0.0 to 1.0
    let barColor: Color

    @State private var phase: Double = 0.0

    private let barCount = 18

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<barCount, id: \.self) { index in
                let baseHeight: CGFloat = isListening ? calculateBarHeight(index: index) : 6.0
                RoundedRectangle(cornerRadius: 3)
                    .fill(barColor)
                    .frame(width: 4, height: max(6, baseHeight))
                    .animation(
                        .easeInOut(duration: 0.15)
                        .repeatCount(1, autoreverses: true),
                        value: audioLevel
                    )
            }
        }
        .frame(height: 50)
        .onAppear {
            withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }

    private func calculateBarHeight(index: index_type) -> CGFloat {
        typealias index_type = Int
        let normalizedIndex = Double(index) / Double(barCount)
        let sineFactor = sin(normalizedIndex * .pi)
        let waveFactor = sin(Double(index) * 0.8 + phase) * 0.2 + 0.8
        let dynamicHeight = CGFloat(audioLevel) * 44.0 * CGFloat(sineFactor * waveFactor)
        return max(6.0, 10.0 + dynamicHeight)
    }
}
