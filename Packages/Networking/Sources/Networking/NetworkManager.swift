import Foundation

/// A ``NetworkClient`` backed by `URLSession`.
///
/// The struct is stateless and `Sendable`, so any actor can call it directly without hopping to the main actor.
/// `URLSession` does the actual I/O off the calling thread, so awaiting a request never blocks the caller.
public struct NetworkManager: NetworkClient {
    private let session: URLSession

    /// Creates a client that sends requests through `session`.
    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func data(from url: URL) async throws(NetworkError) -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw Self.networkError(from: error)
        }

        // URLSession only throws for transport failures; an HTTP error status still arrives as a response.
        guard let httpResponse = response as? HTTPURLResponse else {
            throw .invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw .badStatus(httpResponse.statusCode)
        }
        return data
    }

    private static func networkError(from error: any Error) -> NetworkError {
        // Task cancellation can surface as either error type, depending on when it happens.
        if error is CancellationError { return .cancelled }
        guard let urlError = error as? URLError else { return .transport(.unknown) }

        switch urlError.code {
        case .cancelled:
            return .cancelled
        case .timedOut:
            return .timedOut
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed, .internationalRoamingOff:
            return .noConnection
        default:
            return .transport(urlError.code)
        }
    }
}
