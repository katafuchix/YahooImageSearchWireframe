//
//  UIViewController.swift
//  ImageSearchSample+Wireframe
//
//  Created by cano on 2018/11/06.
//  Copyright © 2018 cano. All rights reserved.
//

import UIKit

extension UIViewController {

    func showErrorAlert(_ title: String?, _ message: String, _ callback: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title ?? "Error", message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            callback?()
        })

        present(alert, animated: true, completion: nil)
    }

    func showErrorAlert(_ title: String?, _ error: Error?, _ callback: (() -> Void)? = nil) {
        showErrorAlert(title, error != nil ? error!.localizedDescription : "Unknown error.", callback)
    }
}
