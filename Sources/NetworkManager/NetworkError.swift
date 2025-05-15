//
//  NetworkError.swift
//  NetworkManager
//
//  Created by Khoa Vo on 7/5/25.
//

import Foundation

// MARK: - Network Error
public enum NetworkError: Error {
    case invalidURL
    case dataTaskFailed
    case httpError(code: Int, data: Data?)
    case decodingFailed(Error)
    case noInternetConnection
    case unknown(Error)
}
