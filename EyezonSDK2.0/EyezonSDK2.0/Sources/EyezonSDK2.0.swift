//
//  EyezonSDK.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation
import UIKit

public enum ServerArea: String {
    case sandbox
    case prod
}

public class Eyezon: NSObject {
    private var clientId: String?
    
    public static let instance = Eyezon()
    weak var broadcastReceiver: EyezonBroadcastReceiver?
    
    private override init() {
        super.init()
    }
    
    public func initSdk(
        area: ServerArea,
        completion: @escaping () -> Void
    ) {
        _ = LocalizationService.shared
        Storage.shared.setCurrentServer(area)
        completion()
    }
    
    public func initMessaging(apnsData: Data) {
        let tokenString = apnsData.reduce("") { $0 + String(format: "%02.2hhx", $1) }
        Storage.shared.setAPNSToken(tokenString)
    }
    
    /// Method for opening EyezonWebView
    /// return UIViewController in which webView embedded
    public func openButton(data: EyezonSDKData, interfaceBuilder: EyezonSDKInterfaceBuilder? = nil, broadcastReceiver: EyezonBroadcastReceiver?) -> UIViewController {
        self.broadcastReceiver = broadcastReceiver
        self.clientId = data.buttonId
        return EyezonAssembly.viewController(with: data, and: broadcastReceiver)
    }
    
    public func logout(
        completion: @escaping (_ logout: Bool, _ error: Error?) -> Void
    ) {
        ApiService.logout { logout, error in
            guard error == nil else {
                completion(false, error)
                return
            }
            completion(logout, nil)
        }
    }
}
