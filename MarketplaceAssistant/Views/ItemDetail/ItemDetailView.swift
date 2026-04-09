import SwiftUI

struct ItemDetailView: View {
    @StateObject private var viewModel: ItemDetailViewModel
    @EnvironmentObject var listingStore: ListingStore
    @Environment(\.dismiss) var dismiss

    init(listing: Listing) {
        _viewModel = StateObject(wrappedValue: ItemDetailViewModel(listing: listing))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Photo thumbnail
                if let image = viewModel.photoImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                }

                editableSection(
                    label: "TITLE",
                    value: viewModel.listing.title,
                    editValue: $viewModel.editTitle,
                    field: .title,
                    isMultiline: false
                )

                editableSection(
                    label: "PRICE",
                    value: "$\(viewModel.listing.price)",
                    editValue: $viewModel.editPrice,
                    field: .price,
                    isMultiline: false
                )

                editableSection(
                    label: "DESCRIPTION",
                    value: viewModel.listing.description,
                    editValue: $viewModel.editDescription,
                    field: .description,
                    isMultiline: true
                )

                // Copy All
                Button {
                    viewModel.copyAll()
                } label: {
                    Label("Copy All", systemImage: "doc.on.doc")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.bordered)
                .tint(.accentPurple)

                // Save / Update
                Button {
                    listingStore.save(viewModel.listing)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    dismiss()
                } label: {
                    let isUpdate = listingStore.listings.contains { $0.id == viewModel.listing.id }
                    Label(
                        isUpdate ? "Update Listing" : "Save Listing",
                        systemImage: "bookmark.fill"
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentPurple)
            }
            .padding()
        }
        .navigationTitle("Item Detail")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.showCopiedToast {
                ToastView(message: "Copied!")
            }
        }
    }

    @ViewBuilder
    private func editableSection(
        label: String,
        value: String,
        editValue: Binding<String>,
        field: ItemDetailViewModel.EditField,
        isMultiline: Bool
    ) -> some View {
        let isEditing = viewModel.editingField == field

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isEditing ? .accentPurple : .secondary)

                Spacer()

                if isEditing {
                    Button { viewModel.cancelEdit() } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.red)
                    }
                    Button { viewModel.confirmEdit() } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.ctaGreen)
                    }
                } else {
                    Button { viewModel.startEditing(field) } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.accentPurple)
                    }
                    Button { viewModel.copyToClipboard(value) } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.accentPurple)
                    }
                }
            }

            if isEditing {
                if isMultiline {
                    TextEditor(text: editValue)
                        .frame(minHeight: 150)
                        .padding(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentPurple, lineWidth: 2)
                        )
                } else {
                    TextField(label, text: editValue)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(label == "PRICE" ? .numberPad : .default)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.accentPurple, lineWidth: 2)
                        )
                }
            } else {
                Text(value)
                    .font(label == "TITLE" ? .headline : .body)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEditing ? Color.accentPurple : Color(.systemGray4), lineWidth: isEditing ? 2 : 1)
        )
    }
}
