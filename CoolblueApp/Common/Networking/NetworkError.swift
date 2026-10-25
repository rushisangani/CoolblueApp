import Foundation

/// The ways a ``NetworkClient`` request can fail.
///
/// A closed set, so callers can switch over it exhaustively and translate it into their own errors.
public nonisolated enum NetworkError: Error, Equatable, Sendable {
    /// The device has no usable connection.
    case noConnection
    /// The server didn't respond in time.
    case timedOut
    /// The request was cancelled, usually because the caller's task was cancelled.
    case cancelled
    /// The response wasn't an HTTP response.
    case invalidResponse
    /// The server answered with a status code outside 200–299.
    case badStatus(Int)
    /// Any other transport failure, with the underlying `URLError` code for diagnostics.
    case transport(URLError.Code)
}
