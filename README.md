# 📡 NetworkManager

**NetworkManager** is a lightweight, extensible Swift package designed to simplify building RESTful API calls in iOS and SwiftUI apps. It promotes clean, type-safe, and testable networking using Swift's modern concurrency and protocol-oriented programming.

---

## 🔧 Features

- ✅ Protocol-based abstraction with `Requestable`
- 🔁 Built-in retry logic for transient failures
- 🧼 Clean URL construction using `URLComponents`
- 🔒 No internet connection detection
- 📦 Works seamlessly with `Codable` request/response bodies
- 🔌 Pluggable `URLSession` for testing/mocking

---

## 📦 Components

### `HTTPMethod`
Enum defining standard HTTP methods: `.get`, `.post`, `.put`, `.patch`, `.delete`.

### `NetworkConfiguration`
Defines the base URL and optional API version for a network environment.

```swift
protocol NetworkConfiguration {
    static var baseURL: URL? { get }
    static var apiVersion: String? { get }
}
```

### `Requestable`
A generic protocol for defining and executing API requests with typed responses.

```swift
protocol Requestable: NetworkConfiguration {
    associatedtype Response
    var urlPath: String { get }
    var httpMethod: HTTPMethod { get }
    var requestBody: Codable? { get }
    var queryParameters: [String: String]? { get }
    var headers: [String: String]? { get }

    func request(using session: URLSession, maxRetries: Int, retryDelay: TimeInterval) async throws -> Response
}
```

Includes built-in:
- Default headers, body, and query parameters
- URL building logic
- Retry mechanism
- Internet connectivity error detection

### `NetworkError`
Defines error types

```swift
public enum NetworkError: Error {
    case invalidURL
    case dataTaskFailed
    case httpError(code: Int, data: Data?)
    case decodingFailed(Error)
    case noInternetConnection
    case unknown(Error)
}
```

## 🚀 Example Usage
See more details: https://github.com/khoavd-dev/NetworkManagerExample

## 📱 Platform
- Swift 5.0+
- iOS 15.0+
- Async/Await based (iOS 15+ recommended for full concurrency)

## 👨‍💻 Author
Built by Khoa Vo. Contributions welcome!
