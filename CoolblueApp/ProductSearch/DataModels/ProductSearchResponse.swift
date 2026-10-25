import Foundation

// One page of search results.
nonisolated struct ProductSearchResponse: Decodable, Sendable {
    let products: [Product]
    let currentPage: Int
    let pageCount: Int
}
