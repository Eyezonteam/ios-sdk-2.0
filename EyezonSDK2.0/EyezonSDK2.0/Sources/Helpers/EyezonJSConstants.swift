//
//  EyezonJSConstants.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 06.08.2021.
//

import Foundation

enum EyezonJSConstants {
    static let leaveDialog = "javascript:eyeZon('leaveDialog')"
    
    /// For listening console events
    static let listeningConsoleEvents = "function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); } window.console.log = captureLog;"
    
    /// For disabling zoom-in
    /// https://developer.apple.com/forums/thread/111183
    static let sourceForZoomDisable = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);"
}
