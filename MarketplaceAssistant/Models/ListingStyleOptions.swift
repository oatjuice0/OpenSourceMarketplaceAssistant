import Foundation

enum SellingStyle: String, CaseIterable, Identifiable {
    case quickSale = "Quick Sale"
    case friendly = "Friendly"
    case detailed = "Detailed"
    case reseller = "Reseller"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .quickSale: return "⚡"
        case .friendly: return "😊"
        case .detailed: return "📋"
        case .reseller: return "🏠"
        }
    }

    var promptDescription: String {
        switch self {
        case .quickSale: return "brief and urgent"
        case .friendly: return "warm and casual"
        case .detailed: return "thorough and informative"
        case .reseller: return "professional and market-aware"
        }
    }
}

enum PricingStrategy: String, CaseIterable, Identifiable {
    case firm = "Firm"
    case obo = "OBO"
    case quickDeal = "Quick Deal"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .firm: return "💰"
        case .obo: return "🤝"
        case .quickDeal: return "📦"
        }
    }

    var promptDescription: String {
        switch self {
        case .firm: return "fixed price, no negotiation language"
        case .obo: return "\"or best offer\" language"
        case .quickDeal: return "priced to sell fast"
        }
    }
}

enum ConditionDetail: String, CaseIterable, Identifiable {
    case highlightBest = "Highlight Best"
    case balanced = "Balanced"
    case fullDisclosure = "Full Disclosure"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .highlightBest: return "✨"
        case .balanced: return "⚖️"
        case .fullDisclosure: return "🔍"
        }
    }

    var promptDescription: String {
        switch self {
        case .highlightBest: return "emphasize positives"
        case .balanced: return "honest pros and cons"
        case .fullDisclosure: return "transparent about any wear"
        }
    }
}

enum LogisticsOption: String, CaseIterable, Identifiable {
    case pickupOnly = "Pickup Only"
    case willShip = "Will Ship"
    case porchPickup = "Porch Pickup"
    case cashOnly = "Cash Only"
    case eTransferOK = "E-Transfer OK"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .pickupOnly: return "🚗"
        case .willShip: return "📦"
        case .porchPickup: return "🏠"
        case .cashOnly: return "💵"
        case .eTransferOK: return "💳"
        }
    }
}
