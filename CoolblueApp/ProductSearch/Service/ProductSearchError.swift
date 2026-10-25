import Foundation
import Networking

// Search Error
nonisolated enum ProductSearchError: Error, Equatable, Sendable {
    case offline
    case server
    case decoding
    case cancelled
    case unknown
}

// Initialize ProductSearchError from NetworkError
nonisolated extension ProductSearchError {
    init(_ error: NetworkError) {
        switch error {
        case .noConnection, .timedOut:
            self = .offline
        case .cancelled:
            self = .cancelled
        case .invalidResponse, .badStatus:
            self = .server
        case .transport:
            self = .unknown
        }
    }
}

extension ProductSearchError {
    // Translated in Localizable.xcstrings.
    var message: LocalizedStringResource {
        switch self {
        case .offline:
            "Check your internet connection and try again."
        case .server, .decoding, .cancelled, .unknown:
            "Something went wrong. Please try again."
        }
    }
}
