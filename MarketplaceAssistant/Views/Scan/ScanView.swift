import SwiftUI
import PhotosUI

struct ScanView: View {
    @StateObject private var viewModel = ScanViewModel()
    @EnvironmentObject var scanLimiter: ScanLimiter
    @EnvironmentObject var listingStore: ListingStore
    @Binding var selectedTab: Int

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var navigateToDetail = false
    @State private var detailListing: Listing?
    @State private var savedListingId: UUID?

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        ScanCounterBadge(remaining: scanLimiter.scansRemaining)

                        CategoryPickerView(selection: $viewModel.selectedCategory)

                        ListingStyleSection(
                            sellingStyle: $viewModel.sellingStyle,
                            pricingStrategy: $viewModel.pricingStrategy,
                            conditionDetail: $viewModel.conditionDetail,
                            selectedLogistics: $viewModel.selectedLogistics,
                            isExpanded: $viewModel.isStyleExpanded,
                            styleDescription: viewModel.styleDescription
                        )

                        PhotoAreaView(image: viewModel.selectedImage) {
                            viewModel.removePhoto()
                            savedListingId = nil
                        }

                        // Camera & Library buttons
                        HStack(spacing: 12) {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                Button {
                                    viewModel.showCamera = true
                                } label: {
                                    Label("Camera", systemImage: "camera")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.accentPurple)
                            }

                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Label("Library", systemImage: "photo")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentPurple)
                        }

                        // Generate button
                        Button {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            Task {
                                await viewModel.generateListing(scanLimiter: scanLimiter)
                                savedListingId = nil
                                if viewModel.hasResult {
                                    try? await Task.sleep(nanoseconds: 100_000_000)
                                    withAnimation {
                                        proxy.scrollTo("results", anchor: .top)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                if viewModel.isGenerating {
                                    ProgressView()
                                        .tint(.white)
                                }
                                Text(scanLimiter.canScan
                                     ? "✏️ Generate Listing"
                                     : "Daily limit reached. Come back tomorrow!")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.ctaGreen)
                        .disabled(!canGenerate)

                        // Generated results
                        if viewModel.hasResult {
                            VStack(spacing: 12) {
                                ResultCardView(
                                    label: "TITLE",
                                    content: viewModel.generatedTitle ?? "",
                                    onCopy: { viewModel.copyToClipboard(viewModel.generatedTitle ?? "") },
                                    onEdit: { navigateToResultDetail() }
                                )

                                ResultCardView(
                                    label: "PRICE",
                                    content: "$\(viewModel.generatedPrice ?? 0)",
                                    onCopy: { viewModel.copyToClipboard("$\(viewModel.generatedPrice ?? 0)") }
                                )

                                ResultCardView(
                                    label: "DESCRIPTION",
                                    content: viewModel.generatedDescription ?? "",
                                    onCopy: { viewModel.copyToClipboard(viewModel.generatedDescription ?? "") }
                                )

                                Button {
                                    saveListing()
                                } label: {
                                    Label(
                                        savedListingId != nil ? "Saved!" : "Save Listing",
                                        systemImage: savedListingId != nil ? "checkmark" : "bookmark"
                                    )
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(savedListingId != nil ? .gray : .accentPurple)
                            }
                            .id("results")
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Scan")
            .fullScreenCover(isPresented: $viewModel.showCamera) {
                CameraView(image: $viewModel.selectedImage)
                    .ignoresSafeArea()
            }
            .task(id: selectedPhotoItem) {
                guard let item = selectedPhotoItem else { return }
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    viewModel.selectedImage = image
                    viewModel.clearResults()
                    savedListingId = nil
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
            .alert("API Key Required", isPresented: $viewModel.showNoAPIKeyAlert) {
                Button("Go to Settings") { selectedTab = 2 }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please add your API key in Settings first.")
            }
            .navigationDestination(isPresented: $navigateToDetail) {
                if let listing = detailListing {
                    ItemDetailView(listing: listing)
                }
            }
        }
        .overlay {
            if viewModel.showCopiedToast {
                ToastView(message: "Copied!")
            }
        }
    }

    private var canGenerate: Bool {
        viewModel.selectedImage != nil && !viewModel.isGenerating && scanLimiter.canScan
    }

    private func saveListing() {
        guard let image = viewModel.selectedImage,
              let photoData = image.jpegData(compressionQuality: 0.8) else { return }

        let id = savedListingId ?? UUID()
        let listing = viewModel.buildListing(photoData: photoData, id: id)
        listingStore.save(listing)
        savedListingId = id

        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func navigateToResultDetail() {
        guard let image = viewModel.selectedImage,
              let photoData = image.jpegData(compressionQuality: 0.8) else { return }

        let id = savedListingId ?? UUID()
        detailListing = viewModel.buildListing(photoData: photoData, id: id)
        navigateToDetail = true
    }
}
