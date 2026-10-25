import Foundation
import Observation

// Loads the first page of results for one query.
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

    // query the results are for
    let query: String
    // products of the first page
    private(set) var products: [Product] = []

    // current view state
    private(set) var state: State = .idle

    // in-flight request, cancelled on reload
    private var task: Task<Void, Never>?

    // source of result pages
    private let service: any ProductSearchService

    init(query: String, service: any ProductSearchService) {
        self.query = query
        self.service = service
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
        state = .loading

        task = Task {
            await load()
        }
    }

    private func load() async {
        do {
            let result = try await service.search(query: query, page: 1)
            if Task.isCancelled {
                return
            }
            products = result.products
            state = products.isEmpty ? .empty : .loaded

        } catch ProductSearchError.cancelled {
            return // Cancelled by a reload; it has already reset the state.
        } catch {
            // A failure can still race a cancellation; don't overwrite the reload's state.
            if Task.isCancelled {
                return
            }
            state = .failed(error)
        }
    }
}
