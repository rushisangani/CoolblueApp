import UIKit

/// Stores decoded images by URL.
///
/// ``ImageLoader`` takes a cache from outside, so the app can use memory plus disk.
/// Methods are `async` so implementations can do file I/O or protect their state with an actor.
public nonisolated protocol ImageCache: Sendable {
    /// Returns the cached image for `url`, or `nil` when there is none.
    func image(for url: URL) async -> UIImage?
    /// Stores `image` for `url`, replacing any existing entry.
    func insert(_ image: UIImage, for url: URL) async
}
