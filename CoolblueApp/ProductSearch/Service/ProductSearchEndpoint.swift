import Foundation

nonisolated enum ProductSearchEndpoint {
    private static let baseURL = URL(string: "https://bdk0sta2n0.execute-api.eu-west-1.amazonaws.com/mobile-assignment/search")!

    // `pageSize` is ignored by the API, so only `query` and `page` are sent.
    static func url(query: String, page: Int) -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.percentEncodedQueryItems = [
            URLQueryItem(name: "query", value: query.addingPercentEncoding(withAllowedCharacters: .queryValueAllowed)),
            URLQueryItem(name: "page", value: String(page)),
        ]
        return components.url!
    }
}

private nonisolated extension CharacterSet {
    static let queryValueAllowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "+&="))
}
