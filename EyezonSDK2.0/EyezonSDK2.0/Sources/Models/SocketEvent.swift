//
//  SocketEvent.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 03.08.2021.
//

import Foundation

/// Analytics event
enum AnalyticEvents {
    static let EVENT_INIT_SDK = "init_sdk"
}

///Webview event
struct KnownClient: Codable {
    let eyezonClientId: Int
}
