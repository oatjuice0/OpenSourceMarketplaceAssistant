import Foundation

struct Listing: Identifiable, Codable {
    let id: UUID
    var title: String
    var price: Int
    var description: String
    var category: String?
    var photoData: Data
    var sellingStyle: String
    var pricingStrategy: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        price: Int,
        description: String,
        category: String? = nil,
        photoData: Data,
        sellingStyle: String,
        pricingStrategy: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.category = category
        self.photoData = photoData
        self.sellingStyle = sellingStyle
        self.pricingStrategy = pricingStrategy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
