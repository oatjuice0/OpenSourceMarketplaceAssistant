import Foundation

class ListingStore: ObservableObject {
    @Published var listings: [Listing] = []

    private let fileManager = FileManager.default

    private var storageDirectory: URL {
        let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("SavedListings", isDirectory: true)
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    init() {
        loadListings()
    }

    func save(_ listing: Listing) {
        if let index = listings.firstIndex(where: { $0.id == listing.id }) {
            var updated = listing
            updated.updatedAt = Date()
            listings[index] = updated
            persistListing(updated)
        } else {
            listings.insert(listing, at: 0)
            persistListing(listing)
        }
    }

    func delete(_ listing: Listing) {
        listings.removeAll { $0.id == listing.id }
        let metaURL = storageDirectory.appendingPathComponent("\(listing.id).json")
        let photoURL = storageDirectory.appendingPathComponent("\(listing.id).jpg")
        try? fileManager.removeItem(at: metaURL)
        try? fileManager.removeItem(at: photoURL)
    }

    // MARK: - Private

    private func persistListing(_ listing: Listing) {
        // Save photo as separate file to keep JSON small
        let photoURL = storageDirectory.appendingPathComponent("\(listing.id).jpg")
        try? listing.photoData.write(to: photoURL)

        var meta = listing
        meta.photoData = Data()
        let metaURL = storageDirectory.appendingPathComponent("\(listing.id).json")
        if let data = try? JSONEncoder().encode(meta) {
            try? data.write(to: metaURL)
        }
    }

    private func loadListings() {
        guard let files = try? fileManager.contentsOfDirectory(
            at: storageDirectory,
            includingPropertiesForKeys: nil
        ) else { return }

        let jsonFiles = files.filter { $0.pathExtension == "json" }
        var loaded: [Listing] = []

        for file in jsonFiles {
            guard let data = try? Data(contentsOf: file),
                  var listing = try? JSONDecoder().decode(Listing.self, from: data) else { continue }

            let photoURL = storageDirectory.appendingPathComponent("\(listing.id).jpg")
            if let photo = try? Data(contentsOf: photoURL) {
                listing.photoData = photo
            }
            loaded.append(listing)
        }

        listings = loaded.sorted { $0.createdAt > $1.createdAt }
    }
}
