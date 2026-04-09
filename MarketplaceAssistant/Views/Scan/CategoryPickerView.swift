import SwiftUI

struct CategoryPickerView: View {
    @Binding var selection: ListingCategory?
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("🏷 Category (optional)")
                        .foregroundColor(.primary)
                    Spacer()
                    if let cat = selection {
                        Text(cat.rawValue)
                            .foregroundColor(.secondary)
                    }
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }

            if isExpanded {
                VStack(spacing: 0) {
                    Button {
                        selection = nil
                        withAnimation { isExpanded = false }
                    } label: {
                        HStack {
                            Text("None")
                            Spacer()
                            if selection == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentPurple)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                    .foregroundColor(.primary)

                    Divider().padding(.horizontal)

                    ForEach(ListingCategory.allCases) { category in
                        Button {
                            selection = category
                            withAnimation { isExpanded = false }
                        } label: {
                            HStack {
                                Text("\(category.icon) \(category.rawValue)")
                                Spacer()
                                if selection == category {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentPurple)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        }
                        .foregroundColor(.primary)

                        if category != ListingCategory.allCases.last {
                            Divider().padding(.horizontal)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .padding(.top, 4)
            }
        }
    }
}
