import SwiftUI

@main
struct CoolblueApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ProductSearchResultView(
                    viewModel: ProductSearchResultViewModel(
                        query: "apple",
                        service: RemoteProductSearchService(client: NetworkManager())
                    )
                )
            }
        }
    }
}
