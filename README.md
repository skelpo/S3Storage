# S3Storage

An implementation of [skelpo/Storage](https://github.com/skelpo/Storage) for Amazon S3. Uses the [LiveUI/S3](https://github.com/LiveUI/S3) package for interacting with the S3 API.

## Installing

Add the package declaration to your manifest's `dependencies` array with the [latest version](https://github.com/skelpo/S3Storage/releases/latest):

```swift
.package(url: "https://github.com/skelpo/S3Storage.git", from: "0.1.0")
```

Then run `swift package update` and regenerate your Xcode project (if you have one).

## Configuration

Create and register an `S3Signer` instance with your app's services. Then register an `S3` instance (or another implementation of `S3StorageClient`) as `S3StorageClient`:

```swift
try services.register(S3(defaultBucket: bucket, signer: signer), as: S3StorageClient.self)
```

# API

You can find API documentation [here](http://www.skelpo.codes/S3Storage).

# License

S3Storage is under the [MIT license agreement](https://github.com/skelpo/S3Storage/blob/master/LICENSE).


