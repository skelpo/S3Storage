import S3

/// The custom `S3Client` type required by `S3Storage`.
public protocol S3StorageClient: S3Client {
    
    /// Gets a URLBuilder implementation instance from a container.
    func urlBuilder(for container: Container) -> URLBuilder
}

extension S3: S3StorageClient {
    
    /// Gets a URLBuilder implementation instance from a container.
    public func urlBuilder(for container: Container) -> URLBuilder {
        return S3URLBuilder(container, defaultBucket: defaultBucket, config: signer.config)
    }
}
