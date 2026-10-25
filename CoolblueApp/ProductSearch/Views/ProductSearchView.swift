import SwiftUI

struct ProductSearchView: View {
    @State private var router: ProductSearchRouter
    @State private var viewModel: ProductSearchSuggestionViewModel
    // shared by the suggestion and result view models
    private let service: any ProductSearchService

    @State private var text = ""
    @FocusState private var isSearchFocused: Bool

    init(client: any NetworkClient) {
        let router = ProductSearchRouter()
        let service = RemoteProductSearchService(client: client)
        self.service = service
        _router = State(initialValue: router)
        _viewModel = State(initialValue: ProductSearchSuggestionViewModel(service: service, router: router))
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            content
                .navigationTitle("Coolblue")
                .searchable(text: $text, prompt: "What are you looking for")
                .searchFocused($isSearchFocused)
                .onChange(of: text) {
                    viewModel.queryChanged(text)
                }
                .onSubmit(of: .search) {
                    viewModel.submitSearch()
                }
                .navigationDestination(for: ProductSearchRouter.Route.self) { route in
                    switch route {
                    case .results(let query):
                        // Tied to the query, so replacing the route with a new query gets a new screen and view model.
                        ProductSearchResultView(
                            viewModel: ProductSearchResultViewModel(query: query, service: service, router: router)
                        )
                        .id(query)
                    case .product(let product):
                        ProductDetailView(product: product)
                    }
                }
        }
    }

    // Part of the screen, not the search overlay, so the list and its scroll position survive navigating away.
    @ViewBuilder
    private var content: some View {
        if viewModel.canSubmit {
            suggestionList
        } else {
            ContentUnavailableView(
                "Search what you need",
                systemImage: "magnifyingglass",
                description: Text("Type to see suggestions.")
            )
        }
    }

    private var suggestionList: some View {
        List {
            Button {
                // End editing first, like the keyboard's Search key does.
                isSearchFocused = false
                viewModel.submitSearch()
            } label: {
                Label("Search for \"\(viewModel.query)\"", systemImage: "magnifyingglass")
            }

            switch viewModel.state {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
            case .loaded(let products):
                ForEach(products) { product in
                    Button {
                        isSearchFocused = false
                        viewModel.showProduct(product)
                    } label: {
                        ProductRow(product: product)
                    }
                    // Keeps the row's own colors instead of tinting its text like a link.
                    .buttonStyle(.plain)
                }
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
    }
}
