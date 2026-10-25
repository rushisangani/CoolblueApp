import SwiftUI

/// Shows an image downloaded from a URL, with a placeholder until it's available.
///
/// Unlike `AsyncImage`, it loads through the ``ImageLoading`` service in the environment,
/// so images are cached and shared across rows:
///
/// ```swift
/// RemoteImage(url: product.imageURL)
///     .frame(width: 88, height: 88)
///     .environment(\.imageLoader, loader)
/// ```
///
/// The image is scaled to fit the frame. The placeholder stays when the URL is `nil`,
/// no loader is injected, or loading fails; the next appearance retries a failed load.
public struct RemoteImage: View {
    private let url: URL?

    @Environment(\.imageLoader) private var imageLoader
    @State private var loaded: (url: URL, image: UIImage)?

    /// Creates a view that shows the image at `url`.
    public init(url: URL?) {
        self.url = url
    }

    public var body: some View {
        Group {
            // Comparing URLs means a reused view never shows the previous URL's image.
            if let loaded, loaded.url == url {
                Image(uiImage: loaded.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task(id: url) {
            // The task reruns every time the view reappears; skip it when this URL is already shown.
            guard let url, let imageLoader, loaded?.url != url else {
                return
            }
            if let image = try? await imageLoader.image(for: url) {
                loaded = (url, image)
            }
        }
    }
}
