import SwiftUI
import ImageLoading
import Networking

@main
struct CoolblueApp: App {
    private let productSearchService: any ProductSearchService // Cached, shared by both search screens
    private let imageLoader: ImageLoader // Shared ImageLoader

    init() {
        let client = Self.makeNetworkClient()

        productSearchService = CachedProductSearchService(wrapping: RemoteProductSearchService(client: client))
        imageLoader = ImageLoader(
            client: client,
            cache: LayeredImageCache(primary: MemoryImageCache(), secondary: DiskImageCache())
        )
    }

    var body: some Scene {
        WindowGroup {
            ProductSearchView(service: productSearchService)
                .environment(\.imageLoader, imageLoader)
        }
    }
    
    private static func makeNetworkClient() -> any NetworkClient {
        #if DEBUG
        // UI tests pass saved search pages at launch, so the app never calls the real API under test.
        if let client = LaunchEnvironmentNetworkClient(environment: ProcessInfo.processInfo.environment) {
            return client
        }
        #endif

        // 15 s instead of the 60 s default, so a stalled request fails fast and the retry button appears sooner.
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        return NetworkManager(session: URLSession(configuration: configuration))
    }
}
