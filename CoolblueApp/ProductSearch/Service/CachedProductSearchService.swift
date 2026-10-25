import Foundation

// Keeps search pages in memory for the app session, so the results screen reuses the suggestions already loaded,
// and searching a query again doesn't download it twice. Failures aren't cached.
actor CachedProductSearchService: ProductSearchService {
    private let service: any ProductSearchService
    // pages already loaded, keyed by page and query
    private var pages: [String: ProductSearchResponse] = [:]

    init(wrapping service: any ProductSearchService) {
        self.service = service
    }

    func search(query: String, page: Int) async throws(ProductSearchError) -> ProductSearchResponse {
        // Page first, so no query text can make two keys collide.
        let key = "\(page) \(query)"
        if let cached = pages[key] {
            return cached
        }
        let response = try await service.search(query: query, page: page)
        pages[key] = response
        return response
    }
}
