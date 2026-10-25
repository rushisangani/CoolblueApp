#if DEBUG
import Foundation
import Networking

// Answers search requests with pages the UI tests pass in the launch environment, instead of calling the API.
// Image requests fail, so rows show their placeholder.
nonisolated struct LaunchEnvironmentNetworkClient: NetworkClient {
    // `UITEST_SEARCH_PAGE_<n>` holds the JSON for page n
    static let pageKeyPrefix = "UITEST_SEARCH_PAGE_"

    private let pages: [Data]

    // nil unless the UI tests passed at least one page
    init?(environment: [String: String]) {
        var pages: [Data] = []
        while let page = environment[Self.pageKeyPrefix + String(pages.count + 1)] {
            pages.append(Data(page.utf8))
        }
        guard !pages.isEmpty else {
            return nil
        }
        self.pages = pages
    }

    func data(from url: URL) async throws(NetworkError) -> Data {
        guard url.path.hasSuffix("/search") else {
            throw .invalidResponse
        }
        let page = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first { $0.name == "page" }?
            .value
        // A page past the end repeats the last one, like the real API.
        return pages[min(Int(page ?? "") ?? 1, pages.count) - 1]
    }
}
#endif
