//
//  Storage.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 04.08.2021.
//

import Foundation


final class Storage {
    /// Nested type
    private enum Keys: String {
        case eyezonAuthToken
        case eyezonClientId
        case eyezonCurrentServer
        case eyezonAPNSToken
    }
    
    static let shared = Storage()
    
    private let userDefaults = UserDefaults.standard
    
    private init() { }
    
    func setAuthToken(_ value: String) {
        userDefaults.set(value, forKey: Keys.eyezonAuthToken.rawValue)
    }
    
    func setClientId(_ value: Int) {
        userDefaults.set(value, forKey: Keys.eyezonClientId.rawValue)
    }
    
    func setCurrentServer(_ value: ServerArea) {
        userDefaults.set(value.rawValue, forKey: Keys.eyezonCurrentServer.rawValue)
    }
    
    func setAPNSToken(_ value: String) {
        userDefaults.set(value, forKey: Keys.eyezonAPNSToken.rawValue)
    }
    
    func getAuthToken() -> String {
        return userDefaults.string(forKey: Keys.eyezonAuthToken.rawValue) ?? .empty
    }
    
    func getClientId() -> Int {
        return userDefaults.integer(forKey: Keys.eyezonClientId.rawValue)
    }
    
    func getCurrentServer() -> ServerArea {
        let areaString = userDefaults.string(forKey: Keys.eyezonCurrentServer.rawValue) ?? .empty
        return ServerArea(rawValue: areaString) ?? .prod
    }
    
    func getAPNSToken() -> String? {
        return userDefaults.string(forKey: Keys.eyezonAPNSToken.rawValue)
    }
}
