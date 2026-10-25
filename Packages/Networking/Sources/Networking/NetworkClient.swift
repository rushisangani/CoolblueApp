import Foundation

/// Fetches raw data over the network.
///
/// The single seam between the app and the transport: features depend on this protocol,
/// so tests can substitute a stub without touching `URLSession`.
public protocol NetworkClient: Sendable {
    /// Returns the body of a successful (2xx) response.
    ///
    /// - Throws: ``NetworkError`` for connectivity problems, cancellation and non-2xx status codes.
    func data(from url: URL) async throws(NetworkError) -> Data
}
