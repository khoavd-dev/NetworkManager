// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// MARK: - Network Configuration
public protocol NetworkConfiguration {
    static var baseURL: URL? { get }
    static var apiVersion: String? { get }
}
