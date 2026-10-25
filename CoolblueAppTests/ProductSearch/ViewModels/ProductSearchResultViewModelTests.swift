import Testing
@testable import CoolblueApp

@MainActor
struct ProductSearchResultViewModelTests {
    private let router = ProductSearchRouter()

    private func makeViewModel(
        _ results: [Int: Result<ProductSearchResponse, ProductSearchError>],
        prefetchDistance: Int = 5
    ) -> (ProductSearchResultViewModel, StubProductSearchService) {
        let service = StubProductSearchService(results: results)
        let viewModel = ProductSearchResultViewModel(
            query: "ip",
            service: service,
            router: router,
            configuration: ProductSearchResultConfiguration(prefetchDistance: prefetchDistance)
        )
        return (viewModel, service)
    }

    // Starts the view model and waits until the first page has loaded or failed.
    private func start(_ viewModel: ProductSearchResultViewModel) async {
        viewModel.start()
        #expect(viewModel.state == .loading)
        await waitUntil { viewModel.state != .loading }
    }

    @Test func startLoadsTheFirstPageOnce() async {
        let (viewModel, service) = makeViewModel([1: .success(.stub(ids: [1, 2]))])

        await start(viewModel)
        viewModel.start()

        #expect(viewModel.state == .loaded)
        #expect(viewModel.products.map(\.id) == [1, 2])
        #expect(await service.requests == [.init(query: "ip", page: 1)])
    }

    @Test func emptyFirstPageShowsEmpty() async {
        let (viewModel, _) = makeViewModel([1: .success(.stub(ids: []))])

        await start(viewModel)

        #expect(viewModel.state == .empty)
    }

    @Test func firstPageFailureShowsTheErrorUntilRetry() async {
        let (viewModel, service) = makeViewModel([1: .failure(.offline)])
        await start(viewModel)
        #expect(viewModel.state == .failed(.offline))

        await service.setResult(.success(.stub(ids: [1])), forPage: 1)
        viewModel.retry()

        #expect(viewModel.state == .loading)
        await waitUntil { viewModel.state != .loading }
        #expect(viewModel.state == .loaded)
        #expect(viewModel.products.map(\.id) == [1])
    }

    @Test func scrollingNearTheEndAppendsTheNextPageWithoutDuplicates() async {
        let (viewModel, service) = makeViewModel([
            1: .success(.stub(ids: [1, 2], page: 1, pageCount: 2)),
            2: .success(.stub(ids: [2, 3], page: 2, pageCount: 2)),
        ])
        await start(viewModel)

        viewModel.loadMoreIfNeeded(after: viewModel.products[1])

        #expect(viewModel.loadMoreState == .loading)
        await waitUntil { viewModel.loadMoreState != .loading }
        #expect(viewModel.products.map(\.id) == [1, 2, 3])
        #expect(await service.requests.map(\.page) == [1, 2])
    }

    @Test func rowFarFromTheEndDoesNotLoadMore() async {
        let (viewModel, service) = makeViewModel(
            [1: .success(.stub(ids: [1, 2, 3], page: 1, pageCount: 2))],
            prefetchDistance: 1
        )
        await start(viewModel)

        viewModel.loadMoreIfNeeded(after: viewModel.products[0])

        #expect(viewModel.loadMoreState == .idle)
        #expect(await service.requests.map(\.page) == [1])
    }

    @Test func lastPageDoesNotLoadMore() async {
        let (viewModel, service) = makeViewModel([1: .success(.stub(ids: [1, 2], page: 1, pageCount: 1))])
        await start(viewModel)

        viewModel.loadMoreIfNeeded(after: viewModel.products[1])

        #expect(viewModel.loadMoreState == .idle)
        #expect(await service.requests.map(\.page) == [1])
    }

    @Test func showProductOpensItsDetail() {
        let (viewModel, _) = makeViewModel([:])
        let product = Product.stub(id: 1)

        viewModel.showProduct(product)

        #expect(router.path == [.product(product)])
    }
}
