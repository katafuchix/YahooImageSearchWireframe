//
//  SearchServiceStub.swift
//  ImageSearchSample+WireframeTests
//
//  Created by cano on 2018/11/07.
//  Copyright © 2018 cano. All rights reserved.
//

import UIKit
import XCTest
import RxSwift
import RxCocoa

@testable import YahooImageSearchWireframe

class SearchServiceStub: SearchServiceType {

    enum Result {
        case succeeded(_ urls: [URL])
        case failed(_ error: Error)
    }
    private let result: Result
    private let parameters: [String:String]
    init(result: SearchServiceStub.Result, parameters: [String:String]) {
        self.result = result
        self.parameters = parameters
    }


    func getImageUrls(_ parameters:[String:String]) -> Observable<[URL]> {
        switch result {
        case .succeeded( let urls):
            return Observable.just(urls)
        case .failed(let error):
            return Observable.error(error)
        }
    }
}
