//
//  EyezonBroadcastReceiver.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation

/// Protocol for interacting with eyezon events
public protocol EyezonBroadcastReceiver: AnyObject {
    /// Event for indicating other console events
    func onConsoleEvent(eventName: String, event: [String: Any])
}
