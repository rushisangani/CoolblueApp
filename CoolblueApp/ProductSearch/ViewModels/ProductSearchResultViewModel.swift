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
    }

    // query the results are for
    let query: String
    // products of the first page
    private(set) var products: [Product] = []

    // current view state
    private(set) var state: State = .idle

    // source of result pages
    private let service: any ProductSearchService

    init(query: String, service: any ProductSearchService) {
        self.query = query
        self.service = service
    }

    // Called every time the screen appears; only the first call loads.
    func start() {
        guard state == .idle else { return }
        state = .loading

        Task {
            await load()
        }
    }

    private func load() async {
        // An error leaves the list empty for now.
        products = (try? await service.search(query: query, page: 1).products) ?? []
        state = .loaded
    }
}
