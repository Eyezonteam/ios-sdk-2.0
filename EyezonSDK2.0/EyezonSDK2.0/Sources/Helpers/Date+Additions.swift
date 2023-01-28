//
//  Date+Additions.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation

extension Date {
    
    func currentTimeMillis() -> Int64 {
        Int64(self.timeIntervalSince1970 * 1000)
    }
}
