import SwiftUI

struct ToolCard: View {
    let title: String
    let imageName: String
    let startColor: Color
    let endColor: Color
    let action: () -> Void

    @State private var isPressed: Bool = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(imageName)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .padding(10)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer(minLength: 4)

                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 140, alignment: .topLeading)
            .background(
                LinearGradient(
                    colors: [startColor, endColor],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(24)
            .shadow(color: endColor.opacity(0.35), radius: 8, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        ._onButtonGesture { pressing in
            isPressed = pressing
        } perform: {}
    }
}
