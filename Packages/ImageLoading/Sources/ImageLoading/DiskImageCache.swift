import CryptoKit
import UIKit

/// An ``ImageCache`` that keeps images as files, so they survive app relaunches.
///
/// Files live in the Caches directory, which the system may purge when storage runs low,
/// so the cache doesn't enforce its own size limit.
public actor DiskImageCache: ImageCache {
    private let directory: URL

    /// Creates a cache in a folder named `name` inside the app's Caches directory.
    public init(name: String = "Images") {
        directory = URL.cachesDirectory.appending(path: name, directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    public func image(for url: URL) async -> UIImage? {
        guard let data = try? Data(contentsOf: fileURL(for: url)), let image = UIImage(data: data) else {
            return nil
        }
        // Decode now, off the main thread, rather than on first draw.
        return await image.byPreparingForDisplay() ?? image
    }

    public func insert(_ image: UIImage, for url: URL) {
        // PNG keeps the image lossless; product images are small, so the size cost is acceptable.
        try? image.pngData()?.write(to: fileURL(for: url), options: .atomic)
    }

    private func fileURL(for url: URL) -> URL {
        // Image URLs contain slashes and query strings, so a hash gives a safe, unique file name.
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        let name = digest.map { String(format: "%02x", $0) }.joined()
        return directory.appending(path: name)
    }
}
