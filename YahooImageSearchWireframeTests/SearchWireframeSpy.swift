//
//  SearchWireframeSpy.swift
//  ImageSearchSample+WireframeTests
//
//  Created by cano on 2018/11/07.
//  Copyright © 2018 cano. All rights reserved.
//

import UIKit

@testable import YahooImageSearchWireframe

class SearchWireframeSpy: SearchWireframeType {
    enum CallArgs {
        case shwoSettingPage
        case showAlert
        case showPhotoList
    }
    
    private(set) var callArgs: [CallArgs] = []

    var viewController: UIViewController? { return nil }

    func goToSettingPage() {
        self.callArgs.append(.shwoSettingPage)
    }

    func showError(error: Error) {
        self.callArgs.append(.showAlert)
    }

    func showPhotoList(_ urls: [URL], _ index: Int) {
        self.callArgs.append(.showPhotoList)
    }

}
