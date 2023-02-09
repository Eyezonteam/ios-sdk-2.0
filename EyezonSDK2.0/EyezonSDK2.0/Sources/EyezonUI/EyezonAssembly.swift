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
        and broadcastReceiver: EyezonBroadcastReceiver?
    ) -> UIViewController {
        let viewController = EyezonWebViewController(
            widgetUrl: data.validUrl,
            broadcastReceiver: broadcastReceiver)
        let presenter = EyezonWebViewPresenterImpl(with: viewController)
        presenter.closed = { [weak viewController] in
            viewController?.dismiss(animated: true)
        }
        viewController.presenter = presenter
        return viewController
    }
}
