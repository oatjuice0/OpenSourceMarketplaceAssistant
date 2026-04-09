import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsManager: SettingsManager
    @EnvironmentObject var scanLimiter: ScanLimiter

    @State private var apiKeyInput: String = ""
    @State private var showAPIKey = false

    var body: some View {
        NavigationStack {
            Form {
                Section("API Configuration") {
                    Picker("Provider", selection: $settingsManager.apiProvider) {
                        ForEach(SettingsManager.APIProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }

                    HStack {
                        if showAPIKey {
                            TextField("API Key", text: $apiKeyInput)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        } else {
                            SecureField("API Key", text: $apiKeyInput)
                        }

                        Button {
                            showAPIKey.toggle()
                        } label: {
                            Image(systemName: showAPIKey ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    .onChange(of: apiKeyInput) { newValue in
                        settingsManager.apiKey = newValue
                    }

                    if settingsManager.hasAPIKey {
                        Label("API key saved", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }

                Section("Usage") {
                    HStack {
                        Text("Daily Scan Limit")
                        Spacer()
                        Text("10 scans per day (Free tier)")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }

                    HStack {
                        Text("Scans Used Today")
                        Spacer()
                        Text("\(scanLimiter.scansUsed) / 10")
                            .foregroundColor(.secondary)
                    }

                    Button("Reset Scan Counter") {
                        scanLimiter.resetCounter()
                    }
                    .font(.subheadline)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Developer")
                        Spacer()
                        Text("Marketplace Assistant")
                            .foregroundColor(.secondary)
                    }
                }

                Section("Legal") {
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Use", destination: URL(string: "https://example.com/terms")!)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                apiKeyInput = settingsManager.apiKey
            }
        }
    }
}
