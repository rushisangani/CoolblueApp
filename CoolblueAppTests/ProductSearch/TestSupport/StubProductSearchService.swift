@testable import CoolblueApp

// A ProductSearchService with a scripted result per page, recording every request it gets.
actor StubProductSearchService: ProductSearchService {
    struct Request: Equatable {
        let query: String
        let page: Int
    }

    private var results: [Int: Result<ProductSearchResponse, ProductSearchError>]
    // requests received so far, in order
    private(set) var requests: [Request] = []

    init(results: [Int: Result<ProductSearchResponse, ProductSearchError>] = [:]) {
        self.results = results
    }

    // Replaces the result for `page`, e.g. to make a retry succeed after a failure.
    func setResult(_ result: Result<ProductSearchResponse, ProductSearchError>, forPage page: Int) {
        results[page] = result
    }

    func search(query: String, page: Int) async throws(ProductSearchError) -> ProductSearchResponse {
        requests.append(Request(query: query, page: page))
        guard let result = results[page] else {
            throw .unknown
        }
        return try result.get()
    }
}
