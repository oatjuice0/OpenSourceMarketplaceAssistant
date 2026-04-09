import Foundation
import UIKit

@MainActor
class ScanViewModel: ObservableObject {
    // Photo
    @Published var selectedImage: UIImage?
    @Published var showCamera = false

    // Style options
    @Published var selectedCategory: ListingCategory?
    @Published var sellingStyle: SellingStyle = .detailed
    @Published var pricingStrategy: PricingStrategy = .obo
    @Published var conditionDetail: ConditionDetail = .balanced
    @Published var selectedLogistics: Set<LogisticsOption> = [.pickupOnly]
    @Published var isStyleExpanded = false

    // Generation state
    @Published var isGenerating = false
    @Published var generatedTitle: String?
    @Published var generatedPrice: Int?
    @Published var generatedDescription: String?
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showNoAPIKeyAlert = false

    // Toast
    @Published var showCopiedToast = false

    private let listingService = ListingService()

    var styleDescription: String {
        "\(sellingStyle.rawValue) · \(pricingStrategy.rawValue)"
    }

    var hasResult: Bool {
        generatedTitle != nil
    }

    func removePhoto() {
        selectedImage = nil
        clearResults()
    }

    func clearResults() {
        generatedTitle = nil
        generatedPrice = nil
        generatedDescription = nil
    }

    func generateListing(scanLimiter: ScanLimiter) async {
        guard let image = selectedImage else { return }

        guard SettingsManager.shared.hasAPIKey else {
            showNoAPIKeyAlert = true
            return
        }

        isGenerating = true

        do {
            let response = try await listingService.generateListing(
                image: image,
                category: selectedCategory,
                sellingStyle: sellingStyle,
                pricingStrategy: pricingStrategy,
                conditionDetail: conditionDetail,
                logistics: selectedLogistics
            )

            generatedTitle = response.title
            generatedPrice = response.price
            generatedDescription = response.description
            scanLimiter.consumeScan()

            UINotificationFeedbackGenerator().notificationOccurred(.success)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isGenerating = false
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

    func buildListing(photoData: Data, id: UUID = UUID()) -> Listing {
        Listing(
            id: id,
            title: generatedTitle ?? "",
            price: generatedPrice ?? 0,
            description: generatedDescription ?? "",
            category: selectedCategory?.rawValue,
            photoData: photoData,
            sellingStyle: sellingStyle.rawValue,
            pricingStrategy: pricingStrategy.rawValue
        )
    }
}
