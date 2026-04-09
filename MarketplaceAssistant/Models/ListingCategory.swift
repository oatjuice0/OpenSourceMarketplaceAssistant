import Foundation

enum ListingCategory: String, CaseIterable, Identifiable {
    case electronics = "Electronics"
    case furniture = "Furniture"
    case clothing = "Clothing"
    case sportsOutdoors = "Sports & Outdoors"
    case homeGarden = "Home & Garden"
    case toysGames = "Toys & Games"
    case autoParts = "Auto Parts"
    case books = "Books"
    case musicalInstruments = "Musical Instruments"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .electronics: return "🔌"
        case .furniture: return "🪑"
        case .clothing: return "👕"
        case .sportsOutdoors: return "⚽"
        case .homeGarden: return "🏡"
        case .toysGames: return "🧸"
        case .autoParts: return "🔧"
        case .books: return "📚"
        case .musicalInstruments: return "🎸"
        case .other: return "📦"
        }
    }
}
