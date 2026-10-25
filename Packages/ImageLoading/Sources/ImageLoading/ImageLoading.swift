import SwiftUI

/// Loads images from remote URLs.
///
/// ``RemoteImage`` reads a conforming loader from the environment, so views never create one themselves.
public protocol ImageLoading: Sendable {
    /// Returns the image at `url`, from a cache when possible.
    ///
    /// - Throws: ``ImageLoadingError`` when the download fails or the data isn't an image.
    func image(for url: URL) async throws(ImageLoadingError) -> UIImage
}

extension EnvironmentValues {
    /// The loader ``RemoteImage`` uses.
    ///
    /// `nil` by default: a view tree without an injected loader shows placeholders,
    /// which makes a missing injection visible and keeps previews off the network.
    @Entry public var imageLoader: (any ImageLoading)? = nil
}
