import S3
import Vapor
import XCTest
@testable import S3Storage

extension S3 {
    static func register(to services: inout Services)throws {
        guard
            let accessKey = Environment.get("S3_ACCESS_KEY"),
            let secretKey = Environment.get("S3_SECRET_KEY"),
            let bucket = Environment.get("S3_BUCKET")
        else {
            throw Abort(.internalServerError, reason: "Missing S3 configuration variable(s)")
        }
        
        let config = S3Signer.Config(
            accessKey: accessKey,
            secretKey: secretKey,
            region: Region(name: .usEast1)
        )
        let signer = try S3Signer(config)
        
        services.register(signer)
        try services.register(S3(defaultBucket: bucket, signer: signer), as: S3StorageClient.self)
    }
}

final class S3StorageTests: XCTestCase {
    let app: Application = {
        var services = Services.default()
        services.register(S3Storage.self)
        try! S3.register(to: &services)
        
        let config = Config.default()
        let env = try! Environment.detect()
        
        return try! Application(config: config, environment: env, services: services)
    }()
    
    let data = """
    # Storage

    Test data for the `LocalStorage` instance so we can test it.

    I could use Lorum Ipsum, or I could just sit here and write jibberish like I am now. It might take long, but oh well.

    Listing to the Piano Guys right now.

    Ok, that should be enough bytes for anyone. Unless we are short of the chunk size. I want enough data for at least two chunks of data.

    # Section 2

    ^><<>@<^<>^<>^<>^<>^<>^<>^<>^ open mouth 😮. Hmm, I wonder how that will work
    Maybe if I ran a byte count I could stop typing. But I'm too lazy.

    I hope this is enough.

    # Final
    """.data(using: .utf8)!
    
    func testStore()throws {
        let storage = try self.app.make(S3Storage.self)
        let file = Vapor.File(data: self.data, filename: "test.md")
        
        let path = try storage.store(file: file, at: "markdown").wait()
        
        XCTAssertEqual(path, "https://s3.us-east-1.amazonaws.com/ck-s3storage-test/markdown/test.md")
    }
    
    func testFetch()throws {
        let storage = try self.app.make(S3Storage.self)
        
        let file = try storage.fetch(file: "markdown/test.md").wait()
        
        XCTAssertEqual(file.filename, "test.md")
        XCTAssertEqual(file.data, self.data)
    }
    
    func testWrite()throws {
        let storage = try self.app.make(S3Storage.self)
        
        let updated = try storage.write(file: "markdown/test.md", with: "All new updated data!".data(using: .utf8)!).wait()
        
        XCTAssertEqual(updated.data, "All new updated data!".data(using: .utf8))
        XCTAssertEqual(updated.filename, "test.md")
    }
    
    func testDelete()throws {
        let storage = try self.app.make(S3Storage.self)
        try XCTAssertNoThrow(storage.delete(file: "markdown/test.md").wait())
    }
    
    static var allTests: [(String, (S3StorageTests) -> ()throws -> ())] = [
        ("testStore", testStore),
        ("testFetch", testFetch),
        ("testWrite", testWrite),
        ("testDelete", testDelete)
    ]
}
