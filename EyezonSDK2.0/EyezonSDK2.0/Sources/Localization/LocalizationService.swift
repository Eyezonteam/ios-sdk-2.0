//
//  LocalizationService.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 05.08.2021.
//

import Foundation
@_implementationOnly import SwiftyJSON

enum LocalizationKeys {
    static let SDK_ALERT_ERROR_TITLE = "SDK_ALERT_ERROR_TITLE"
    static let SDK_ALERT_ERROR_MESSAGE = "SDK_ALERT_ERROR_MESSAGE"
}

final class LocalizationService {
    /// Nested type
    private enum Constants {
        static let STORAGE_BASE_URL = "https://storage.googleapis.com/"
        static let LANGUAGES_JSON = "languages.json"
        static let STORAGE_IOS = "eyezon_language/ios/"
    }
    // MARK: - Public properties
    static let shared = LocalizationService()
    var localizeDict: [String: String]!

    // MARK: - Lifecycle
    private init() {
        loadLocalize(for: Locale.current.languageCode ?? "en") { }
    }

    
    func loadLocalize(for locale: String, completion: @escaping () -> Void) {
        let urlString = "\(Constants.STORAGE_BASE_URL)\(Constants.STORAGE_IOS)\(Constants.LANGUAGES_JSON)"
        guard let url = URL(string: urlString) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard error == nil, response != nil, let data = data else {
                return
            }
            guard let json = try? JSON(data: data).dictionaryObject else {
                return
            }
            
            self?.loadSpecifiedLocalization(
                locale: json.keys.contains(locale) ? locale : "en",
                completion: {
                    completion()
                }
            )
        }
        task.resume()
    }
    
    private func loadSpecifiedLocalization(locale: String, completion: @escaping () -> Void) {
        let urlString = "\(Constants.STORAGE_BASE_URL)\(Constants.STORAGE_IOS)\(locale).json"
        guard let url = URL(string: urlString) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard error == nil, response != nil, let data = data else {
                return
            }
            guard let json = try? JSON(data: data), let dictionary = json.dictionaryObject as? [String: String] else {
                return
            }
            self?.localizeDict = dictionary
            completion()
        }
        task.resume()
    }
    
    func localizedString(key: String) -> String {
        return localizeDict?[key] ?? key
    }
}
