import Foundation
import UIKit

@MainActor
class ItemDetailViewModel: ObservableObject {
    @Published var listing: Listing
    @Published var editingField: EditField?
    @Published var editTitle: String = ""
    @Published var editPrice: String = ""
    @Published var editDescription: String = ""
    @Published var showCopiedToast = false

    enum EditField {
        case title, price, description
    }

    init(listing: Listing) {
        self.listing = listing
    }

    func startEditing(_ field: EditField) {
        editingField = field
        switch field {
        case .title: editTitle = listing.title
        case .price: editPrice = "\(listing.price)"
        case .description: editDescription = listing.description
        }
    }

    func confirmEdit() {
        guard let field = editingField else { return }
        switch field {
        case .title: listing.title = editTitle
        case .price: listing.price = Int(editPrice) ?? listing.price
        case .description: listing.description = editDescription
        }
        listing.updatedAt = Date()
        editingField = nil
    }

    func cancelEdit() {
        editingField = nil
    }

    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        showCopiedToast = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            showCopiedToast = false
        }
    }

    func copyAll() {
        let text = """
        \(listing.title)
        $\(listing.price)

        \(listing.description)
        """
        copyToClipboard(text)
    }

    var photoImage: UIImage? {
        UIImage(data: listing.photoData)
    }
}
