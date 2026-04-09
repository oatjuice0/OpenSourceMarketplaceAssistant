import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ScanView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Scan", systemImage: "camera.fill")
                }
                .tag(0)

            SavedListingsView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(2)
        }
        .tint(Color.accentPurple)
    }
}
