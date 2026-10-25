import Foundation
import Observation

struct ProductSearchSuggestionConfiguration {
    // pause after the last keystroke before requesting
    var debounceInterval: Duration = .milliseconds(300)
    // shorter queries show no suggestions
    var minimumQueryLength = 2
    // max suggestions shown under the field
    var suggestionCount = 4
    // waits out the debounce
    var sleep: @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
}

// Drives the search field: debounced product suggestions while typing, and submitting a query to the results screen.
@MainActor
@Observable
final class ProductSearchSuggestionViewModel {
   
    // view state
    enum State {
        case idle
        case loading
        case loaded([Product])
    }

    // current view state
    private(set) var state: State = .idle
    // trimmed search query
    private(set) var query = ""

    // source of suggestion products
    private let service: any ProductSearchService
    
    // debounce, query length and suggestion count
    private let configuration: ProductSearchSuggestionConfiguration
    
    // navigates to the results on submit and to a product on tap
    private let router: ProductSearchRouter
    
    // in-flight debounce + request, cancelled when the query changes
    private var task: Task<Void, Never>?

    init(
        service: any ProductSearchService,
        configuration: ProductSearchSuggestionConfiguration = ProductSearchSuggestionConfiguration(),
        router: ProductSearchRouter
    ) {
        self.service = service
        self.configuration = configuration
        self.router = router
    }

    // any non-empty query can be submitted
    var canSubmit: Bool {
        !query.isEmpty
    }

    // restarts suggestions for the new text
    func queryChanged(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Typing a space changes the text but not the query; don't restart the request for it.
        guard trimmed != query else { return }
        query = trimmed

        // Latest wins: a new keystroke cancels the pending or running request.
        task?.cancel()
        guard query.count >= configuration.minimumQueryLength else {
            state = .idle
            return
        }
        // show the spinner and load suggestions
        state = .loading
        task = Task {
            await loadSuggestions(for: query)
        }
    }

    func submitSearch() {
        guard canSubmit else {
            return
        }
        // show search results
        router.showResults(for: query)
    }

    // opens a suggested product's detail screen
    func showProduct(_ product: Product) {
        router.showProduct(product)
    }

    private func loadSuggestions(for query: String) async {
        do {
            try await configuration.sleep(configuration.debounceInterval)
        } catch {
            return // Cancelled by a newer keystroke during the debounce.
        }

        do {
            let page = try await service.search(query: query, page: 1)
            if Task.isCancelled {
                return
            }
            let suggestedProducts = Array(page.products.prefix(configuration.suggestionCount))
            state = .loaded(suggestedProducts)
            
        } catch ProductSearchError.cancelled {
            return // Cancelled by a newer keystroke mid-request.
        } catch {
            // A failure can still race a cancellation; don't overwrite the newer query's state.
            if Task.isCancelled {
                return
            }
            // Suggestions are optional: on failure, show none and let the results screen report the error.
            state = .loaded([])
        }
    }
}
