import Testing
@testable import CoolblueApp

struct CachedProductSearchServiceTests {
    @Test func samePageIsLoadedOnlyOnce() async throws {
        let stub = StubProductSearchService(results: [1: .success(.stub(ids: [1, 2]))])
        let service = CachedProductSearchService(wrapping: stub)

        _ = try await service.search(query: "ip", page: 1)
        let cached = try await service.search(query: "ip", page: 1)

        #expect(cached.products.map(\.id) == [1, 2])
        #expect(await stub.requests == [.init(query: "ip", page: 1)])
    }

    @Test func otherPageOrQueryIsLoaded() async throws {
        let stub = StubProductSearchService(results: [
            1: .success(.stub(ids: [1])),
            2: .success(.stub(ids: [2], page: 2)),
        ])
        let service = CachedProductSearchService(wrapping: stub)

        _ = try await service.search(query: "ip", page: 1)
        _ = try await service.search(query: "ip", page: 2)
        _ = try await service.search(query: "mac", page: 1)

        #expect(await stub.requests == [
            .init(query: "ip", page: 1),
            .init(query: "ip", page: 2),
            .init(query: "mac", page: 1),
        ])
    }
}
