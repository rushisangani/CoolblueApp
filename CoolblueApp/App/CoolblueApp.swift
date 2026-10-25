import SwiftUI

@main
struct CoolblueApp: App {
    private let client: any NetworkClient // Shared NetworkClient
    private let imageLoader: ImageLoader // Shared ImageLoader

    init() {
        self.client = Self.makeNetworkClient()

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
