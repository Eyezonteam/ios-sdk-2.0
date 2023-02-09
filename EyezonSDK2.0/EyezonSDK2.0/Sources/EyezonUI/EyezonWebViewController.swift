//
//  EyezonWebViewController.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 02.08.2021.
//

import UIKit
import WebKit
import Lottie

enum ButtonPosition {
    case right
    case left
}

final class EyezonWebViewController: UIViewController {
    
    // MARK: - Private properties
    private var eyezonWebView: WKWebView!
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addSubview(loaderView)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    private lazy var loaderView: LottieAnimationView = {
        let bundle = Bundle.allFrameworks.filter({ NSDataAsset(name: "loader", bundle: $0) != nil }).first ?? Bundle.main
        let view = LottieAnimationView(
            asset: Resources.Files.loaderAnimation,
            bundle: bundle,
            imageProvider: nil,
            animationCache: nil,
            configuration: .shared
        )
        view.contentMode = .scaleAspectFit
        view.loopMode = .loop
        view.play()
        view.tintColor = UIColor(red: 255.0 / 255.0, green: 45.0 / 255.0, blue: 85 / 255.0, alpha: 1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let widgetUrl: String
    private weak var broadcastReceiver: EyezonBroadcastReceiver?
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        [eyezonWebView]
    }
    
    // MARK: - Public properties
    var presenter: EyezonWebViewPresenter!
    
    // MARK: - Lifecycle
    init(
        widgetUrl: String,
        broadcastReceiver: EyezonBroadcastReceiver?
    ) {
        self.widgetUrl = widgetUrl
        self.broadcastReceiver = broadcastReceiver
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInterface()
        
        guard let url = URL(string: widgetUrl) else { return }
        let urlRequest = URLRequest(url: url)
        eyezonWebView.load(urlRequest)
        constraintView()
        loading(show: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didEnterBackground()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.presenter.webViewClose()
            self.eyezonWebView?.configuration.userContentController.removeScriptMessageHandler(forName: "logHandler")
        }
    }
    
    func setupInterface() {
        view.backgroundColor = .white
        makeWebView()
        view.addSubview(eyezonWebView)
        view.addSubview(loadingView)
    }
    
    @objc func closeAction(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    private func constraintView() {
        let webViewNCConstraints = [
            eyezonWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            eyezonWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            eyezonWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eyezonWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        NSLayoutConstraint.activate(webViewNCConstraints)
        
        let loadingViewNCConstraints = [
            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            loaderView.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
            loaderView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor)
        ]
        NSLayoutConstraint.activate(loadingViewNCConstraints)
    }
    
    private func makeWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.applicationNameForUserAgent = "Safari" //Fix for old version of WebSDK
        injectingScripts(in: configuration)
        eyezonWebView = WKWebView(frame: .zero, configuration: configuration)
        eyezonWebView.navigationDelegate = self
        eyezonWebView.uiDelegate = self
        eyezonWebView.translatesAutoresizingMaskIntoConstraints = false
        WKWebsiteDataStore.default().removeData(
            ofTypes: .init(arrayLiteral: WKWebsiteDataTypeDiskCache),
            modifiedSince: Date(timeIntervalSince1970: .zero),
            completionHandler: { }
        )
    }
    
    private func injectingScripts(in configuration: WKWebViewConfiguration) {
        /// For listening console events
        let script = WKUserScript(
            source: EyezonJSConstants.listeningConsoleEvents,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        
        /// For disabling zoom-in
        /// https://developer.apple.com/forums/thread/111183
        let scriptZoomDisable = WKUserScript(
            source: EyezonJSConstants.sourceForZoomDisable,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        configuration.userContentController.addUserScript(script)
        configuration.userContentController.addUserScript(scriptZoomDisable)
        /// register the bridge script that listens for the output
        configuration.userContentController.add(self, name: "logHandler")
    }
    
    private func loading(show: Bool) {
        loadingView.isHidden = !show
    }
}

// MARK: - WKUIDelegate
extension EyezonWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        return nil
    }
}

// MARK: - WKNavigationDelegate
extension EyezonWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        presenter.webViewLoaded()
        decisionHandler(.allow)
    }
}

// MARK: - WKScriptMessageHandler
extension EyezonWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let (eventName, eventDictionary) = presenter.mapConsoleEvent(message.body)
        
        // Discard some event's
        // guard !eventName.isEmpty, !eventDictionary.isEmpty else { return }
        
        if eventName == "BUTTON_CLICKED" {
            loading(show: false)
        }
        broadcastReceiver?.onConsoleEvent(eventName: eventName, event: eventDictionary)
    }
}

// MARK: - EyezonWebViewProtocol
extension EyezonWebViewController: EyezonWebViewProtocol {
    func showError(with message: String) {
        let alertVC = UIAlertController(title: "unknownError".localizedFromJSON, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localizedFromJSON, style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.popViewController(animated: true)
        })
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func showComplete(with message: String) {
        let alertVC = UIAlertController(title: "information".localizedFromJSON, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok".localizedFromJSON, style: .default, handler: { _ in
        })
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func willEnterForeground() {
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
    }
    
    func didEnterBackground() {
        eyezonWebView.evaluateJavaScript(EyezonJSConstants.leaveSession)
    }
}
