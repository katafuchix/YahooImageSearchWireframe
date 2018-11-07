//
//  SearchWireframe.swift
//  ImageSearchSample+Wireframe
//
//  Created by cano on 2018/11/06.
//  Copyright © 2018 cano. All rights reserved.
//

import UIKit
import SKPhotoBrowser

protocol SearchWireframeType: Wireframe {
    func showPhotoList(_ urls: [URL], _ index: Int)
}

class SearchWireframe: SearchWireframeType {

    var viewController: UIViewController? { return searchViewController }
    private weak var searchViewController: ViewController?

    init(viewController: ViewController) {
        self.searchViewController = viewController
    }

    func showPhotoList(_ urls: [URL], _ index: Int) {
        // URLからSKPhotoを生成
        let photos: [SKPhoto] = urls.compactMap { url in
            return SKPhoto.photoWithImageURL(url.absoluteString)
        }
        // 初期化
        let browser = SKPhotoBrowser(photos: photos)
        // 初回に表示するインデックス
        browser.initializePageIndex(index)
        // 表示
        self.searchViewController?.present(browser, animated: true, completion: {})
    }
}
