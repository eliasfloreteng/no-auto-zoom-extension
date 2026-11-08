import SafariServices
import SwiftUI

/// The app exists to install the Safari extension, so it only explains how to turn it on.
struct SetupView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var isEnabled: Bool?
    @State private var settingsError: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        Image(.appIconArtwork)
                            .resizable()
                            .frame(width: 88, height: 88)
                            .clipShape(.rect(cornerRadius: 20))
                            .accessibilityHidden(true)
                        Text("Safari zooms in whenever you tap a text field with small text. This extension stops that. Pinch-to-zoom keeps working.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }

                Section {
                    if let isEnabled {
                        Label {
                            Text(isEnabled ? "The extension is on" : "The extension is off")
                        } icon: {
                            Image(systemName: isEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(isEnabled ? .green : .secondary)
                        }
                    }
                    Button("Open Safari Extension Settings", systemImage: "gear", action: openSettings)
                } footer: {
                    if let settingsError {
                        Text(settingsError)
                    }
                }

                Section("Turn it on") {
                    Step(number: 1, text: "Tap **Open Safari Extension Settings**, or go to **Settings › Apps › Safari › Extensions › No Auto Zoom**.")
                    Step(number: 2, text: "Turn on **Allow Extension**.")
                    Step(number: 3, text: "Set **All Websites** to **Allow**, so it works on every site.")
                }

                Section {
                    Label {
                        Text("To keep auto-zoom on a site, tap \(Image(systemName: "puzzlepiece.extension")) in Safari's page menu, choose **No Auto Zoom** and turn it off for that site.")
                    } icon: {
                        Image(systemName: "hand.tap")
                    }
                } header: {
                    Text("Per site")
                }
            }
            .navigationTitle("No Auto Zoom")
        }
        // Coming back from Settings is the moment the state is likely to have changed.
        .task(id: scenePhase) {
            if scenePhase == .active { await refreshState() }
        }
    }

    private static let extensionIdentifier = "\(Bundle.main.bundleIdentifier!).extension"

    private func refreshState() async {
        isEnabled = try? await SFSafariExtensionManager
            .stateOfExtension(withIdentifier: Self.extensionIdentifier)
            .isEnabled
    }

    private func openSettings() {
        Task {
            do {
                try await SFSafariSettings.openExtensionsSettings(forIdentifiers: [Self.extensionIdentifier])
                settingsError = nil
            } catch {
                settingsError = "Couldn't open Settings: \(error.localizedDescription)"
            }
        }
    }
}

private struct Step: View {
    let number: Int
    let text: LocalizedStringKey

    var body: some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: "\(number).circle.fill")
                .foregroundStyle(.tint)
        }
    }
}

#Preview {
    SetupView()
}
