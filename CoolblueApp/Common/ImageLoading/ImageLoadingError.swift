/// The ways loading a remote image can fail.
public nonisolated enum ImageLoadingError: Error, Equatable, Sendable {
    /// The download failed.
    case network(NetworkError)
    /// The download succeeded, but the data isn't a decodable image.
    case invalidImageData
}
