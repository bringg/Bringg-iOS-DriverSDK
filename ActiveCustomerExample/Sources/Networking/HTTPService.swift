//
//  HTTPService.swift
//  BringgActiveCustomerSDKExample
//
//

import Foundation

struct GetUserToken: Codable {
    let accessToken: String
    let secret: String
    let region: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case secret
        case region
    }
}

struct GetActiveTask {
    let taskId: Int
}

// This mocks the http service to the hosting app's server
final class HTTPService {
    static let shared = HTTPService()

    func getUserToken(_ completion: @escaping (Result<GetUserToken, Error>) -> Void) {
        // this is where you contact you server to get the GetUserToken
        // Your server should generate the token using the following api
        // https://developers.bringg.com/reference#generate-customer-one-time-codets
        completion(.failure(NSError.notImplemented))
    }

    func getActiveTask(_ completion: @escaping (Result<GetActiveTask, Error>) -> Void) {
        // The task id and waypoint id for the active customer should be fetched from your server
        completion(.failure(NSError.notImplemented))
    }
}

extension NSError {
    static let notImplemented = NSError(domain: "HTTPService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
}
