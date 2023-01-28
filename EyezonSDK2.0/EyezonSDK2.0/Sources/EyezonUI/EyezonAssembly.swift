//
//  Assembly.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import Foundation
import UIKit
import WebKit

final class EyezonAssembly {
    static func viewController(
        with data: EyezonSDKData,
        and interfaceBuilder: EyezonSDKInterfaceBuilder?,
        and broadcastReceiver: EyezonBroadcastReceiver?
    ) -> UIViewController {
        let viewController = EyezonWebViewController(
            widgetUrl: data.validUrl,
            isNavigationController: interfaceBuilder?.isNavigationController ?? false,
            navBarBackgroundColor: interfaceBuilder?.navBarBackgroundColor ?? UIColor.white,
            navBarTitleText: interfaceBuilder?.navBarTitleText ?? "Eyezon",
            navBarTitleColor: interfaceBuilder?.navBarTitleColor ?? UIColor(red: 1.00, green: 0.18, blue: 0.33, alpha: 1.00),
            navBarBackButtonText: interfaceBuilder?.navBarBackButtonText ?? "Back",
            navBarBackButtonColor: interfaceBuilder?.navBarBackButtonColor ?? UIColor(red: 1.00, green: 0.18, blue: 0.33, alpha: 1.00),
            navBarBackButtonLeftPosition: interfaceBuilder?.navBarBackButtonLeftPosition ?? true,
            broadcastReceiver: broadcastReceiver)
        let presenter = EyezonWebViewPresenterImpl(with: viewController)
        presenter.closed = { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        viewController.presenter = presenter
        return viewController
    }
}
