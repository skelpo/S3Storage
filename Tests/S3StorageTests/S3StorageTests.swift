import S3
import Vapor
import XCTest
@testable import S3Storage

final class S3StorageTests: XCTestCase {
    let app = Application(environment: .testing, configure: { services in
        guard
            let accessKey = Environment.get("S3_ACCESS_KEY"),
            let secretKey = Environment.get("S3_SECRET_KEY"),
            let bucket = Environment.get("S3_BUCKET")
        else {
            throw Abort(.internalServerError, reason: "Missing S3 configuration variable(s)")
        }

        let config = S3Signer.Config(accessKey: accessKey, secretKey: secretKey, region: Region(name: .usEast1))
        let signer = try S3Signer(config)

        let client = try S3(defaultBucket: bucket, signer: signer)
        services.instance(S3Client.self, client)

        services.register(S3Storage.self, S3Storage.init(container:))
    })
    
    let data: ByteBuffer = {
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
        """

        var buffer = ByteBufferAllocator().buffer(capacity: data.count)
        buffer.writeString(data)

        return buffer
    }()
    
    func testStore()throws {
        let container = try self.app.makeContainer().wait()
        defer { container.shutdown() }

        let storage = try container.make(S3Storage.self)
        let file = Vapor.File(data: self.data, filename: "test.md")
        
        let path = try storage.store(file: file, at: "markdown").wait()
        
        XCTAssertEqual(path, "markdown/test.md")
    }
    
    func testFetch()throws {
        let container = try self.app.makeContainer().wait()
        defer { container.shutdown() }

        let storage = try container.make(S3Storage.self)
        
        let file = try storage.fetch(file: "markdown/test.md").wait()
        
        XCTAssertEqual(file.filename, "test.md")
        XCTAssertEqual(file.data, self.data)
    }
    
    func testWrite()throws {
        let container = try self.app.makeContainer().wait()
        defer { container.shutdown() }

        let storage = try container.make(S3Storage.self)
        
        let updated = try storage.write(file: "markdown/test.md", with: "All new updated data!".data(using: .utf8)!).wait()

        let text = "All new updated data!"
        var newBuffer = ByteBufferAllocator().buffer(capacity: text.count)
        newBuffer.writeString(text)

        XCTAssertEqual(updated.data, newBuffer)
        XCTAssertEqual(updated.filename, "test.md")
    }
    
    func testDelete()throws {
        let container = try self.app.makeContainer().wait()
        defer { container.shutdown() }

        let storage = try container.make(S3Storage.self)
        try XCTAssertNoThrow(storage.delete(file: "markdown/test.md").wait())
    }
}
