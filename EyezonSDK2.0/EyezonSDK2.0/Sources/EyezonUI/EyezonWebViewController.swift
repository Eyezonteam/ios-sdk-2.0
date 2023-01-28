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
    
    let navView = UIView()
    let seperatorView = UIView()
    let titleLabel = UILabel()
    
    let navBarButton = UIButton(type: .system) as UIButton
    
    private let widgetUrl: String
    private weak var broadcastReceiver: EyezonBroadcastReceiver?
    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        [eyezonWebView]
    }
    
    // custom nav bar
    private var isCustomNavigationController: Bool
    
    private let navBarBackgroundViewColor: UIColor
    
    private let navBarTitleLabelText: String
    private let navBarTitleLabelColor: UIColor
    
    private let navBarBackButtonTitleText: String
    private let navBarBackButtonTitleColor: UIColor
    private var navBarBackButtonLeftPositionState: Bool
    
    private var topInset: CGFloat = 10
    
    // MARK: - Public properties
    var presenter: EyezonWebViewPresenter!
    
    // MARK: - Lifecycle
    init(
        widgetUrl: String,
        isNavigationController: Bool,
        navBarBackgroundColor: UIColor,
        navBarTitleText: String,
        navBarTitleColor: UIColor,
        navBarBackButtonText: String,
        navBarBackButtonColor: UIColor,
        navBarBackButtonLeftPosition: Bool,
        broadcastReceiver: EyezonBroadcastReceiver?
    ) {
        self.widgetUrl = widgetUrl
        
        self.isCustomNavigationController = !isNavigationController
        
        self.navBarBackgroundViewColor = navBarBackgroundColor
        
        self.navBarTitleLabelText = navBarTitleText
        self.navBarTitleLabelColor = navBarTitleColor
        
        self.navBarBackButtonTitleText = navBarBackButtonText
        self.navBarBackButtonTitleColor = navBarBackButtonColor
        self.navBarBackButtonLeftPositionState = navBarBackButtonLeftPosition
        
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
        // background color
        navigationController?.navigationBar.backgroundColor = navBarBackgroundViewColor
        
        // title
        navigationItem.title = navBarTitleLabelText
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: navBarTitleLabelColor]
        
        // back button
        let backButton = UIBarButtonItem()
        backButton.title = navBarBackButtonTitleText
        backButton.tintColor = navBarBackButtonTitleColor
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
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
        topInset = modalPresentationStyle == .fullScreen ? 0 : 10
        if !isCustomNavigationController {
            navView.backgroundColor = navBarBackgroundViewColor
            navView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(navView)
            
            titleLabel.text = navBarTitleLabelText
            titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
            titleLabel.textColor = navBarTitleLabelColor
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            navView.addSubview(titleLabel)
            
            navBarButton.setTitle(navBarBackButtonTitleText, for: .normal)
            navBarButton.setTitleColor(navBarBackButtonTitleColor, for: .normal)
            navBarButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            navBarButton.translatesAutoresizingMaskIntoConstraints = false
            navBarButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
            navBarButton.titleLabel?.adjustsFontSizeToFitWidth = true
            
            if navBarBackButtonTitleText == "" {
                navBarButton.isHidden = true
            } else {
                navBarButton.isHidden = false
            }
            
            navView.addSubview(navBarButton)
            
            seperatorView.backgroundColor = .gray.withAlphaComponent(0.15)
            seperatorView.translatesAutoresizingMaskIntoConstraints = false
            
            navView.addSubview(seperatorView)
        }
        
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
        if !isCustomNavigationController {
            let navBarConstraints = [
                navView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topInset),
                navView.bottomAnchor.constraint(equalTo: eyezonWebView.topAnchor),
                navView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                navView.heightAnchor.constraint(equalToConstant: 44)
            ]
            NSLayoutConstraint.activate(navBarConstraints)
            
            let titleLabelConstraints = [
                titleLabel.topAnchor.constraint(equalTo: navView.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: navView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: navView.trailingAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: navView.bottomAnchor)
            ]
            NSLayoutConstraint.activate(titleLabelConstraints)
            
            let seperatorViewConstraints = [
                seperatorView.leadingAnchor.constraint(equalTo: navView.leadingAnchor),
                seperatorView.trailingAnchor.constraint(equalTo: navView.trailingAnchor),
                seperatorView.bottomAnchor.constraint(equalTo: navView.bottomAnchor),
                seperatorView.heightAnchor.constraint(equalToConstant: 1)
            ]
            NSLayoutConstraint.activate(seperatorViewConstraints)
            
            let leftNavBarButtonConstraints = [
                navBarButton.leadingAnchor.constraint(equalTo: navView.leadingAnchor, constant: 9),
                navBarButton.topAnchor.constraint(equalTo: navView.topAnchor),
                navBarButton.bottomAnchor.constraint(equalTo: navView.bottomAnchor),
                navBarButton.widthAnchor.constraint(lessThanOrEqualToConstant: 90)
            ]
            
            let rightNavBarButtonConstraints = [
                navBarButton.trailingAnchor.constraint(equalTo: navView.trailingAnchor, constant: -9),
                navBarButton.topAnchor.constraint(equalTo: navView.topAnchor),
                navBarButton.bottomAnchor.constraint(equalTo: navView.bottomAnchor),
                navBarButton.widthAnchor.constraint(lessThanOrEqualToConstant: 90)
            ]
            
            if navBarBackButtonLeftPositionState {
                NSLayoutConstraint.activate(leftNavBarButtonConstraints)
            } else {
                NSLayoutConstraint.activate(rightNavBarButtonConstraints)
            }
            
            let webViewConstraints = [
                eyezonWebView.topAnchor.constraint(equalTo: navView.bottomAnchor),
                eyezonWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                eyezonWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                eyezonWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
            NSLayoutConstraint.activate(webViewConstraints)
            
            let loadingViewConstraints = [
                loadingView.topAnchor.constraint(equalTo: navView.bottomAnchor),
                loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

                loaderView.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
                loaderView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor)
            ]
            NSLayoutConstraint.activate(loadingViewConstraints)
        } else {
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
        eyezonWebView.evaluateJavaScript(EyezonJSConstants.leaveDialog)
    }
}
