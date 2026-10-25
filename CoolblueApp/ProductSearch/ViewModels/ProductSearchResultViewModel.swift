import Foundation
import Observation

struct ProductSearchResultConfiguration {
    // how many rows from the end the next page starts loading
    var prefetchDistance = 5
}

// Loads the results for one query, page by page, as the user scrolls.
@MainActor
@Observable
final class ProductSearchResultViewModel {
    
    // view state
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case failed(ProductSearchError)
    }

    // footer state while paging
    enum LoadMoreState: Equatable {
        case idle
        case loading
        case failed(ProductSearchError)
    }

    // query the results are for
    let query: String
    // products loaded so far, across all pages
    private(set) var products: [Product] = []
    
    // current view state
    private(set) var state: State = .idle
    // footer spinner or retry footer under the list
    private(set) var loadMoreState: LoadMoreState = .idle

    // last page loaded; 0 before the first page arrives
    private var currentPage = 0
    // total pages reported by the API
    private var pageCount = 0
    // in-flight page request, cancelled on reload
    private var task: Task<Void, Never>?

    // source of result pages
    private let service: any ProductSearchService

    // prefetch distance
    private let configuration: ProductSearchResultConfiguration

    init(
        query: String,
        service: any ProductSearchService,
        configuration: ProductSearchResultConfiguration = ProductSearchResultConfiguration()
    ) {
        self.query = query
        self.service = service
        self.configuration = configuration
    }

    // Called every time the screen appears; only the first call loads.
    func start() {
        guard state == .idle else { return }
        retry()
    }

    // resets everything and loads page 1; also the full-screen Try Again
    func retry() {
        task?.cancel()
        products = []
        currentPage = 0
        pageCount = 0
        loadMoreState = .idle
        state = .loading
        
        task = Task {
            await load(page: 1)
        }
    }

    private func load(page: Int) async {
        do {
            let result = try await service.search(query: query, page: page)
            if Task.isCancelled {
                return
            }
            
            // The API answers a page past the end with its last page, so filter repeats
            // and take the page number from the response; paging then stops at the real end.
            let knownIDs = Set(products.map(\.id))
            products += result.products.filter { !knownIDs.contains($0.id) }
            currentPage = result.currentPage
            pageCount = result.pageCount
            state = products.isEmpty ? .empty : .loaded
            loadMoreState = .idle
            
        } catch ProductSearchError.cancelled {
            return // Cancelled by a reload; it has already reset the state.
        } catch {
            // A failure can still race a cancellation; don't overwrite the reload's state.
            if Task.isCancelled {
                return
            }
            
            // Page 1 has nothing to fall back on, so it shows the full-screen error.
            // A later page keeps the products already loaded and shows a retry footer under them.
            if page == 1 {
                state = .failed(error)
            } else {
                loadMoreState = .failed(error)
            }
        }
    }
}

// MARK: - Load more

extension ProductSearchResultViewModel {
    // loads the next page once a row near the end appears
    func loadMoreIfNeeded(after product: Product) {
        guard products.suffix(configuration.prefetchDistance).contains(where: { $0.id == product.id }) else {
            return
        }
        loadNextPage()
    }

    // retries the next page after a footer error
    func retryLoadMore() {
        loadMoreState = .idle
        loadNextPage()
    }

    // Only from `.idle`: after a failure only `retryLoadMore()` loads again, so scrolling doesn't retry a failing page.
    private func loadNextPage() {
        guard state == .loaded, loadMoreState == .idle, currentPage < pageCount else {
            return
        }
        loadMoreState = .loading
        task = Task {
            await load(page: currentPage + 1)
        }
    }
}
