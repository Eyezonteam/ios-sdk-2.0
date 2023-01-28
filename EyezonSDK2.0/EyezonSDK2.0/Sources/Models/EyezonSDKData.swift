//
//  EyezonSDKData.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation
import UIKit

public class EyezonSDKInterfaceBuilder {
    
    let isNavigationController: Bool?
    
    let navBarBackgroundColor: UIColor?
    
    let navBarTitleText: String?
    let navBarTitleColor: UIColor?
    
    let navBarBackButtonText: String?
    let navBarBackButtonColor: UIColor?
    
    let navBarBackButtonLeftPosition: Bool?
    
    public init(
        isNavigationController: Bool? = false,
        navBarBackgroundColor: UIColor? = UIColor.white,
        navBarTitleText: String? = "Eyezon",
        navBarTitleColor: UIColor? = UIColor(red: 1.00, green: 0.18, blue: 0.33, alpha: 1.00),
        navBarBackButtonText: String? = "Back",
        navBarBackButtonColor: UIColor? = UIColor(red: 1.00, green: 0.18, blue: 0.33, alpha: 1.00),
        navBarBackButtonLeftPosition: Bool? = true
    ) {
        self.isNavigationController = isNavigationController
        self.navBarBackgroundColor = navBarBackgroundColor
        self.navBarTitleText = navBarTitleText
        self.navBarTitleColor = navBarTitleColor
        self.navBarBackButtonText = navBarBackButtonText
        self.navBarBackButtonColor = navBarBackButtonColor
        self.navBarBackButtonLeftPosition = navBarBackButtonLeftPosition
    }
}


public class EyezonSDKData {
    let businessId: String
    let buttonId: String
    let widgetUrl: String?
    
    private var apnsToken: String? {
        Storage.shared.getAPNSToken()
    }
    private let application = "IOS_SDK"
    private var eyezonRegion: String {
        return Storage.shared.getCurrentServer().rawValue
    }
    
    var validUrl: String {
        var validUrlString = "\(widgetUrl ?? UrlConstants.DEFAULT_WIDGET_URL)&buttonId=\(buttonId)&businessId=\(businessId)&application=\(application)&eyezonRegion=\(eyezonRegion)"
        validUrlString.safeAppendToUrl(apnsToken, fieldName: "apnToken")
        return validUrlString
    }
    
    public init(
        businessId: String,
        buttonId: String,
        widgetUrl: String? = nil
    ) {
        self.businessId = businessId
        self.buttonId = buttonId
        self.widgetUrl = widgetUrl
    }
}
