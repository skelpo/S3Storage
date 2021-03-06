import Storage
import S3

/// A `Storage` interface for the Amazon S3 API, backed with the [LiveUI/S3](https://github.com/LiveUI/S3) library.
///
/// `S3Storage` use an `S3StorageClient` instead of `S3Client`. We conform the basic `S3` type for you, so as long as you register
/// your `S3` instance properly, everything should work as normal.
///
///     try services.register(S3(defaultBucket: bucket, signer: signer), as: S3StorageClient.self)
///
/// When uploading a file to Amazon S3, you can pass a path into the `.store(file:at:)` method. If you do, the file's localtion will be
/// `path/filename`. If no path is passed in and there is no default path, the file will be located at `filename`.
///
/// When accessing a file to read, override, or delete it, use the reletive path instead of the full URL.
///
///     storage.fetch(file: "documents/README.md")
public struct S3Storage: Storage, ServiceType {
    
    /// See `ServiceType.makeService(for:)`.
    public static func makeService(for worker: Container) throws -> S3Storage {
        return S3Storage(container: worker)
    }
    
    /// The path that will be used if `nil` is passed into the `S3Storage.store(file:at:)` method
    public let defaultPath: String?
    
    /// The container used by the `S3Client` instance to create, read, and delete files.
    internal let container: Container
    
    
    /// Creates a new `S3Storage` instance.
    ///
    /// - Parameters:
    ///   - container: The container used by the `S3Client` instance to create, read, and delete files.
    ///   - defaultPath: The default path that files will be stored at.
    public init(container: Container, defaultPath: String? = nil) {
        self.container = container
        self.defaultPath = defaultPath
    }
    
    /// See `Storage.store(file:at:)`
    public func store(file: Vapor.File, at path: String? = nil) -> EventLoopFuture<String> {
        do {
            let client = try self.container.make(S3StorageClient.self)
            
            let s3Path: String
            if let unwrappedPath = path {
                s3Path = unwrappedPath + "/" + file.filename
            } else if let unwrappedPath = self.defaultPath {
                s3Path = unwrappedPath + "/" + file.filename
            } else {
                s3Path = file.filename
            }
            
            let type = file.contentType?.description ?? MediaType.plainText.description
            let upload = File.Upload(
                data: file.data,
                destination: s3Path,
                mime: type
            )
            
            return try client.put(file: upload, on: container).map { response in
                return response.path
            }
        } catch let error {
            return self.container.future(error: error)
        }
    }
    
    /// See `Storage.fetch(file:)`.
    public func fetch(file: String) -> EventLoopFuture<Vapor.File> {
        do {
            let client = try self.container.make(S3StorageClient.self)
            
            return try client.get(file: file, on: self.container).map { response in
                guard let name = response.path.split(separator: "/").last.map(String.init) else {
                    throw StorageError(identifier: "fileName", reason: "Unable to extract file name from path `\(response.path)`")
                }
                
                return Vapor.File(data: response.data, filename: name)
            }
        } catch let error {
            return self.container.future(error: error)
        }
    }
    
    /// See `Storage.write(file:data:options:)`.
    ///
    /// Amazon S3 does not support mutating files, so we just delete the existing one and upload a new version
    /// with the data passed in. The `options` parameter is ignored.
    public func write(file: String, with data: Data, options: Data.WritingOptions = []) -> EventLoopFuture<Vapor.File> {
        do {
            let path = String(file.split(separator: "/").dropLast().joined())
            guard let name = file.split(separator: "/").last.map(String.init) else {
                throw StorageError(identifier: "fileName", reason: "Unable to extract file name from path `\(file)`")
            }
            
            return self.delete(file: file).flatMap {
                let file = Vapor.File(data: data, filename: name)
                
                return self.store(file: file, at: path).transform(to: file)
            }
        } catch let error {
            return self.container.future(error: error)
        }
    }
    
    /// See `Storage.delete(file:)`.
    public func delete(file: String) -> EventLoopFuture<Void> {
        do {
            let client = try self.container.make(S3StorageClient.self)
            
            return try client.delete(file: file, on: self.container)
        } catch let error {
            return self.container.future(error: error)
        }
    }
}
