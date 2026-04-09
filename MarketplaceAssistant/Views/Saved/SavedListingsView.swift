import SwiftUI

struct SavedListingsView: View {
    @EnvironmentObject var listingStore: ListingStore

    var body: some View {
        NavigationStack {
            Group {
                if listingStore.listings.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No saved listings yet.")
                            .font(.headline)
                        Text("Generate your first one!")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(listingStore.listings) { listing in
                            NavigationLink(destination: ItemDetailView(listing: listing)) {
                                SavedListingRow(listing: listing)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                listingStore.delete(listingStore.listings[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Saved")
        }
    }
}
