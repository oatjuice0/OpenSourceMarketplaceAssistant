import SwiftUI

struct ScanCounterBadge: View {
    let remaining: Int

    var body: some View {
        Text("⚡ \(remaining) of 10 scans remaining today")
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
    }
}
