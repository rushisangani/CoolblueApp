import UIKit

/// An ``ImageCache`` that checks a fast cache before a slower, persistent one.
///
/// A hit in `secondary` is copied into `primary`, so the next read is fast.
public struct LayeredImageCache: ImageCache {
    private let primary: any ImageCache
    private let secondary: any ImageCache

    /// Creates a cache that reads `primary` first, typically memory, then `secondary`, typically disk.
    public init(primary: any ImageCache, secondary: any ImageCache) {
        self.primary = primary
        self.secondary = secondary
    }

    public func image(for url: URL) async -> UIImage? {
        if let image = await primary.image(for: url) {
            return image
        }
        guard let image = await secondary.image(for: url) else {
            return nil
        }
        await primary.insert(image, for: url)
        return image
    }

    public func insert(_ image: UIImage, for url: URL) async {
        await primary.insert(image, for: url)
        await secondary.insert(image, for: url)
    }
}
