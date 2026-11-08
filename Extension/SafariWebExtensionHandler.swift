import Foundation

/// Safari requires a principal class for the extension. The extension keeps its
/// settings in `browser.storage` and never messages the app, so it has no work to do.
final class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {
    func beginRequest(with context: NSExtensionContext) {
        context.completeRequest(returningItems: nil)
    }
}
