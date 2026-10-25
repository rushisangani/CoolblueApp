import UIKit

/// An in-memory ``ImageCache`` that the system trims under memory pressure.
public actor MemoryImageCache: ImageCache {
    // NSCache evicts entries automatically when memory runs low; the actor guards access to it.
    private let cache = NSCache<NSURL, UIImage>()

    public init() {}

    public func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    public func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}
