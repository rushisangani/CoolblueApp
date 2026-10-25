import Foundation
import Testing
import Networking
@testable import CoolblueApp

struct ProductSearchErrorTests {
    @Test(arguments: [
        (NetworkError.noConnection, ProductSearchError.offline),
        (.timedOut, .offline),
        (.cancelled, .cancelled),
        (.invalidResponse, .server),
        (.badStatus(500), .server),
        (.transport(.cannotFindHost), .unknown),
    ])
    func mapsNetworkErrors(networkError: NetworkError, expected: ProductSearchError) {
        #expect(ProductSearchError(networkError) == expected)
    }
}
