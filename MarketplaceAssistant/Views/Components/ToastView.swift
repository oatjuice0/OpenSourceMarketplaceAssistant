import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(radius: 4)
                .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: message)
    }
}
