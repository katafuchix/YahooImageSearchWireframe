//
//  Wireframe.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import SVProgressHUD

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import Cocoa
#endif

enum RetryResult {
    case retry
    case cancel
}

protocol Wireframe {
    var viewController: UIViewController? { get }
    func showAlert(_ title: String, _ message: String)
    func showError(error: Error)
    func showLoading(_ message: String?)
    func hideLoading()
}

extension Wireframe {

    func showAlert(_ title: String, _ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.viewController?.present(alertController, animated: true, completion: nil)
    }

    func showError(error: Error) {
        let title  = "エラー"
        let message = error.localizedDescription
        showAlert(title, message)
    }

    func showLoading(_ message: String? = nil) {
        SVProgressHUD.setMinimumSize(CGSize(width: 180, height: 180))
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show(withStatus: message ?? "Loading")
    }

    func hideLoading() {
        SVProgressHUD.dismiss()
    }
}

class DefaultWireframe: Wireframe {
    static let shared = DefaultWireframe()

    func open(url: URL) {
        #if os(iOS)
            UIApplication.shared.openURL(url)
        #elseif os(macOS)
            #if swift(>=4.0)
                NSWorkspace.shared.open(url)
            #else
                NSWorkspace.shared.open(url)
            #endif
        #endif
    }

    #if os(iOS)
    private static func rootViewController() -> UIViewController {
        // cheating, I know
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    #endif

    static func presentAlert(_ message: String) {
        #if os(iOS)
            let alertView = UIAlertController(title: "RxExample", message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
            })
            rootViewController().present(alertView, animated: true, completion: nil)
        #endif
    }

    func promptFor<Action : CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action> {
        #if os(iOS)
        return Observable.create { observer in
            let alertView = UIAlertController(title: "RxExample", message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: cancelAction.description, style: .cancel) { _ in
                observer.on(.next(cancelAction))
            })

            for action in actions {
                alertView.addAction(UIAlertAction(title: action.description, style: .default) { _ in
                    observer.on(.next(action))
                })
            }

            DefaultWireframe.rootViewController().present(alertView, animated: true, completion: nil)

            return Disposables.create {
                alertView.dismiss(animated:false, completion: nil)
            }
        }
        #elseif os(macOS)
            return Observable.error(NSError(domain: "Unimplemented", code: -1, userInfo: nil))
        #endif
    }
}


extension RetryResult : CustomStringConvertible {
    var description: String {
        switch self {
        case .retry:
            return "Retry"
        case .cancel:
            return "Cancel"
        }
    }
}

// maybe useful
extension DefaultWireframe {
    //static let shared = DefaultWireframe()
    weak var viewController: UIViewController? { return topViewController() }

    private func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
