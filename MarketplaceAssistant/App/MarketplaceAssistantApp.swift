import SwiftUI

@main
struct MarketplaceAssistantApp: App {
    @StateObject private var scanLimiter = ScanLimiter()
    @StateObject private var listingStore = ListingStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scanLimiter)
                .environmentObject(listingStore)
                .environmentObject(SettingsManager.shared)
        }
    }
}
