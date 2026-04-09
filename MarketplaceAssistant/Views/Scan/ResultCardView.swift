import SwiftUI

struct ResultCardView: View {
    let label: String
    let content: String
    let onCopy: () -> Void
    var onEdit: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)

                Spacer()

                if let onEdit {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .foregroundColor(.accentPurple)
                    }
                }

                Button(action: onCopy) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.accentPurple)
                }
            }

            Text(content)
                .font(label == "TITLE" ? .headline : .body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}
