//
//  ApiService.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 23.12.2021.
//

import Foundation

fileprivate class ApiError: Codable, LocalizedError {
    var message: String
    
    init(
        message: String
    ) {
        self.message = message
    }
    
    var errorDescription: String? {
        get {
            return self.message
        }
    }
}

final class ApiService {
    private static var apiUrl: String {
        switch Storage.shared.getCurrentServer() {
        case .prod:
            return UrlConstants.RELEASE_BASE_URL_EU
        case .sandbox:
            return UrlConstants.DEBUG_BASE_URL
        }
    }
    
    static func logout(
        completion: @escaping (_ logout: Bool, _ error: Error?) -> Void
    ) {
        let clientId = Storage.shared.getClientId()
        if clientId == 0 {
            completion(false, ApiError(message: "ClientId is missing"))
            return
        }
        guard let token = Storage.shared.getAPNSToken(), !token.isEmpty else {
            completion(false, ApiError(message: "APN Token is missing"))
            return
        }
        guard let url = URL(string: "\(apiUrl)/api/client/\(clientId)/apn?token=\(token)") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let session = URLSession.shared.dataTask(with: request) { data, response, error in
            guard data != nil, error == nil, (response as? HTTPURLResponse)?.statusCode == 200  else {
                if error == nil,
                   let data = data,
                   let error = try? JSONDecoder().decode(ApiError.self, from: data) {
                    completion(false, error)
                } else {
                    completion(false, error)
                }
                return
            }
            completion(true, nil)
        }
        session.resume()
    }
}
