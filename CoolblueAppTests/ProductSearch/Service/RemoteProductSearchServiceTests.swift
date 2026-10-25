import Foundation
import Testing
import Networking
@testable import CoolblueApp

struct RemoteProductSearchServiceTests {
    @Test func decodesTheResponse() async throws {
        let service = RemoteProductSearchService(client: StubNetworkClient(result: .success(Fixture.searchPage)))

        let page = try await service.search(query: "iphone", page: 1)

        #expect(page.products.map(\.id) == [785359, 793277])
        #expect(page.pageCount == 3)
    }

    @Test func mapsNetworkErrors() async {
        let service = RemoteProductSearchService(client: StubNetworkClient(result: .failure(.noConnection)))

        await #expect(throws: ProductSearchError.offline) {
            try await service.search(query: "iphone", page: 1)
        }
    }

    @Test func invalidJSONThrowsDecoding() async {
        let service = RemoteProductSearchService(client: StubNetworkClient(result: .success(Data("{}".utf8))))

        await #expect(throws: ProductSearchError.decoding) {
            try await service.search(query: "iphone", page: 1)
        }
    }
}
