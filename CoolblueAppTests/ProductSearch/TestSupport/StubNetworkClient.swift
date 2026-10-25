import Foundation
import Networking
@testable import CoolblueApp

// A NetworkClient that returns a fixed result, whatever the URL.
struct StubNetworkClient: NetworkClient {
    let result: Result<Data, NetworkError>

    func data(from url: URL) async throws(NetworkError) -> Data {
        try result.get()
    }
}
