import SwiftUI

@main
struct CoolblueApp: App {
    private let client: any NetworkClient = NetworkManager() // Shared NetworkClient
    private let imageLoader: ImageLoader // Shared ImageLoader

    init() {
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
