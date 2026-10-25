import Foundation
import Networking

// Product Search Service
nonisolated protocol ProductSearchService: Sendable {
    func search(query: String, page: Int) async throws(ProductSearchError) -> ProductSearchResponse
}

// Fetches search pages from the API and translates transport errors into `ProductSearchError`.
nonisolated struct RemoteProductSearchService: ProductSearchService {
    private let client: any NetworkClient

    init(client: any NetworkClient) {
        self.client = client
    }

    func search(query: String, page: Int) async throws(ProductSearchError) -> ProductSearchResponse {
        let data: Data
        do {
            data = try await client.data(from: ProductSearchEndpoint.url(query: query, page: page))
        } catch {
            throw ProductSearchError(error)
        }

        do {
            return try await Self.decode(data)
        } catch {
            throw .decoding
        }
    }

    // `@concurrent` runs decoding off the caller's actor, so a large page never blocks the main thread.
    @concurrent
    private static func decode(_ data: Data) async throws -> ProductSearchResponse {
        try JSONDecoder().decode(ProductSearchResponse.self, from: data)
    }
}
