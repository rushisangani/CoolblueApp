import SwiftUI

struct ProductSearchView: View {
    @State private var router = ProductSearchRouter()
    private let service: any ProductSearchService
    @State private var text = ""

    init(client: any NetworkClient) {
        service = RemoteProductSearchService(client: client)
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            ContentUnavailableView(
                "Search what you need",
                systemImage: "magnifyingglass",
                description: Text("Search to see products.")
            )
            .navigationTitle("Coolblue")
            .searchable(text: $text, prompt: "What are you looking for")
            .onSubmit(of: .search) {
                let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !query.isEmpty else { return }
                router.showResults(for: query)
            }
            .navigationDestination(for: ProductSearchRouter.Route.self) { route in
                switch route {
                case .results(let query):
                    // Tied to the query, so replacing the route with a new query gets a new screen and view model.
                    ProductSearchResultView(viewModel: ProductSearchResultViewModel(query: query, service: service))
                        .id(query)
                }
            }
        }
    }
}
