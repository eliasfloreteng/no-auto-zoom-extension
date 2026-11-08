import SwiftUI

/// The app exists to install the Safari extension, so it only explains how to turn it on.
struct SetupView: View {
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

                Section("Turn it on") {
                    Step(number: 1, text: "Open **Settings** and go to **Apps › Safari › Extensions**.")
                    Step(number: 2, text: "Tap **No Auto Zoom** and turn on **Allow Extension**.")
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
