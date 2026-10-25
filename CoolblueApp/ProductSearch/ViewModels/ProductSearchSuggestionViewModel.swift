import Foundation
import Observation

// Drives the search field: product suggestions while typing, and submitting a query to the results screen.
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
    
    // navigates to the results screen on submit
    private let router: ProductSearchRouter
    
    // in-flight request, cancelled when the query changes
    private var task: Task<Void, Never>?

    // shorter queries show no suggestions
    private let minimumQueryLength = 2
    // max suggestions shown under the field
    private let suggestionCount = 4

    init(service: any ProductSearchService, router: ProductSearchRouter) {
        self.service = service
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
        guard query.count >= minimumQueryLength else {
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

    private func loadSuggestions(for query: String) async {
        do {
            let page = try await service.search(query: query, page: 1)
            if Task.isCancelled {
                return
            }
            let suggestedProducts = Array(page.products.prefix(suggestionCount))
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
