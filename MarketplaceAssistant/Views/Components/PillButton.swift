import SwiftUI

struct PillButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentPurple.opacity(0.1) : Color(.systemGray6))
                .foregroundColor(isSelected ? .accentPurple : .primary)
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.accentPurple : Color.clear, lineWidth: 1.5)
                )
                .clipShape(Capsule())
        }
    }
}
