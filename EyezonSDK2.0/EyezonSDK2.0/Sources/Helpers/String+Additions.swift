//
//  String+Additions.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation

extension String {
    public static var empty: String {
        ""
    }
    
    mutating func safeAppendToUrl(_ value: String?, fieldName: String) {
        let appendValue = value ?? .empty
        if !appendValue.isEmpty {
            append("&\(fieldName)=\(appendValue)")
        }
    }
    
    var localizedFromJSON: String {
        return LocalizationService.shared.localizedString(key: self)
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
