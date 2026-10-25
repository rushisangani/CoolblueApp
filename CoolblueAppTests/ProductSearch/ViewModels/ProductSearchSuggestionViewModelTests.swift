import Testing
@testable import CoolblueApp

@MainActor
struct ProductSearchSuggestionViewModelTests {
    // page 1 has six products, more than the four suggestions shown
    private let page = ProductSearchResponse.stub(ids: [1, 2, 3, 4, 5, 6])
    private let service: StubProductSearchService
    private let router = ProductSearchRouter()

    init() {
        service = StubProductSearchService(results: [1: .success(page)])
    }

    // No-op sleep, so tests don't wait out the real debounce.
    private func makeViewModel(
        configuration: ProductSearchSuggestionConfiguration = ProductSearchSuggestionConfiguration(sleep: { _ in })
    ) -> ProductSearchSuggestionViewModel {
        ProductSearchSuggestionViewModel(service: service, configuration: configuration, router: router)
    }

    @Test func shortQueryStaysIdleWithoutRequest() async {
        let viewModel = makeViewModel()

        viewModel.queryChanged("i")

        #expect(viewModel.state == .idle)
        #expect(await service.requests.isEmpty)
    }

    @Test func loadsAtMostTheConfiguredNumberOfSuggestions() async {
        let viewModel = makeViewModel()

        viewModel.queryChanged(" ip ")

        #expect(viewModel.query == "ip")
        #expect(viewModel.state == .loading)
        await waitUntil { viewModel.state != .loading }
        #expect(viewModel.state == .loaded(Array(page.products.prefix(4))))
        #expect(await service.requests == [.init(query: "ip", page: 1)])
    }

    @Test func whitespaceOnlyChangeDoesNotSearchAgain() async {
        let viewModel = makeViewModel()
        viewModel.queryChanged("ip")
        await waitUntil { viewModel.state != .loading }

        viewModel.queryChanged("ip ")

        #expect(viewModel.state == .loaded(Array(page.products.prefix(4))))
        #expect(await service.requests.count == 1)
    }

    @Test func newKeystrokeDuringDebounceCancelsThePreviousSearch() async {
        let viewModel = makeViewModel(configuration: ProductSearchSuggestionConfiguration(debounceInterval: .milliseconds(50)))

        viewModel.queryChanged("ip")
        viewModel.queryChanged("iph")

        await waitUntil { viewModel.state != .loading }
        #expect(await service.requests == [.init(query: "iph", page: 1)])
    }

    @Test func failureShowsNoSuggestions() async {
        await service.setResult(.failure(.offline), forPage: 1)
        let viewModel = makeViewModel()

        viewModel.queryChanged("ip")

        await waitUntil { viewModel.state != .loading }
        #expect(viewModel.state == .loaded([]))
    }

    @Test func clearingTheQueryReturnsToIdle() async {
        let viewModel = makeViewModel()
        viewModel.queryChanged("ip")
        await waitUntil { viewModel.state != .loading }

        viewModel.queryChanged("")

        #expect(viewModel.state == .idle)
        #expect(!viewModel.canSubmit)
    }

    @Test func submitSearchShowsResultsOnlyWithAQuery() {
        let viewModel = makeViewModel()

        viewModel.submitSearch()
        #expect(router.path.isEmpty)

        viewModel.queryChanged("ip")
        viewModel.submitSearch()
        #expect(router.path == [.results(query: "ip")])
    }

    @Test func showProductOpensItsDetail() {
        let viewModel = makeViewModel()
        let product = Product.stub(id: 1)

        viewModel.showProduct(product)

        #expect(router.path == [.product(product)])
    }
}
