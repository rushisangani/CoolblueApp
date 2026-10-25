import SwiftUI

@main
struct CoolblueApp: App {
    private let client: any NetworkClient // Shared NetworkClient
    private let imageLoader: ImageLoader // Shared ImageLoader

    init() {
        // 15 s instead of the 60 s default, so a stalled request fails fast and the retry button appears sooner.
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        self.client = NetworkManager(session: URLSession(configuration: configuration))

        imageLoader = ImageLoader(
            client: client,
            cache: LayeredImageCache(primary: MemoryImageCache(), secondary: DiskImageCache())
        )
    }

    var body: some Scene {
        WindowGroup {
            ProductSearchView(client: client)
                .environment(\.imageLoader, imageLoader)
        }
    }
}
