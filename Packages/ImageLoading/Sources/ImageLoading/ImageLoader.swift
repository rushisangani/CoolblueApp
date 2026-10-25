import Networking
import UIKit

/// Downloads, decodes and caches remote images.
///
/// It's an `actor` because many rows ask for images at the same time, and it keeps a mutable
/// record of downloads in progress. The actor serializes access to that record without locks,
/// which Swift 6's data-race checking requires.
///
/// Concurrent requests for the same URL share one download. A download keeps running when the
/// view that asked for it disappears, so the image still lands in the cache for the next request.
public actor ImageLoader: ImageLoading {
    private let client: any NetworkClient
    private let cache: any ImageCache
    private var inFlight: [URL: Task<Result<UIImage, ImageLoadingError>, Never>] = [:]

    /// Creates a loader that downloads through `client` and stores images in `cache`.
    public init(client: any NetworkClient, cache: any ImageCache) {
        self.client = client
        self.cache = cache
    }

    public func image(for url: URL) async throws(ImageLoadingError) -> UIImage {
        if let cached = await cache.image(for: url) {
            return cached
        }
        // Checked after the cache lookup: another call may have started this download while we were suspended.
        if let task = inFlight[url] {
            return try await task.value.get()
        }

        // An unstructured task, so a cancelled caller doesn't cancel a download other callers are waiting for.
        // It returns a Result because Task can't carry a typed error.
        let task = Task { [client, cache] in
            await Self.download(url, client: client, cache: cache)
        }
        inFlight[url] = task
        defer {
            inFlight[url] = nil
        }
        return try await task.value.get()
    }

    private static func download(_ url: URL, client: any NetworkClient, cache: any ImageCache) async -> Result<UIImage, ImageLoadingError> {
        let data: Data
        do {
            data = try await client.data(from: url)
        } catch {
            return .failure(.network(error))
        }
        guard let image = UIImage(data: data) else {
            return .failure(.invalidImageData)
        }
        // Decode now, off the main thread, rather than on first draw. Failures aren't cached, so they retry next time.
        let prepared = await image.byPreparingForDisplay() ?? image
        await cache.insert(prepared, for: url)
        return .success(prepared)
    }
}
