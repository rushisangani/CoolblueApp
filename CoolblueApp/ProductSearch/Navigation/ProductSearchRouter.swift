import Observation

// Owns the search navigation stack. View models ask it to navigate; the screen only binds to `path`.
@MainActor
@Observable
final class ProductSearchRouter {
    enum Route: Hashable {
        case results(query: String)
    }

    var path: [Route] = []

    // Replaces the stack instead of appending, so searching again never stacks results on results.
    func showResults(for query: String) {
        path = [.results(query: query)]
    }
}
